
[
    {
        name => 'Itself::Application',
        # read/written by Config::Model::Itself (read_all)

        element => [
            model => {
                refer_to => '! class',
                type => 'leaf',
                value_type => 'reference'
            },
            category => {
                choice => [
                    'system',
                    'user',
                    'application'
                ],
                type => 'leaf',
                value_type => 'enum'
            },
            allow_config_file_override => {
                type => 'leaf',
                upstream_default => '0',
                value_type => 'boolean'
            },
            require_config_file => {
                type => 'leaf',
                upstream_default => '0',
                value_type => 'boolean'
            }
        ],
    }
] ;

