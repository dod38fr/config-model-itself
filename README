
Config::Model::Itself - Model editor for Config::Model 

This module provides a graphical editor to edit configuration model
for Config:Model. 

This modules also provides a model for Config::Model (hence the Itself
name, you can also think of it as a meta-model).  The editor will use
this meta-model to construct the graphical interface so you can edit
the configuration model for *your* application. [ This module is the
"eat your own dog food" principle applied to Config::Model ;-) ]

Let's step back a little to explain. Any configuration data is, in
essence, structured data. This data could be stored in an XML file. A
configuration model is a way to describe the structure and relation of
all items of a configuration data set.

This configuration model is also expressed as structured data. This
structure data is structured and follow a set of rules which are
described for humans in Config::Model.

The structure and rules documented in Config::Model are also expressed
in a model in the files provided with Config::Model::Itself.

Hence the possibity to verify, modify configuration data provided by
Config::Model can also be applied on configuration models. Using the
same user interface.

The model editor is launched by "cme meta edit"

Since the model editor and the configuration data editor are based on
the same graphical module, you will use similar UIs to edit
configuration data (for instance OpenSsh configuration data from
sshd_config) and OpenSsh model (if you need to add new parameters in
OpenSsh model)

Once this module is installed, you can run "cme meta edit" in an empty
directory to create you own model.

You can also start from an existing model. Clone from github a model
(like config-model-openssh), jump in the cloned directory and run
"cme meta edit"

You can also peek in an installed model. For instance, if you have installed
Config::Model::OpenSsh, you can run

  # cme meta edit sshd -system

Note that "save" menu will save the model in current directory.

---------------------------------------------------------------------
INSTALLATION

On debian/ubuntu:

  apt-get install libconfig-model-itself-perl

Otherwise:

  cpanm Config::Model::Itself
