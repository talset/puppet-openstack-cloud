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
# Unit tests for cloud::logging::agent class
#

require 'spec_helper'

describe 'cloud::monitoring::server::sensu' do

  shared_examples_for 'openstack sensu monitoring server' do

    let :params do
      {
        :rabbit_names      => ['foo','boo','zoo'],
        :rabbit_password   => 'secrete',
        :cluster_node_type => 'disc'
      }
    end

    context 'with manage_rabbitmq set to true' do
      before :each do
        params.merge!(
          :manage_rabbitmq   => true,
          :rabbitmq_user     => 'testsensu',
          :rabbitmq_password => 'sensusecret',
          :rabbitmq_vhost    => '/testsensu'
        )
      end

      should  contain_class('rabbitmq')
      should  contain_rabbitmq__user('testsensu').with(
        'password' => 'sensusecret'
      )
      should contain_rabbitmq__vhost('/testsensu').with(
        'ensure' => 'present'
      )
    end

    context 'with manage_redis set to true' do
      before :each do
        params.merge!( :manage_redis => true )
      end

      should  contain_class('redis')
    end

    context 'with proxy_dashboard set to true' do
      before :each do
        params.merge!(
          :proxy_dashboard      => true,
          :dashboard_servername => 'sensu.monitor.example.com',
          :vhost_configuration  => { 'port' => '80', 'docroot' => '/tmp'}
        )
      end

      should  contain_class('apache')
      should  contain_apache__vhost('sensu.monitor.example.com').with(
        'docroot' => '/tmp',
        'port'    => '80'
      )
    end

    context 'with a given check' do
      before :each do
        params.merge!(
          :checks      =>  {'check-mem.sh' => {}}
        )
      end

      should contain_sensu__check('check-mem.sh')
    end

    context 'with a given handler' do
      before :each do
        params.merge!(
          :handlers      =>  {'irc' => {}}
        )
      end

      should contain_sensu__handler('irc')
    end



  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack sensu monitoring server'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack sensu monitoring server'
  end

end
