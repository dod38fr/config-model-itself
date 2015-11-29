
[
    {
        name => 'Itself::Application',
        # read/written by Config::Model::Itself (read_all)

        element => [
            model => {
                refer_to => '! class',
                type => 'leaf',
                value_type => 'reference',
                description => 'Top class required to configuration this application',
            },
            category => {
                choice => [
                    'system',
                    'user',
                    'application'
                ],
                type => 'leaf',
                value_type => 'enum',
                help => {
                    system => 'Configuration file is owned by root and usually located in C</etc>',
                    user => 'Configuration files is owned by user and usually located in C<~/.*>',
                    application => 'Configuration file is located anywhere and is usually explicitly '
                    .'specified to application. E.g. C<multistrap -f CONFIG_FILE>',
                }
            },
            allow_config_file_override => {
                type => 'leaf',
                upstream_default => '0',
                value_type => 'boolean',
                description => 'Set if user can override the configuration file loaded by default by cme',
            },
            require_config_file => {
                type => 'leaf',
                upstream_default => '0',
                value_type => 'boolean',
                description => "set when there's no default path for the configuration file."
                . "user will have to specify a configuration file with C<--file> option."
            }
        ],
    }
] ;

