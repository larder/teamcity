# Cookbook Name:: teamcity
# Attributes:: agent
#
# Copyright 2013, Malte Swart (chef@malteswart.de)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

agent = default['teamcity']['agents']['default']

agent['server_url'] = nil
agent['name'] = nil # generate name by teamcity

agent['user'] = 'teamcity'
agent['group'] = 'teamcity'

agent['home'] = "/home/" + default['teamcity']['agents']['default']['user']
agent['base'] = default['teamcity']['agents']['default']['home']

agent['system_dir'] = default['teamcity']['agents']['default']['base']
agent['work_dir'] = "#{default['teamcity']['agents']['default']['base']}/work"
agent['temp_dir'] = "#{default['teamcity']['agents']['default']['base']}/tmp"

agent['own_address'] = nil
agent['own_port'] = 9090
agent['authorization_token'] = nil

agent['system_properties'] = {}
agent['env_properties'] = {}
