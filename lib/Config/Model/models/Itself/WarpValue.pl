
[
  [
   name => "Itself::WarpValue",

   class_description => 'Warp functionality enable a Value object to change its properties (i.e. default value or its type) dynamically according to the value of another Value object locate elsewhere in the configuration tree.',

   'element' 
   => [
       'follow' 
       => {
	   type => 'hash',
	   index_type =>'string',
	   cargo => { type => 'leaf', value_type => 'uniline' } ,
	   description => 'Specify with a path the configuration element that will drive the warp , i.e .the elements that control the property change. These a specified using a variable name (used in the "rules" formula) and a path to fetch the actual value. Example $country => " ! country"',
	  },
       'rules' => {
		   type => 'hash',
		   ordered => 1,
		   index_type => 'string',
		   cargo => { type => 'node',
			      config_class_name => 'Itself::WarpOnlyElement' ,
			    },
		   description => 'Specify several test (as formula using the variables defined in "follow" element) to try in sequences and their associated effects',
		  },
      ],
  ],
];
