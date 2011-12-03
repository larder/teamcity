#
# Author:: Paul Morton (<larder-project@biaprotect.com>)
# Cookbook Name:: teamcity
#
# Copyright 2011, Paul Morton
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
  class Utility
    include Teamcity::Helper
    def get_latest_build(build_type)

      version = get_json(build_rest_uri("buildTypes/id:#{build_type}/builds",'status'=>'SUCCESS','count'=>'1'))['build'][0]['number']
      version
    end

    def initialize(options)
      options[:port] = options[:port] || 80
      initialize_connection(options)
    end
  end
end