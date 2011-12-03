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