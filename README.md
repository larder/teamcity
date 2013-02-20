Description
===========
Provides a collection of tools for downloading build artifacts from a teamcity server

Requirement
===========

Platform
--------

* Any supported by chef

Library Methods
===============

Teamcity::Utility
-----------------
A collection of utilities for dealing with teamcity

### Methods
- get_latest_build(build_type): Gets the latest successful build for the specified build type.

### Examples
    tc = Teamcity::Utility.new(:server=>node.teamcity.server, :port => 80, :username => node.teamcity.username, :password => node.teamcity.password)
    build_version = tc.get_latest_build('bt3')

    #Download a whole build
    teamcity_build "Download Build" do
      build_type "bt4"
      version build_version
      destination "C:\\Temp\\#{build_version}\\Build.zip"
      overwrite true
      action :download
    end



Resources/Providers
===================

teamcity_build
---------------
Download all artifacts from a teamcity build

### Actions
- :download: Downloads teamcity artifacts

### Attribute Parameters
* Indicates a default value is set

- :build_type: The team city identifier for the build. Example 'bt1'
- :version: The numeric build to download. Example '1.2.3.444'
- :overwrite: Overwrite the file if it already exists
- :destination: Where to download the file to.
- :connection: Connection information for the teamcity server
    - :server=>'ServerName',:port => 80, :username => 'YourUsername', :password => 'Password'

### Node Attributes
- node['teamcity']: Teamcity related data
- node['teamcity']['server']: The default name of the teamcity server
- node['teamcity']['port']: The port that teamcity operates on
- node['teamcity']['username']: The default username to login with
- node['teamcity']['password']: The default password to login with


### Examples
    #Download a whole build
    teamcity_build "Download Build" do
      build_type "bt4"
      version "1.2.3.4"
      destination "C:\\Temp\\1.2.3.4\\Build.zip"
      overwrite true
      action :download
    end

teamcity_files
---------------
Download a specific list of files from the artifacts of a teamcity build

### Actions
- :download: Downloads teamcity artifacts

### Attribute Parameters

- :build_type: The team city identifier for the build. Example 'bt1'
- :version: The numeric build to download. Example '1.2.3.444'
- :overwrite: Overwrite the file if it already exists
- :destination: Where to download the file to.
- :files: An array of relative paths to files that should be downloaded
    - Example: ['deploy/release.zip','deploy/debug.zip']
- :connection: Connection information for the teamcity server
    - :server=>'ServerName',:port => 80, :username => 'YourUsername', :password => 'Password'

### Node Attributes
- node['teamcity']: Teamcity related data
- node['teamcity']['server']: The default name of the teamcity server
- node['teamcity']['port']: The port that teamcity operates on
- node['teamcity']['username']: The default username to login with
- node['teamcity']['password']: The default password to login with


### Examples
    #Download some files from a build
    teamcity_files "Download Build" do
      build_type "bt3"
      version "1.2.3.4"
      files ["deploy/Release.zip","deploy/Debug.zip"]
      destination "C:\\Temp\\1.2.3.4"
      overwrite true
      action :download
    end



