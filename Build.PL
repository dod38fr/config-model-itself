use Module::Build;

use warnings FATAL => qw(all) ;
use strict ;

require 5.010;

# check that pod docs are up-to-date this is redundant with work done by
# dzil. But this enable to re-build the docs downstream.
# Use $^X in there as requested in 
# https://rt.cpan.org/Public/Bug/Display.html?id=74891
my $class = Module::Build->subclass(
    class => "Module::Build::Custom",
    code => <<'SUBCLASS' );

sub ACTION_build {
    my $self = shift;
    # below requires Config::Model 2.028
    system ($^X, '-MConfig::Model::Utils::GenClassPod', '-e','gen_class_pod("Itself::Model");') == 0
                    or die "gen-class-pod failed: $?";
    $self->SUPER::ACTION_build;
}
SUBCLASS

my $build = $class->new
  (
   module_name   => 'Config::Model::Itself',
   license       => 'lgpl',
   dist_author   => "Dominique Dumont (ddumont at cpan dot org)",
   dist_abstract => "Graphical editor of configuration models",

##{ $plugin->get_prereqs ##}

   add_to_cleanup => [qw/wr_test wr_root/] ,
  );


$build->add_build_element('pl');

$build->create_build_script;
