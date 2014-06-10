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
# Unit tests for cloud::orchestration class
#

require 'spec_helper'

describe 'cloud::orchestration' do

  shared_examples_for 'openstack orchestration' do

    let :params do
      {
        :rabbit_hosts               => ['10.0.0.1'],
        :rabbit_password            => 'secrete',
        :rabbit_use_ssl             => true,
        :kombu_ssl_ca_certs         => '/ssl/ca/certs',
        :kombu_ssl_certfile         => '/ssl/cert/file',
        :kombu_ssl_keyfile          => '/ssl/key/file',
        :kombu_ssl_version          => 'SSLv3',
        :ks_keystone_internal_host  => '10.0.0.1',
        :ks_keystone_internal_port  => '5000',
        :ks_keystone_internal_proto => 'http',
        :ks_keystone_admin_host     => '10.0.0.1',
        :ks_keystone_admin_port     => '5000',
        :ks_keystone_admin_proto    => 'http',
        :ks_heat_public_host        => '10.0.0.1',
        :ks_heat_public_proto       => 'http',
        :ks_heat_password           => 'secrete',
        :heat_db_host               => '10.0.0.1',
        :heat_db_user               => 'heat',
        :heat_db_password           => 'secrete',
        :verbose                    => true,
        :log_facility               => 'LOG_LOCAL0',
        :use_syslog                 => true,
        :debug                      => true
      }
    end

    it 'configure heat common' do
      should contain_class('heat').with(
          :verbose                 => true,
          :debug                   => true,
          :log_facility            => 'LOG_LOCAL0',
          :use_syslog              => true,
          :rabbit_userid           => 'heat',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_use_ssl          => true,
          :kombu_ssl_ca_certs      => '/ssl/ca/certs',
          :kombu_ssl_certfile      => '/ssl/cert/file',
          :kombu_ssl_keyfile       => '/ssl/key/file',
          :kombu_ssl_version       => 'SSLv3',
          :keystone_host           => '10.0.0.1',
          :keystone_port           => '5000',
          :keystone_protocol       => 'http',
          :keystone_password       => 'secrete',
          :auth_uri                => 'http://10.0.0.1:5000/v2.0',
          :sql_connection          => 'mysql://heat:secrete@10.0.0.1/heat?charset=utf8',
          :log_dir                 => false
        )
    end

    it 'checks if Heat DB is populated' do
      should contain_exec('heat_db_sync').with(
        :command => 'heat-manage --config-file /etc/heat/heat.conf db_sync',
        :user    => 'heat',
        :path    => '/usr/bin',
        :unless  => '/usr/bin/mysql heat -h 10.0.0.1 -u heat -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian' }
    end

    it_configures 'openstack orchestration'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat' }
    end

    it_configures 'openstack orchestration'
  end

end
