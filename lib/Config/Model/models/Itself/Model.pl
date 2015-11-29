
[
    [
        name => "Itself::Model",

        element => [
            class => {
                type => 'hash',
                index_type => 'string' ,
                ordered => 1,
                cargo => {
                    type => 'node',
                    config_class_name => 'Itself::Class' ,
                },
            },
            application => {
                type => 'hash',
                index_type => 'string',
                cargo => {
                    type => 'node',
                    config_class_name => 'Itself::Application',
                },
            },
        ],

        description => [
            class  => 'A configuration model is made of several configuration classes.',
        ],
    ],
];
