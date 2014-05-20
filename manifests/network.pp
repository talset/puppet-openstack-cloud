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
# == Class: cloud::network
#
# Common class for network nodes
#
# === Parameters:
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
# [*verbose*]
#   (optional) Set log output to verbose output
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*tunnel_eth*]
#   (optional) Which interface we connect to create overlay tunnels.
#   Defaults to '127.0.0.1'
#
# [*provider_vlan_ranges*]
#   (optionnal) VLAN range for provider networks
#   Defaults to ['physnet1:1000:2999']
#
# [*provider_bridge_mappings*]
#   (optionnal) Bridge mapping for provider networks
#   Defaults to ['physnet1:br-eth1']
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
#
# [*dhcp_lease_duration*]
#   (optionnal) DHCP Lease duration (in seconds)
#   Defaults to '120'
#
# [*ssl*]
#   (optional) Enable SSL (boolean)
#   Dfaults false
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

class cloud::network(
  $verbose                  = true,
  $debug                    = true,
  $rabbit_hosts             = ['127.0.0.1:5672'],
  $rabbit_password          = 'rabbitpassword',
  $rabbit_use_ssl           = false,
  $kombu_ssl_ca_certs       = undef,
  $kombu_ssl_certfile       = undef,
  $kombu_ssl_keyfile        = undef,
  $kombu_ssl_version        = 'SSLv3',
  $tunnel_eth               = '127.0.0.1',
  $api_eth                  = '127.0.0.1',
  $provider_vlan_ranges     = ['physnet1:1000:2999'],
  $provider_bridge_mappings = ['physnet1:br-eth1'],
  $use_syslog               = true,
  $log_facility             = 'LOG_LOCAL0',
  $dhcp_lease_duration      = '120',
  $ssl                      = false,
  $ssl_cacert               = false,
  $ssl_cert                 = false,
  $ssl_key                  = false,
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
  } else {
    $log_dir = '/var/log/neutron'
  }

  if $::osfamily == 'RedHat' {
    kmod::load { 'ip_gre': }
  }

  class { 'neutron':
    allow_overlapping_ips   => true,
    verbose                 => $verbose,
    debug                   => $debug,
    rabbit_user             => 'neutron',
    rabbit_hosts            => $rabbit_hosts,
    rabbit_password         => $rabbit_password,
    rabbit_virtual_host     => '/',
    rabbit_use_ssl          => $rabbit_use_ssl,
    kombu_ssl_ca_certs      => $kombu_ssl_ca_certs,
    kombu_ssl_certfile      => $kombu_ssl_certfile,
    kombu_ssl_keyfile       => $kombu_ssl_keyfile,
    kombu_ssl_version       => $kombu_ssl_version,
    bind_host               => $api_eth,
    log_facility            => $log_facility,
    use_syslog              => $use_syslog,
    dhcp_agents_per_network => '2',
    core_plugin             => 'neutron.plugins.ml2.plugin.Ml2Plugin',
    service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
    log_dir                 => $log_dir,
    dhcp_lease_duration     => $dhcp_lease_duration,
    report_interval         => '30',
    use_ssl                 => $ssl,
    ca_file                 => $ssl_cacert,
    cert_file               => $ssl_cert,
    key_file                => $ssl_key,
  }

  class { 'neutron::agents::ovs':
    enable_tunneling => true,
    tunnel_types     => ['gre'],
    bridge_mappings  => $provider_bridge_mappings,
    local_ip         => $tunnel_eth
  }

  class { 'neutron::plugins::ml2':
    type_drivers          => ['gre','vlan'],
    tenant_network_types  => ['gre'],
    network_vlan_ranges   => $provider_vlan_ranges,
    tunnel_id_ranges      => ['1:10000'],
    mechanism_drivers     => ['openvswitch','l2population'],
    enable_security_group => true,
    firewall_driver       => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'
  }

  # TODO(EmilienM) Temporary, need to be fixed upstream.
  # There is an issue when using ML2 + OVS: neutron services don't read OVS
  # config file, only ML2. I need to patch puppet-neutron.
  # Follow-up: https://github.com/enovance/puppet-openstack-cloud/issues/199
  neutron_plugin_ml2 {
    'agent/tunnel_types':     value => ['gre'];
    'agent/l2_population':    value => true;
    'agent/polling_interval': value => '15';
    'OVS/local_ip':           value => $tunnel_eth;
    'OVS/enable_tunneling':   value => true;
    'OVS/integration_bridge': value => 'br-int';
    'OVS/tunnel_bridge':      value => 'br-tun';
    'OVS/bridge_mappings':    value => $provider_bridge_mappings;
  }

  # TODO(EmilienM), Temporary, it's a bug in Debian packages. GH#342
  file { '/var/lib/neutron':
      ensure => 'directory',
      owner  => 'neutron',
      group  => 'neutron',
      mode   => '0755'
  }

}
