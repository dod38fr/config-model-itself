# $Author: ddumont $
# $Date: 2008-04-11 18:20:21 +0200 (ven, 11 avr 2008) $
# $Revision: 600 $

#    Copyright (c) 2007-2008 Dominique Dumont.
#
#    This file is part of Config-Model-Itself.
#
#    Config-Model-Itself is free software; you can redistribute it
#    and/or modify it under the terms of the GNU Lesser Public License
#    as published by the Free Software Foundation; either version 2.1
#    of the License, or (at your option) any later version.
#
#    Config-Model-Itself is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied
#    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU Lesser Public License for more details.
#
#    You should have received a copy of the GNU Lesser Public License
#    along with Config-Model-Itself; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA

[
 [
  name => 'Itself::CommonElement',

  # warp often depend on this one, so list it first
  'element'
  => [

      'description' 
      => {
	  type => 'leaf',
	  value_type => 'string', 
	 },

       'mandatory'
       => { type => 'leaf',
	    value_type => 'boolean',
	    level => 'hidden',
	    warp => { follow => '?type',
		     'rules'
		      => { 'leaf' => {
				      built_in   => 0,
				      level => 'normal',
				     }
			 }
		    }
	  },
      # node element (may be within a hash or list)

       'config_class_name'
       => {
	   type => 'leaf',
	   level => 'hidden',
	   value_type => 'reference', 
	   refer_to => '! class',
	   warp => {  follow => { t => '?type' },
		      rules  => [ '  $t  eq "node" or $t  eq "warped_node" '
				  => { 
				       # should be able to warp refer_to ??
				       level => 'normal',
				     },
				]
		   }
	  },

      # warped_node: warp parameter for warped_node. They must be
      # warped out when type is not a warped_node

      # end warp elements for warped_node

      # leaf element

       'choice'
       => { type => 'list',
	    level => 'hidden',
	    warp => { follow => { t  => '?type',
				  vt => '?value_type',
				},
		      'rules'
		      => [ '  ($t eq "leaf" and $vt eq "enum" )
                            or $t eq "check_list"' 
			   => {
			       level => 'normal',
			      } ,
			 ]
		    },
	    cargo => { type => 'leaf', value_type => 'uniline'},
	  },

       [qw/min max/]
       => { type => 'leaf',
	    value_type => 'integer',
	    level => 'hidden',
	    warp => { follow => {
				 'type'  => '?type',
				 'vtype' => '?value_type' ,
				},
		     'rules'
		      => [ '$type eq "hash"
                            or
                            (    $type eq "leaf" 
                             and (    $vtype eq "integer" 
                                   or $vtype eq "number" 
                                 )
                            ) '
			   => {
			       level => 'normal',
			      }
			 ]
		    }
	  },

       [qw/default built_in/] 
       => { type => 'leaf',
	    level => 'hidden',
	    value_type => 'uniline',
	    warp => {  follow => { 't' => '?type' },
		       'rules'
		       => [ '$t eq "leaf"' 
			    => {
				level => 'normal',
			       }
			  ]
		    }
	  },
 
       [qw/convert/] 
       => { type => 'leaf',
	    value_type => 'enum',
	    level => 'hidden',
	    warp => {  follow => { 't' => '?type'},
		       'rules'
		       => [ '$t eq "leaf"'
			    => {
				choice => [qw/uc lc/],
				level => 'normal',
			       }
			  ]
		    }
	  },


       [qw/default_list/] 
       => { type => 'check_list',
	    level => 'hidden',
	    refer_to => '- choice',
	    warp => { follow => { t => '?type' },
		      'rules'
		      => [ '$t eq "check_list"' 
			   => {
			       level => 'normal',
			      } ,
			 ]
		    },
	  },

      # hash element

      'index_type' 
      => { type => 'leaf',
	   value_type => 'enum',
	   level      => 'hidden' ,
	   warp => { follow => '?type',
		     'rules'
		     => { 'hash' => {
				     level => 'important',
				     #mandatory => 1,
				     choice => [qw/string integer/] ,
				    }
			}
		   },
	   description => 'Specify the type of allowed index for the hash. "String" means no restriction.',
	 },

      # list element


     ],
   'description' 
   => [
       value_type => 'specify the type of a leaf element.',
       default => 'Specify default value. This default value will be written in the configuration data',
       built_in => 'Another way to specify a default value. But this default value is considered as "built_in" the application and is not written in the configuration data (unless modified)',
       convert => 'When stored, the value will be converted to uppercase (uc) or lowercase (lc).',
       choice => 'Specify the possible values',
       default_list => 'Specify items checked by default',
       help => 'Specify help string specific to possible values. E.g for "light" value, you could write " red => \'stop\', green => \'walk\' ',
       replace => 'Used for enum to substitute one value with another. This parameter must be used to enable user to upgrade a configuration with obsolete values. The old value is the key of the hash, the new one is the value of the hash',
      ],
 ],
];