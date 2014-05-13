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
# == Class: cloud::telemetry
#
# Common telemetry class, used by Controller, Storage,
# Network and Compute nodes
#
# === Parameters:
#
# [*ceilometer_secret*]
#   Secret key for signing messages.
#   Defaults to 'ceilometersecret'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
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
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_public_host*]
#   (optional) Public Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_ceilometer_password*]
#   (optional) Password used by Ceilometer to connect to Keystone API
#   Defaults to 'ceilometerpassword'
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
# [*region*]
#   (optional) the keystone region of this node
#   Defaults to 'RegionOne'
#
# [*ssl_cacert*]
#   (optional) Certificate chain for SSL validation
#
class cloud::telemetry(
  $ceilometer_secret          = 'ceilometersecret',
  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword' ,
  $rabbit_use_ssl             = false,
  $kombu_ssl_ca_certs         = undef,
  $kombu_ssl_certfile         = undef,
  $kombu_ssl_keyfile          = undef,
  $kombu_ssl_version          = 'SSLv3',
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $ks_ceilometer_password     = 'ceilometerpassword',
  $region                     = 'RegionOne',
  $verbose                    = true,
  $debug                      = true,
  $log_facility               = 'LOG_LOCAL0',
  $use_syslog                 = true,
  $ssl_cacert                 = undef,
){

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
  } else {
    $log_dir = '/var/log/ceilometer'
  }

  class { 'ceilometer':
    metering_secret    => $ceilometer_secret,
    rabbit_hosts       => $rabbit_hosts,
    rabbit_password    => $rabbit_password,
    rabbit_userid      => 'ceilometer',
    verbose            => $verbose,
    debug              => $debug,
    log_dir            => $log_dir,
    use_syslog         => $use_syslog,
    log_facility       => $log_facility,
    rabbit_use_ssl     => $rabbit_use_ssl,
    kombu_ssl_ca_certs => $kombu_ssl_ca_certs,
    kombu_ssl_certfile => $kombu_ssl_certfile,
    kombu_ssl_keyfile  => $kombu_ssl_keyfile,
    kombu_ssl_version  => $kombu_ssl_version,
  }

  class { 'ceilometer::agent::auth':
    auth_url      => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    auth_password => $ks_ceilometer_password,
    auth_region   => $region,
    auth_cacert   => $ssl_cacert,
  }

}
