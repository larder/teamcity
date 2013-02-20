# Cookbook Name:: teamcity
# Recipe:: agent
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

node['teamcity']['agents'].each do |name, agent| # multiple agents
  agent_label = Proc.new do |seperator|
    if agent['default'] == true
      ''
    else
      seperator + name
    end
  end

  unless agent['server_url'] && agent['server_url'].present?
    message = "You need to setup the server url for agent #{name}"
    Chef::Log.fatal message
    raise message
  end

  # Create the users' group
  group agent['group'] do
  end

  # Create the user
  user agent['user'] do
    comment 'TeamCity Agent' + agent_label.call(' ')
    gid agent['group']
    home agent['home']
  end

  directory agent['base'] do
    user agent['user']
    group user agent['group']
    recursive true

    action :create
    not_if { File.exists? agent['base'] }
  end

  install_file = "#{Chef::Config[:file_cache_path]}/teamcity-agent-#{name}.zip"
  installed_check = Proc.new { ::File.exists? "#{agent['base']}/bin" }

  remote_file install_file do
    source agent['server_url'] + '/update/buildAgent.zip'
    mode 0555
    action :create_if_missing
    not_if &installed_check
  end

  package 'unzip' do
    action :install
    not_if &installed_check
  end

  # is there a better approach?
  execute "unzip #{install_file} -d #{agent[:base]}" do
    user agent[:user]
    creates "#{agent['base']}/bin"
    not_if &installed_check
  end

  file install_file do
    action :delete
    only_if &installed_check
  end

  # as of TeamCity 6.5.4 the zip does NOT contain the file mode
  %w{linux-x86-32 linux-x86-64 linux-ppc-64 }.each do |platform|
    file ::File.join( agent['base'], 'launcher/bin/TeamCityAgentService-' + platform) do
      mode 0755
    end
  end

  # try to extract agent name + authenticationCode from file
  agent_config = ::File.join agent['base'], 'conf', 'buildAgent.properties'
  if (agent['name'].nil? || agent['authorization_token'].nil?) && ::File.readable?(agent_config)
    settings = File.new(agent_config).readlines.map do |s|
      s.index("#") ? s.slice(0, s.index("#")).strip : s.strip  # remove comments
    end.reject do |s|
     s.index("=").nil? # remove lines without =
    end.inject({}) do |memento,line| # split on = and convert to hash
      key, value = line.split '='
      memento[key] = value
      memento
    end
    if agent['name'].nil? && !settings['name'].nil?
      Chef::Log.info "Setting agent (#{name})'s name to #{settings['name']}"
      node.set['teamcity']['agents'][name]['name'] = settings['name']
    end
    if agent['authorization_token'].nil? && !settings['authorizationToken'].nil?
      Chef::Log.info "Setting agent (#{name})'s authorization_token"
      node.set['teamcity']['agents'][name]['authorization_token'] = settings['authorizationToken']
    end
  end

  # buildAgent.properties (TeamCity will restart if this file is changed)
  template agent_config do
    source "buildAgent.properties.erb"
    variables node['teamcity']['agents'][name]
    mode 0644
  end
end
