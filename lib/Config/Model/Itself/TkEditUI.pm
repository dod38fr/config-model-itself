# $Author: ddumont $
# $Date: 2008-04-17 15:38:28 +0200 (Thu, 17 Apr 2008) $
# $Revision: 615 $

#    Copyright (c) 2008 Dominique Dumont.
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
use vars qw/$VERSION/ ;

$VERSION = sprintf "1.%04d", q$Revision: 615 $ =~ /(\d+)/;

Construct Tk::Widget 'ConfigModelEditUI';

sub ClassInit {
    my ($class, $mw) = @_;
    # ClassInit is often used to define bindings and/or other
    # resources shared by all instances, e.g., images.


    # cw->Advertise(name=>$widget);
}

sub Populate { 
    my ($cw, $args) = @_;


    my $model_dir  = delete $args->{-model_dir} ;
    my $model_name = delete $args->{-model_name} ;

    $cw->SUPER::Populate($args) ;

    my $items = [[ qw/command test -command/, sub{ $cw->test_model }],
		] ;

    my $model_menu = $cw->{my_menu}->cascade(-label => 'Model', -menuitems => $items) ;
    $cw->{model_dir} = $model_dir ;
    $cw->{model_name} = $model_name ;
}

sub test_model {
    my $cw = shift ;

    my $testw =  $cw -> {test_widget} ;
    $testw->destroy if defined $testw ;

    my $model = Config::Model -> new(model_dir => $cw->{model_dir}) ;

    my $name = $cw->{model_name};
    my $inst = $model->instance (root_class_name => $name,
				 instance_name => "test $name model");

    my $root = $inst -> config_root ;

    $cw -> {test_widget} = $cw->ConfigModelUI (-root => $root, -quit => 'soft') ;
}

1;