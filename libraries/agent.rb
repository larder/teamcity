#
# Author:: Malte Swart (<chef@malteswart.de>)
# Cookbook Name:: teamcity
#
# Copyright 2013, Malte Swart
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

module Teamcity
  class Agent
    def initialize(name, node)
      @name = name
      @node = node

      cache
    end

    def cache
      # cache agent + shorter calls
      @agent = @node['teamcity']['agents'][@name]
    end

    # delegate to agent attributes hash of chef per default
    def method_missing(meth, *args, &block)
      if meth.is_a?(Symbol) && args.empty?
        @agent[meth.to_s]
      else
        super
      end
    end

    # set default values for agent
    def set_defaults
      agent = @node.default_unless['teamcity']['agents'][@name]

      agent['server_url'] = nil
      agent['name'] = nil # generate name by teamcity

      agent['user'] = 'teamcity'
      agent['group'] = 'teamcity'

      agent['home'] = nil

      agent['system_dir'] = '.'
      agent['work_dir'] = 'work'
      agent['temp_dir'] = 'tmp'

      agent['own_address'] = nil
      agent['own_port'] = 9090
      agent['authorization_token'] = nil

      agent['system_properties'] = {}
      agent['env_properties'] = {}

      # recache
      cache
    end

    def to_hash
      @agent.keys.inject({}) do |memento, key|
        memento[key] = self.send key.to_sym
        memento
      end
    end

    def self.agent_count(node)
      @agent_count ||= node['teamcity']['agents'].to_hash.reject { |n, agent| agent.nil? }.size
    end

    def label(seperator)
      if self.class.agent_count(@node) < 2
        ''
      else
        seperator + @name
      end
    end

    def server_url?
      @agent['server_url'] && !@agent['server_url'].empty?
    end

    def home
      @agent['home'] || File.join('', 'home', user)
    end

    def system_dir
      File.expand_path @agent['system_dir'], home
    end

    def work_dir
      File.expand_path @agent['work_dir'], system_dir
    end

    def temp_dir
      File.expand_path @agent['temp_dir'], system_dir
    end

    def name=(name)
      @node.set['teamcity']['agents'][@name]['name'] = name
      cache
    end

    def authorization_token=(authorization_token)
      @node.set['teamcity']['agents'][@name]['authorization_token'] = authorization_token
      cache
    end
  end
end
