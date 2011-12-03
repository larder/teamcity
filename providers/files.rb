include Teamcity::Helper

action :download do
  initialize_connection(@new_resource.connection)
  download_files(@new_resource.files,@new_resource.destination)
end