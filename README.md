What
====

A data backend for Hiera that can return the content of whole files.

Configuration
=============

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
