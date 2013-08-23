
[
    [
        name => "Itself::WarpRule",

        class_description =>
          'Specify one condition and one effect to be applied on the warped object',

        'element' => [

            'condition' => {
                type       => 'leaf',
                value_type => 'string',
                mandatory  => 1,
                description =>
                  'Perl code snippet that will be eval\'ed to check whether the warp rule '
                  . 'will apply. This snippet must end with a boolean value. This expression should use '
                  . 'variables defined with the "follow" parameter. Example \'$m1 eq "A" && $m2 eq "C"\'.'
                  . 'For more details, see L<Config::Model::Warper/"Warp rules argument"> ',
            },

            'effect' => {
                type              => 'node',
                config_class_name => 'Itself::WarpOnlyElement',
                description => 
                    'Specified the property changes to be applied when the '
                    . 'associated condition is true. '
                    . 'For more details, see L<Config::Model::Warper/"Warp rules argument"> ',
            },
        ],

    ],

];
