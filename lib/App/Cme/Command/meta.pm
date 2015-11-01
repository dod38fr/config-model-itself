# ABSTRACT: Edit the configuration of an application

package App::Cme::Command::meta ;

use strict ;
use warnings ;
use 5.10.1;

use App::Cme -command ;

use base qw/App::Cme::Common/;

use Config::Model;

use Config::Model::Itself ;
use YAML::Tiny;

use Tk ;
use Config::Model::TkUI ;
use Config::Model::Itself::TkEditUI ;
use Path::Tiny ;

my %meta_cmd = (
    dump => \&dump_cds,
    'dump-yaml' => \&dump_yaml,
    'gen-dot' => \&gen_dot,
    edit => \&edit,
    save => \&save,
    plugin => \&plugin,
);

sub validate_args {
    my ($self, $opt, $args) = @_;

    my $mc = $opt->{'_meta_command'} = shift @$args  || die "please specify meta sub command\n";

    if (not $meta_cmd{$mc}) {
        die "Unexpected meta sub command: '$mc'. Expected ".join(' ', sort keys %meta_cmd)."\n";
    }

    $opt->{'try_application_as_model'} = 1;
    $self->process_args($opt,$args);
}

sub opt_spec {
    my ( $class, $app ) = @_;

    return (
		[
            "dir=s"         => "directory where to read and write a model",
            {default => 'lib/Config/Model/models'}
        ],
        [
            "dumptype=s" => "dump every values (full), only preset values "
            . "or only customized values (default)",
            {callbacks => { 'expected values' => sub { $_[0] =~ m/^full|preset|custom$/ ; }}}
        ],
		[ "open-item=s"   => "force the UI to open the specified node"],
		[ "plugin-file=s" => "create a model plugin in this file" ],
        [ "load-yaml=s"   => "load model from YAML file" ],
        [ "load=s"        => "load model from cds file (Config::Model serialisation file)"],
        [ "system!"       => "read model from system files" ],
        $class->cme_global_options()
    );
}

sub usage_desc {
  my ($self) = @_;
  my $desc = $self->SUPER::usage_desc; # "%c COMMAND %o"
  return "$desc [ edit | gendot | dump | yaml ] your_model_class ";
}

sub description {
    my ($self) = @_;
    return $self->get_documentation;
}

sub read_data {
    my $load_file = shift ;

    my @data ;
    if ( $load_file eq '-' ) {
        @data = <STDIN> ;
    }
    else {
        open(LOAD,$load_file) || die "cannot open load file $load_file:$!";
        @data = <LOAD> ;
        close LOAD;
    }

    return wantarray ? @data : join('',@data);
}

sub load_optional_data {
    my ($self, $args, $opt, $root_model, $meta_root) = @_;

    if (defined $opt->{load}) {
        my $data = read_data($opt->{load}) ;
        $data = qq(class:"$root_model" ).$data unless $data =~ /^\s*class:/ ;
        $meta_root->load($data);
    }

    if (defined $opt->{'load-yaml'}) {
        my $yaml = read_data($opt->{'load-yaml'}) ;
        my $pdata = Load($yaml) ;
        $meta_root->load_data($pdata) ;
    }

    if (@$args) {
        my $data = join(' ',@$args) ;
        $data = qq(class:"$root_model" ).$data unless $data =~ /^\s*class:/ ;
        $meta_root->load($data) ;
    }
}

sub load_meta_model {
    my ($self, $opt, $args) = @_;

    my $root_model = $opt->{_root_model};
    my $model_dir = path(split m!/!, $opt->{dir}) ;

    if (! $model_dir->is_dir) {
        $model_dir->mkpath(0, 0755) || die "can't create $model_dir:$!";
    }

    my $meta_model = $self->{meta_model} = Config::Model -> new();

    my $meta_inst = $meta_model->instance(
        root_class_name => 'Itself::Model',
        instance_name   => $root_model . ' model',
        check           => $opt->{'force-load'} ? 'no' : 'yes',
    );

    my $meta_root = $meta_inst -> config_root ;

    my $system_model_dir = $INC{'Config/Model.pm'} ;
    $system_model_dir =~ s/\.pm//;
    $system_model_dir .= '/models' ;

    return ($meta_inst, $meta_root, $model_dir, $system_model_dir);
}

sub load_meta_root {
    my ($self, $opt, $args) = @_;

    my ($meta_inst, $meta_root, $model_dir, $system_model_dir) = $self->load_meta_model($opt,$args);

    my $root_model = $opt->{_root_model};
    my $meta_model_dir = $opt->{system} ? $system_model_dir
                       :                  $model_dir->canonpath ;

    say "Reading model from $meta_model_dir" if $opt->system();

    # now load model
    my $rw_obj = Config::Model::Itself -> new(
        model_object => $meta_root,
        model_dir    => $meta_model_dir,
    ) ;

    $meta_inst->initial_load_start ;

    $rw_obj->read_all(
        force_load => $opt->{'force-load'},
        root_model => $root_model,
        # legacy     => 'ignore',
    );

    $meta_inst->initial_load_stop ;

    $self->load_optional_data($args, $opt, $root_model, $meta_root) ;

    my $write_sub = sub {
            my $wr_dir = shift || $model_dir ;
            $rw_obj->write_all( );
        } ;

    return ($rw_obj, $model_dir, $meta_root, $root_model, $write_sub);
}

sub load_meta_plugin {
    my ($self, $opt, $args) = @_;

    my ($meta_inst, $meta_root, $model_dir, $system_model_dir) = $self->load_meta_model($opt,$args);

    my $root_model = $opt->{_root_model};
    my $meta_model_dir = $system_model_dir ;
    my $plugin_file = shift @$args or die "missing plugin file";

    # now load model
    my $rw_obj = Config::Model::Itself -> new(
        model_object => $meta_root,
        model_dir    => $meta_model_dir,
    ) ;

    $meta_inst->initial_load_start ;
    $meta_inst->layered_start;

    $rw_obj->read_all(
        force_load => $opt->{'force-load'},
        root_model => $root_model,
        # legacy     => 'ignore',
    );

    $meta_inst->layered_stop;

    # load any existing plugin file
    $rw_obj->read_model_snippet(snippet_dir => $model_dir, model_file => $plugin_file) ;

    $meta_inst->initial_load_stop ;

    $self->load_optional_data($args, $opt, $root_model, $meta_root) ;

    my $write_sub = sub {
            $rw_obj->write_model_snippet(
                snippet_dir => $model_dir,
                model_file => $opt->{'plugin_file'}
            );
        } ;

    return ($rw_obj, $model_dir, $meta_root, $root_model, $write_sub);
}

sub execute {
    my ($self, $opt, $args) = @_;

    # how to specify root-model when starting from scratch ?
    # ask question and fill application file ?

    my $root_model = $opt->{_root_model};
    say "Running ",$opt->{_meta_command}, " on $root_model";

    my $cmd_sub = $meta_cmd{$opt->{_meta_command}};

    $self->$cmd_sub($opt, $args);
}

sub save {
    my ($self, $opt, $args) = @_;
    my ($rw_obj, $model_dir, $meta_root, $root_model, $write_sub) = $self->load_meta_root($opt, $args) ;

    &$write_sub;
}

sub gen_dot {
    my ($self, $opt, $args) = @_;
    my ($rw_obj, $model_dir, $meta_root, $root_model, $write_sub) = $self->load_meta_root($opt, $args) ;

    print $rw_obj->get_dot_diagram ;
}

sub dump_cds {
    my ($self, $opt, $args) = @_;
    my ($rw_obj, $model_dir, $meta_root, $root_model, $write_sub) = $self->load_meta_root($opt, $args) ;

    say "running dump_cds";
    my $dump_file = shift @$args;

    my $dump_string = $meta_root->dump_tree( mode => $opt->{dumptype} || 'custom' ) ;

    if ($dump_file) {
        open(DUMP,">$dump_file") or die "cannot dump in $dump_file:$!";
        print DUMP $dump_string ;
        close DUMP;
    }
    else {
        print $dump_string ;
    }
}

sub dump_yaml{
    my ($self, $opt, $args) = @_;
    my ($rw_obj, $model_dir, $meta_root, $root_model, $write_sub) = $self->load_meta_model($opt, $args) ;

    require YAML::Tiny;
    import YAML::Tiny qw/Dump/;
    print Dump($meta_root->dump_as_data(ordered_hash_as_list => 0)) ;

}

sub plugin {
    my ($self, $opt, $args) = @_;
    my @info = $self->load_meta_plugin($opt, $args) ;
    $self->_edit($opt, $args, @info);
}

sub edit {
    my ($self, $opt, $args) = @_;
    my @info = $self->load_meta_root($opt, $args) ;
    $self->_edit($opt, $args, @info);
}

sub _edit {
    my ($self, $opt, $args, $rw_obj, $model_dir, $meta_root, $root_model, $write_sub) = @_;

    my $mw = MainWindow-> new;

    $mw->withdraw ;
    # Thanks to Jerome Quelin for the tip
    $mw->optionAdd('*BorderWidth' => 1);

    my $cmu = $mw->ConfigModelEditUI(
        -root       => $meta_root,
        -store_sub  => $write_sub,
        -model_name => $root_model,
    );

    my $open_item = $opt->{'open-item'};
    if (not $meta_root->fetch_element('class')->fetch_size) {
        $open_item ||=  qq(class:"$root_model" );
    }
    else {
        $open_item ||= 'class';
    }

    if ($open_item) {
        my $obj = $meta_root->grab($open_item) ;
        $cmu->after(10, sub { $cmu->force_element_display($obj) });
    }

    &MainLoop ; # Tk's

}

1;

__END__

=head1 SYNOPSIS

  # edit meta model
  cme meta [ options ] edit Sshd

  # plugin mode
  cme meta [options] edit Debian::Dpkg -plugin-file dpkg-snippet.pl

=head1 DESCRIPTION

config-model-edit will provides a Perl/Tk graphical interface to edit
configuration models that will be used by Config::Model.

Config::Model is a general purpose configuration framework based on
configuration models (See L<Config::Model> for details).

This configuration model is also expressed as structured data. This
structure data is structured and follow a set of rules which are
described for humans in L<Config::Model>.

The structure and rules documented in L<Config::Model> are also expressed
in a model in the files provided with L<Config::Model::Itself>.

Hence the possibity to verify, modify configuration data provided by
Config::Model can also be applied on configuration models using the
same user interface as L<config-edit>.

The model editor program is config-model-edit.

=head1 USAGE

C<config-model-edit> will read and write model file from
C<./lib/Config/Model/models>.

When you specify a C<-model> options, only configuration models matching
this options will be loaded. I.e.

  config-model-edit -model Xorg

will load models C<Xorg> (file C<Xorg.pl>) and all other C<Xorg::*> like
C<Xorg::Screen> (file C<Xorg/Screen.pl>).

=head1 Options

=over

=item -model

Mandatory option that specifies the configuration model to be
edited.

=item -plugin-file foo.pl

this option can be used to create model plugins. A model plugin is an addendum to
an existing model. The resulting file will be saved in a C<.d> directory besides the
original file to be taken into account.

For instance:

 $ config-model-edit -model Debian::Dpkg -plugin-file my-plugin.pl
 # perform additions to Debian::Dpkg and Debian::Dpkg::Control::Source and save
 $ find lib -name my-plugin.pl
 lib/Config/Model/models/Debian/Dpkg.d/my-plugin.pl
 lib/Config/Model/models/Debian/Dpkg/Control/Source.d/my-plugin.pl

=item system

Read model from system files, i.e. from installed files, not from
C<./lib> directory.

=item -trace

Provides a full stack trace when exiting on error.

=item -force-load

Load file even if error are found in data. Bad data are loaded, but should be cleaned up
before saving the model. See menu C<< File -> check >> in the GUI.

=item -dot-diagram

Returns a dot file that represent the stucture of the configuration
model. C<include> are represented by solid lines. Class usage
(i.e. C<config_class_name> parameter) is represented by dashed
lines. The name of the element is attached to the dashed line.

=item -dump [ file ]

Dump configuration content on STDOUT or in the specified with
Config::Model syntax.

By default, dump only custom values, i.e. different from application
built-in values or model default values. See -dumptype option for
other types of dump

=item -dumptype [ full | preset | custom ]

Choose to dump every values (full), only preset values or only
customized values (default)

=item -load <cds_file_to_load> | -

Load model from cds file (using Config::Model serialisation format,
typically done with -dump option). This option can be used with
C<-save> to directly save a model loaded from the cds file or from
STDIN.

=item -load-yaml <yaml_file_to_load> | -

Load configuration data in model from YAML file. This
option can be used with C<-save> to directly save a model loaded from
the YAML file or from STDIN.

=item -dump_yaml

Dump a model in YAML format

=item -save

Force a save of the model even if no edition was done. This option is
useful to migrate a model when Config::Model model feature changes.

=item -dir

Directory where to read and write model

=item -open-item 'path'

In graphical mode, force the UI to open the specified node. E.g.

 -open_item 'class:Fstab::FsLine element:fs_mntopts rules'

=back

=head1 LOGGING

All Config::Model logging was moved from klunky debug and
verbose prints to L<Log::Log4perl>. Logging can be configured in the
following files:

=over

=item *

 ~/.log4config-model

=item *

 /etc/log4config-model.conf

=back

Without these files, the following Log4perl config is used:

 log4perl.logger=WARN, Screen
 log4perl.appender.Screen        = Log::Log4perl::Appender::Screen
 log4perl.appender.Screen.stderr = 0
 log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
 log4perl.appender.Screen.layout.ConversionPattern = %d %m %n

Log4Perl categories are shown in L<config-edit/LOGGING>

=head1 AUTHOR

Dominique Dumont, ddumont at cpan dot org

=head1 SEE ALSO

L<Config::Model>,
L<Config::Model::Node>,
L<Config::Model::Instance>,
L<Config::Model::HashId>,
L<Config::Model::ListId>,
L<Config::Model::WarpedNode>,
L<Config::Model::Value>

=cut
