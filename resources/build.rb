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

actions :download

attribute :build_type, :required => true, :kind_of => String
attribute :version, :kind_of => [String]
attribute :overwrite, :kind_of => [TrueClass,FalseClass], :default => false
attribute :destination, :kind_of => String, :required => true
attribute :connection, :kind_of => Hash, :default => {}
