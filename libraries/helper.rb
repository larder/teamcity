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

require 'net/http'
require 'json'
require 'fileutils'

module Teamcity
  module Helper


    def get_json (uri)

      req = build_request uri
      res = Net::HTTP.start(uri.host, uri.port) { |http|
        http.request(req)
      }

     if res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
     else
       Chef::Log.debug "Server returned code #{res.code}"
       raise Teamcity::Exceptions::InvalidServerResponse
     end
    end

    def get_file(uri,destination)
      req = build_request uri

      if File.exists? destination
        if @new_resource.overwrite
          Chef::Log.info "Unlinking #{destination} so that I can download from teamcity"
          File.unlink(destination)
        else
          raise Teamcity::Exceptions::FileAlreadyExists "Cannot download file, #{destination} already exists, use :overwrite"
        end
      end
      Chef::Log.info "Downloading file to #{destination}. This may take a while..."
      Net::HTTP.start(uri.host, uri.port) { |http|
        Chef::Log.debug "Starting HTTP session..."
        http.request req do |response|
          Chef::Log.debug "Getting HTTP Response"
          if response.is_a?(Net::HTTPSuccess)
            Chef::Log.debug "Response was successful with code #{response.code}"
            Chef::Log.debug "Recursively creating #{destination}"
            ::FileUtils.mkdir_p(File.dirname(destination))
            open destination, 'w' do |io|
              io.binmode
              response.read_body do |chunk|
                Chef::Log.debug "Downloaded chunk of size #{chunk.size}"
                io.write chunk
              end
              io.close
            end
          else
            Chef::Log.debug "Server returned code #{response.code}"
            raise Teamcity::Exceptions::FileNotFound "The file specified for download does not exist on the server"
          end

        end
      }
    end

    def initialize_connection(options)
      @server =  options[:server] || node.teamcity.server
      @username = options[:username] || node.teamcity.username
      @password = options[:password] || node.teamcity.password
      @port = options[:port] || node.teamcity.port
    end

    def build_request(uri)
      req = Net::HTTP::Get.new(uri.request_uri)
      req['Accept'] = "application/json"
      req.basic_auth @username, @password
      req
    end

    def build_rest_uri(path,params)
      build_uri("app/rest/#{path}",params)
    end

    def build_uri(path,params)
      uri = URI("http://#{@server}:#{@port}/httpAuth/#{path}")
      uri.query = build_query_string(params) unless params.nil?
      uri
    end

    def find_build_by_version( build_type, version )

      get_json(build_rest_uri("buildTypes/id:#{build_type}/builds/number:#{version}",nil))

    end

    def download_all(destination)
      build_info = find_build_by_version(@new_resource.build_type,@new_resource.version)
      build_id =  build_info['id']
      path = "repository/downloadAll/#{@new_resource.build_type}/#{build_id}:id/artifacts.zip"
      get_file(build_uri(path,nil),"#{destination}")
    end

    def download_files(files,destination)
      build_info = find_build_by_version(@new_resource.build_type,@new_resource.version)
      build_id =  build_info['id']
      files.each do |file|
        path = "repository/download/#{@new_resource.build_type}/#{build_id}:id/#{file}"
        get_file(build_uri(path,nil),File.join(destination,file))
      end
    end

    def build_query_string(params)
      qs = ''
      params.each do |key,value|
        qs = "?" if qs.eql? ''
        qs << "&" unless qs.eql? '?'
        qs << "#{key}=#{value}"
      end
      qs
    end

  end
end
