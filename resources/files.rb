actions :download

attribute :build_type, :required => true, :kind_of => String
attribute :version, :kind_of => [String,Symbol]
attribute :overwrite, :kind_of => [TrueClass,FalseClass], :default => false
attribute :destination, :kind_of => String, :required => true
attribute :files, :kind_of => Array, :required => true
attribute :connection, :kind_of => Hash, :default => {}