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
# [*checks*]
#   (optionnal) Hash of checks and their respective options
#   Defaults to {}.
#
# [*handlers*]
#   (optionnal) Hash of handlers and their respective options
#   Defaults to {}.
#
# [*proxy_dashboard*]
#   (optional) Should an apache proxy should be put in front of
#   the dashboard
#   Defaults to false
#
# [*dashboard_servername*]
#   (optional) Servername to bind the sensu-dashboard to
#   Valid only if proxy dashboard is set to true
#   Defaults to 'monitor.example.com'
#
# [*vhost_configuration*]
#   (optional) Hash of settings to apply to the vhost
#   Valid only if proxy dashboard is set to true
#   Defaults to {}
#
# [*manage_rabbitmq*]
#   (optionnal) Should the sensu installation manage its own rabbitmq-server
#   Defauls to false
#
# [*rabbitmq_user*]
#   (optionnal) Rabbitmq user
#   Defauls to sensu
#
# [*rabbitmq_password*]
#   Rabbitmq_password
#   Defauls to undef
#
# [*rabbitmq_vhost*]
#   (optionnal) Rabbitmq vhost
#   Defauls to /sensu
#
# [*rabbitmq_user_permissions*]
#   (optionnal) Hash describing rabbitmq user permissions
#   Defauls to {'read_permission' => '.*', 'write_permission' => '.*', 'configure_permission' => '.*'}
#
# [*manage_redis*]
#   (optionnal) Should the sensu installation manage its own redis-server
#   Defauls to true
#

class cloud::monitoring::server::sensu (
  $checks                    = {},
  $handlers                  = {},
  $proxy_dashboard           = false,
  $dashboard_servername      = 'monitor.example.com',
  $vhost_configuration       = {},
  $manage_rabbitmq           = false,
  $rabbitmq_user             = 'sensu',
  $rabbitmq_password         = undef,
  $rabbitmq_vhost            = '/sensu',
  $rabbitmq_user_permissions = {'read_permission' => '.*', 'write_permission' => '.*', 'configure_permission' => '.*'},
  $manage_redis              = true,
) {

  # TODO (spredzy): Find a nicer way to deal with dependencies
  Service['rabbitmq-server'] -> Class['sensu::package']
  Service['redis-6379'] -> Service['sensu-api'] -> Service['sensu-server']

  include cloud::monitoring::agent::sensu

  $user_permissions = hash("${rabbitmq_user}@${rabbitmq_vhost}", $rabbitmq_user_permissions)
  $vhost = hash($dashboard_servername, $vhost_configuration)

  if $manage_redis {
    include redis
  }

  if $manage_rabbitmq {
    include rabbitmq

    rabbitmq_user { $rabbitmq_user :
      password => $rabbitmq_password,
      require  => Class['rabbitmq'],
    }
    rabbitmq_vhost { $rabbitmq_vhost :
      ensure  => present,
      require => Class['rabbitmq'],
    }

    create_resources('rabbitmq_user_permissions', $user_permissions)
  }

  if $proxy_dashboard {
    include apache
    create_resources('apache::vhost', $vhost)
  }

  create_resources('sensu::check', $checks)
  create_resources('sensu::handler', $handlers)

}
