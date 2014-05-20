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
#
# == Class: cloud::volume
#
# Common class for volume nodes
#
# === Parameters:
#
# [*cinder_db_host*]
#   (optional) Cinder database host
#   Defaults to '127.0.0.1'
#
# [*cinder_db_user*]
#   (optional) Cinder database user
#   Defaults to 'cinder'
#
# [*cinder_db_password*]
#   (optional) Cinder database password
#   Defaults to 'cinderpassword'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to cinder queues.
#   Defaults to 'rabbitpassword'
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to false
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to 'SSLv3'
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
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
class cloud::volume(
  $cinder_db_host            = '127.0.0.1',
  $cinder_db_user            = 'cinder',
  $cinder_db_password        = 'cinderpassword',
  $rabbit_hosts              = ['127.0.0.1:5672'],
  $rabbit_password           = 'rabbitpassword',
  $rabbit_use_ssl            = false,
  $kombu_ssl_ca_certs        = undef,
  $kombu_ssl_certfile        = undef,
  $kombu_ssl_keyfile         = undef,
  $kombu_ssl_version         = 'SSLv3',
  $verbose                   = true,
  $debug                     = true,
  $log_facility              = 'LOG_LOCAL0',
  $storage_availability_zone = 'nova',
  $use_syslog                = true,
  $ssl                       = false,
  $ssl_cacert                = false,
  $ssl_cert                  = false,
  $ssl_key                   = false,
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
  } else {
    $log_dir = '/var/log/cinder'
  }

  $encoded_user = uriescape($cinder_db_user)
  $encoded_password = uriescape($cinder_db_password)


  class { 'cinder':
    sql_connection      => "mysql://${encoded_user}:${encoded_password}@${cinder_db_host}/cinder?charset=utf8",
    rabbit_userid       => 'cinder',
    rabbit_hosts        => $rabbit_hosts,
    rabbit_password     => $rabbit_password,
    rabbit_virtual_host => '/',
    rabbit_use_ssl      => $rabbit_use_ssl,
    kombu_ssl_ca_certs  => $kombu_ssl_ca_certs,
    kombu_ssl_certfile  => $kombu_ssl_certfile,
    kombu_ssl_keyfile   => $kombu_ssl_keyfile,
    kombu_ssl_version   => $kombu_ssl_version,
    verbose             => $verbose,
    debug               => $debug,
    log_dir             => $log_dir,
    log_facility        => $log_facility,
    use_syslog          => $use_syslog,
    use_ssl             => $ssl,
    ca_file             => $ssl_cacert,
    cert_file           => $ssl_cert,
    key_file            => $ssl_key,
    # https://review.openstack.org/#/c/92993/
    # storage_availability_zone => $storage_availability_zone
  }

  cinder_config {
    'DEFAULT/storage_availability_zone': value => $storage_availability_zone
  }

  class { 'cinder::ceilometer': }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Cinder DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Gonéri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'cinder_db_sync':
    command => 'cinder-manage db sync',
    path    => '/usr/bin',
    user    => 'cinder',
    unless  => "/usr/bin/mysql cinder -h ${cinder_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

}
