use strict;
use warnings;

# This class is trashed during tests

return [
    [
        name    => "MasterModel::ToTrash",
        element => [
            [qw/my_hash my_hash2 my_hash3/] => {
                type       => 'hash',
                index_type => 'string',
                cargo_type => 'leaf',
                cargo_args => { value_type => 'string' },
            },

        ]
    ]
];
