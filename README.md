hiera-file
==========

A data backend for Hiera that can return the content of whole files.

Configuration
-------------

A sample Hiera config file that activates this backend and stores data in
/etc/puppet/data can be seen below:

    ---
    :backends:
      - file

    :hierarchy:
      - %{calling_module}
      - common

    :file:
      :datadir: /etc/puppet/data

Now, consider the following puppet module:

    mymodule
    |-- README
    |-- LICENSE
    `-- manifests
        `-- init.pp

Suppose that `init.pp` has the following content:

    class mymodule {
      notify { "example": message => hiera('giant_vampire_commandos'); }
    }

For the key "giant_vampire_commandos" as specified specified in the notify
resource declared in the `mymodule` module, Hiera will check the following two
locations for data:

    /etc/puppet/data/mymodule.d/giant_vampire_commandos
    /etc/puppet/data/common.d/giant_vampire_commandos

If either of those files exists, Hiera will read it and return the unedited
contents. A typical use for this might be file resources via the content
parameter. e.g.

    file { '/tmp/very_important_file':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => hiera('giant_vampire_commandos'),
    }

Installation
------------

### Via Rubygems (preferred)

    gem install hiera-file

### With Puppet/Pluginsync

Git clone this directory into your modulepath; Puppet will pluginsync lib/
onto all your nodes.

Credits
-------

  * Hunter Haugen wrote it up ine 15 minutes and published it as a gist
  * Reid Vandewiele updated it for hiera 0.3.0 wrote the README and gemspec, and fixed the directory extension
  * Igal Koshevoy updated it for hiera 1.0 and added directory traversal prevention
  * Jonathan Kinred made it return the first value first
  * Adrien Thebo dreamed it up, got other people to write it, published it and claimed all the credit, and wrote specs
