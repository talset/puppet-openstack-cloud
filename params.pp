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

# Parameters of eNovance CI

class os_params {
  $site_domain = "enovance.com"

  # Root hashed password (enovance by default)
  $root_password = "$1$2X/chMfy$CuJ4xPZY0WO2pRfIm5djn/"

  # Databases
  $keystone_db_host = "10.68.0.46"
  $keystone_db_user = "keystone"
  $keystone_db_password = "rooghah0phe1tieDeixoodo0quil8iox"
  $keystone_allowed_hosts = ["os-ci%", "10.68.0.%"]
  # Extra roles, one for Midonet:
  $keystone_roles_addons = ["SwiftOperator", "ResellerAdmin"chMfy]


  $ceilometer_database_connection = 'mongodb://10.68.0.46/ceilometer'

  # Keystone Users
  $ks_admin_token = "iw3feche3JeeYo9mejoohaugai3thohahwo9tiuyoe5Thier8Eiwah8K"
  $ks_admin_email = "dev@enovance.com"
  $ks_admin_password = "Xokoph5io2aenaoh0nuiquei9aineigo"

  $ks_swift_dispersion_password = "aipee1die1eeSohph9yae8eeluthaleu"
  $ks_swift_password = "cwnu6Eeph4jahsh5wooch5Panahjaidie8"
  $ks_ceilometer_password = "eafhafbheafaefaejiiutiu7374aesf3aiNu"

  $keystone_memchached = ["10.68.0.46:11211"]

  # API Ports
  $swift_port = "8080"
  $keystone_port = "5000"
  $keystone_admin_port = "35357"
  $ceilometer_port = "8777"

  # Keystone Endpoints
  $ks_keystone_public_proto = "http"
  $ks_keystone_public_port = "5000"
  $ks_keystone_public_host = "os-ci-test2.enovance.com" # ipvs lb web 
  $ks_keystone_internal_host = "os-ci-test2.enovance.com" # ipvs lb int # can be used for now
  $ks_keystone_admin_host = "os-ci-test2.enovance.com" # ipvs lb int # can be used for now

  $ks_swift_public_proto = "http"
  $ks_swift_public_port = "8080"
  $ks_swift_public_host = "os-ci-test2.enovance.com"
  $ks_swift_admin_host = "os-ci-test2.enovance.com"
  $ks_swift_internal_host = "os-ci-test2.enovance.com"

  $ks_ceilometer_public_proto = "http"
  $ks_ceilometer_public_host = "os-ci-test2.enovance.com"
  $ks_ceilometer_admin_host = "os-ci-test2.enovance.com"
  $ks_ceilometer_internal_host = "os-ci-test2.enovance.com"

  # swift
  $swift_cors_allow_origin = "http://os-ci-test2.enovance.com"
  $swift_hash_suffix = "ni2aseiWi8ich3oo"
  $swift_rsync_max_connections = 5
  $swift_memchached = ["10.68.0.46:11211"]
  $statsd_host = "127.0.0.1"
  $statsd_port = "4125"
  $os_swift_zone = {
     'os-ci-test3' => 1,
     'os-ci-test4' => 2,
     'os-ci-test6' => 3,
  }

  # MySQL
  $mysql_password = "Poveiquiec1woht1"

  # Ceilometer
  $ceilometer_secret = "aefiojanjbo778efa"

  # MongoDB
  $mongodb_location = ''

  # RabbitMQ
  $rabbit_names = ['os-ci-test2']
  $rabbit_hosts = ['10.68.0.46:5672']
  $rabbit_password = "okaeTh3aiwiewohk"
  # Useful when we need a single Rabbit host (like Sensu needs)
  $rabbit_main_host = 'os-ci-test2'

}