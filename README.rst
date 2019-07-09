========
g-server
========

Bits and pieces to configure base of your servers in opinionated way with power of Puppet.

When submodule codebase size exceeds common sense it will be moved to its own puppet module.

--------
Features
--------

Interface Sides
===============

You can specify which interfaces are external and which internal.

Other modules/classes can use this information to eg. listen on only some interfaces or create firewall rules.

Configurable as ``g_server`` parameters.

Usage:

.. code-block:: puppet

  g_server::get_interfaces($side).each | $iface | { }
  g_server::get_side($iface) # => one of G_server::Side

-------
Classes
-------

Accounts
========

- Handles root account password and its ssh keys
- Marks admin users to allow ``sudo`` usage
- Creates user accounts and sets ssh keys

Hiera usage
-----------

.. code-block:: yaml

   g_server::accounts::root_password_hash: "$6$9OBVSpVQDgHsldz8$BmiwDh3XGC4qgDL/Qdh5DQPhJ4haNqBvB1KV0BqZwA4w8ZEr3ljcE9YmcVvtkxXqb4uMtl4V3Gk7n0vI2T2NH0"
   
   g_server::accounts::users:
     glorpen:
       ssh_authorized_keys:
         "example.glorpen": "<ssh pub key>"
       admin: true


Cron
====

Simple cron job wrapper.

- Setting environment variables
- Uses ``::cron::job``
- Allows using templates with custom variables

Hiera usage
-----------

.. code-block:: yaml

   g_server::cron::jobs:
     "example-job":
       minute: "0"
       hour: "10" # "*/5", "1-5", ...
       template_source: "example/job-example.sh.epp"
       #template_content: "puppet://..."
       vars:
         var1: "example"

Firewall
========

Setups base rules for firewall.

See ``glorpen/g_firewall`` for more.

Network
=======

- Supports differnating between external and internal facing interfaces
- Sets internal host names
- Supports creating macvlan interfaces
- Sets hostname
- Allows setting routes, dns, dhcp, gateway, mac per interface
- Supports IPv6

Hiera usage
-----------

.. code-block:: yaml

   g_server::network::interfaces:
     eth0:
       ipv4addr: "192.168.1.12"
       ipv4netmask: "255.255.255.0"
       ipv4gw: "192.168.1.1"
       nameservers:
         - "8.8.8.8"

Repos
=====

Configures package manager and installs Puppet repository.

Base Services
=============

Setups base services.

SSH
---

- sets up to date ciphers
- creates ssh users group
- sets host keys
- configures firewall (supports _`Interface Sides`)

Fail2Ban
--------

Basic fail2ban configuration.

Volumes
=======

Manages LVM volumes, mountpoints and filesystems.

Supports managing:

- volume groups
- logical volumes
- thin pools
- thin provisioned volumes
- filesystems with options
- mountpoints (with chmod/chown)
- lvm raids

Hiera usage
-----------

.. code-block:: yaml

   g_server::volumes::groups:
     "example0":
       devices:
         - /dev/sda2
       volumes:
         root:
           mountpoint: /
           size: 10G
           mount_options: errors=remount-ro,noatime,nodiratime
           pass: 1
         other:
           mountpoint: /example
           size: 1G
