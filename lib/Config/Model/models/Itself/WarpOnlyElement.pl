use strict;
use warnings;

return [
  [
   name => "Itself::WarpOnlyElement",

   include => 'Itself::WarpableElement' ,

   'element' 
   => [

       'level' 
       => {
	   type => 'leaf',
	   value_type => 'enum', 
	   choice => [qw/important normal hidden/] ,
	  },

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

      ],

   'description' 
   => [
       level => 'Used to highlight important parameter or to hide others. Hidden parameter are mostly used to hide features that are unavailable at start time. They can be made available later using warp mechanism',
      ],
  ],

];
