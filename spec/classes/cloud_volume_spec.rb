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
# Unit tests for cloud::volume class
#

require 'spec_helper'

describe 'cloud::volume' do

  shared_examples_for 'openstack volume' do

    let :params do
      {
        :cinder_db_host            => '10.0.0.1',
        :cinder_db_user            => 'cinder',
        :cinder_db_password        => 'secrete',
        :rabbit_hosts              => ['10.0.0.1'],
        :rabbit_password           => 'secrete',
        :rabbit_use_ssl            => true,
        :kombu_ssl_ca_certs        => '/ssl/ca/certs',
        :kombu_ssl_certfile        => '/ssl/cert/file',
        :kombu_ssl_keyfile         => '/ssl/key/file',
        :kombu_ssl_version         => 'SSLv3',
        :verbose                   => true,
        :debug                     => true,
        :log_facility              => 'LOG_LOCAL0',
        :storage_availability_zone => 'nova',
        :use_syslog                => true,
        :ssl                       => true,
        :ssl_cacert                => '/ssl/ca/cert',
        :ssl_cert                  => '/ssl/cert',
        :ssl_key                   => '/ssl/key',
      }
    end

    it 'configure cinder common' do
      should contain_class('cinder').with(
        :verbose             => true,
        :debug               => true,
        :rabbit_userid       => 'cinder',
        :rabbit_hosts        => ['10.0.0.1'],
        :rabbit_password     => 'secrete',
        :rabbit_virtual_host => '/',
        :rabbit_use_ssl      => true,
        :kombu_ssl_ca_certs  => '/ssl/ca/certs',
        :kombu_ssl_certfile  => '/ssl/cert/file',
        :kombu_ssl_keyfile   => '/ssl/key/file',
        :log_facility        => 'LOG_LOCAL0',
        :use_syslog          => true,
        :log_dir             => false,
        :use_ssl             => true,
        :ca_file             => '/ssl/ca/cert',
        :cert_file           => '/ssl/cert',
        :key_file            => '/ssl/key',
        # :storage_availability_zone => 'nova'
      )
      should contain_class('cinder::ceilometer')
    end

    it 'checks if Cinder DB is populated' do
      should contain_exec('cinder_db_sync').with(
        :command => 'cinder-manage db sync',
        :user    => 'cinder',
        :path    => '/usr/bin',
        :unless  => '/usr/bin/mysql cinder -h 10.0.0.1 -u cinder -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack volume'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack volume'
  end

end
