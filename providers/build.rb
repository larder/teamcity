include Teamcity::Helper

action :download do
  initialize_connection(@new_resource.connection)
  download_all(@new_resource.destination)
end