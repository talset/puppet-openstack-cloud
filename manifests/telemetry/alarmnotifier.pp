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
# Telemetry Alarm Notifier nodes
#
#  [*enabled*]
#   (optional) should the service be enabled
#    Defaults to true
#
#  [*notifier_rpc_topic*]
#    (optional) define on which topic the notifier will have access
#    Defaults to undef
#
#  [*rest_notifier_certificate_key*]
#    (optional) define the certificate key for the rest service
#    Defaults to undef
#
#  [*rest_notifier_certificate_file*]
#    (optional) define the certificate file for the rest service
#    Defaults to undef
#
#  [*rest_notifier_ssl_verify*]
#    (optional) should the ssl verify parameter be enabled
#    Defaults to undef
#
class cloud::telemetry::alarmnotifier(
  $enabled                        = true,
  $notifier_rpc_topic             = undef,
  $rest_notifier_certificate_key  = undef,
  $rest_notifier_certificate_file = undef,
  $rest_notifier_ssl_verify       = true,
){

  include 'cloud::telemetry'

  class { 'ceilometer::alarm::notifier':
    enabled                        => $enabled,
    notifier_rpc_topic             => $notifier_rpc_topic,
    rest_notifier_certificate_file => $rest_notifier_certificate_file,
    rest_notifier_certificate_key  => $rest_notifier_certificate_key,
    rest_notifier_ssl_verify       => $rest_notifier_ssl_verify,
  }

}
