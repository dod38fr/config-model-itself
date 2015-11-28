#    Copyright (c) 2008,2010 Dominique Dumont.
#
#    This file is part of Config-Model-Itself.
#
#    Config-Model is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser Public License as
#    published by the Free Software Foundation; either version 2.1 of
#    the License, or (at your option) any later version.
#
#    Config-Model is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser Public License for more details.
#
#    You should have received a copy of the GNU Lesser Public License
#    along with Config-Model; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA

package Config::Model::Itself::TkEditUI ;

use strict;
use warnings ;
use Carp ;

use base qw/Config::Model::TkUI/;

Construct Tk::Widget 'ConfigModelEditUI';

sub ClassInit {
    my ($class, $mw) = @_;
    # ClassInit is often used to define bindings and/or other
    # resources shared by all instances, e.g., images.


    # cw->Advertise(name=>$widget);
}

sub Populate { 
    my ($cw, $args) = @_;

    my $cm_lib_dir    = (delete $args->{-cm_lib_dir})."/models" ;
    my $model_name   = delete $args->{-model_name} || '';
    my $root_dir     = delete $args->{-root_dir} ; # used to test the edited model

    $args->{'-title'} ||= "cme meta edit $model_name" ;

    $cw->SUPER::Populate($args) ;

    my $items = [[ qw/command test -command/, sub{ $cw->test_model }] ] ;

    my $model_menu = $cw->{my_menu}->cascade(-label => 'Model',
					     -menuitems => $items) ;
    $cw->{cm_lib_dir} = $cm_lib_dir ;
    $cw->{model_name} = $model_name ;
    $cw->{root_dir} = $root_dir ;

    $cw->show_message("Add a name in Class to create your model") unless $model_name;
}

sub test_model {
    my $cw = shift ;

    if ( $cw->{root}->instance->needs_save ) {
        my $answer = $cw->Dialog(
            -title          => "save model before test",
            -text           => "Save model ?",
            -buttons        => [ qw/yes no cancel/, 'show changes' ],
            -default_button => 'yes',
        )->Show;

        if ( $answer eq 'yes' ) {
            $cw->save( sub {$cw->_launch_test;});
        }
        elsif ( $answer eq 'no' ) {
            $cw->_launch_test;
        }
        elsif ( $answer =~ /show/ ) {
            $cw->show_changes( sub { $cw->test_model } );
        }
    }
    else {
        $cw->_launch_test;
    }
}
sub _launch_test {
    my $cw = shift ;

    my $testw =  $cw -> {test_widget} ;
    $testw->destroy if defined $testw and Tk::Exists($testw);

    # need to read test model from where it was written...
    my $model = Config::Model -> new(model_dir => $cw->{cm_lib_dir}) ;

    # keep a reference on this object, otherwise it will vanish at the end of this block.
    $cw->{test_model} =  $model ;

    my $name = $cw->{model_name};
    my $inst = $model->instance (root_class_name => $name,
				 instance_name => "test $name model",
				 root_dir => $cw->{root_dir} ,
				);

    my $root = $inst -> config_root ;

    $cw -> {test_widget} = $cw->ConfigModelUI (-root => $root, -quit => 'soft') ;
}

1;
