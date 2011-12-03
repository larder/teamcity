module Teamcity
  module Exceptions
    class FileAlreadyExists < RuntimeError; end
    class FileNotFound < RuntimeError; end
    class InvalidServerResponse < RuntimeError; end
  end
end