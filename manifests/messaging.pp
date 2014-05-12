#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::messaging
#
# Install Messsaging Server (RabbitMQ)
#
# === Parameters:
#
# [*rabbit_names*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to $::hostname
#
# [*rabbit_password*]
#   (optional) Password to connect to OpenStack queues.
#   Defaults to 'rabbitpassword'
#
# [*cluster_node_type*]
#   (optional) Store the queues on the disc or in the RAM.
#   Could be set to 'disk' or 'ram'.
#   Defaults to 'disc'
#
# [*ssl*]
#   (optional) Enable SSL support
#   Defaults to false
#
# [*ssl_cacert*]
#   (required with ssl) CA certificate to use for SSL support.
#
# [*ssl_cert*]
#   (required with ssl) Certificate to use for SSL support.
#
# [*ssl_key*]
#   (required with ssl) Private key to use for SSL support.
#
# [*ssl_management_port*]
#   Port to access RabbitMQ management console via SSL.
#   Default 5671
#
# [*ssl_stomp_port*]
#   STOMP protocol SSL access port.
#   Default 6164
#
class cloud::messaging(
  $cluster_node_type        = 'disc',
  $rabbit_names             = $::hostname,
  $rabbit_password          = 'rabbitpassword',
  $ssl                      = false,
  $ssl_cacert               = undef,
  $ssl_cert                 = undef,
  $ssl_key                  = undef,
  $ssl_management_port      = '5671',
  $ssl_stomp_port           = '6164',
){

  # we ensure having an array
  $array_rabbit_names = any2array($rabbit_names)

  # Packaging issue: https://bugzilla.redhat.com/show_bug.cgi?id=1033305
  if $::osfamily == 'RedHat' {
    file {'/usr/sbin/rabbitmq-plugins':
      ensure => link,
      target => '/usr/lib/rabbitmq/bin/rabbitmq-plugins'
    }

    file {'/usr/sbin/rabbitmq-env':
      ensure => link,
      target => '/usr/lib/rabbitmq/bin/rabbitmq-env'
    }
  }

  class { 'rabbitmq':
    delete_guest_user        => true,
    config_cluster           => true,
    cluster_nodes            => $array_rabbit_names,
    wipe_db_on_cookie_change => true,
    cluster_node_type        => $cluster_node_type,
    ssl                      => $ssl,
    ssl_cacert               => $ssl_cacert,
    ssl_cert                 => $ssl_cert,
    ssl_key                  => $ssl_key,
    ssl_management_port      => $ssl_management_port,
    ssl_stomp_port           => $ssl_stomp_port,
  }

  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq'],
  }
  rabbitmq_user { ['nova','glance','neutron','cinder','ceilometer','heat']:
    admin    => true,
    password => $rabbit_password,
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq']
  }
  rabbitmq_user_permissions {[
    'nova@/',
    'glance@/',
    'neutron@/',
    'cinder@/',
    'ceilometer@/',
    'heat@/',
  ]:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

}
