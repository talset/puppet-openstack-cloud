#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Authors: Mehdi Abaakouk <mehdi.abaakouk@enovance.com>
#          Emilien Macchi <emilien.macchi@enovance.com>
#          Francois Charlier <francois.charlier@enovance.com>
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
# Metering server nodes
#

class os_telemetry_server(
  $ks_keystone_internal_host      = $os_params::ks_keystone_internal_host,
  $ks_keystone_internal_proto     = $os_params::ks_keystone_internal_proto,
  $ks_ceilometer_password         = $os_params::ks_ceilometer_password,
  $ceilometer_database_connection = $os_params::ceilometer_database_connection,
){

# Install MongoDB database
  class { 'ceilometer::db':
    database_connection => $ceilometer_database_connection,
    require             => Class['mongodb']
  }

# Install Ceilometer-collector
  class { 'ceilometer::collector': }

# Install Ceilometer-evaluator
  class { 'ceilometer::alarm::evaluator': }

# Install Ceilometer-notifier
  class { 'ceilometer::alarm::notifier': }

# Install Ceilometer-API
  class { 'ceilometer::api':
    keystone_password => $ks_ceilometer_password,
    keystone_host     => $ks_keystone_internal_host,
    keystone_protocol => $ks_keystone_internal_proto,
  }

# Ceilometer Central Agent is defined in site.pp since it must be installed on only node (not able to scale-out)

}