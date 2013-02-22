Description
===========
Provides:
- a collection of tools for downloading build artifacts from a teamcity server
- a recipe for installing and configuring (multiple) teamcity agents

Requirement
===========

Platform
--------

* Any supported by chef

Cookbooks
---------

The agent needs the Java JDK (JDK 6 or later for TeamCity 7.0). We recommend the [opscode java cookbook](http://community.opscode.com/cookbooks/java) to install it. But the cookbook assumes only that the OpenJDK is setup correctly.


Attributes
==========

Agent
-----

The agent recipe supports setup for multiple agent per host. Per agent an entry in `node['teamcity']['agents']` handles all options for this agent. The key is a chef internal name for the agent and does not have to be the name for the agent in teamcity. It is only used if you have multiple agents, to distinguish the agents (primary as suffix for the teamcity-agent service).

Per default a default agent is configured. If you want to setup more agents, create additional entries and ensure that the paths do not interact. Read also [the official documentation](http://confluence.jetbrains.com/display/TCD7/Setting+up+and+Running+Additional+Build+Agents#SettingupandRunningAdditionalBuildAgents-InstallingSeveralBuildAgentsontheSameMachine) for more information and limitations.

The following attributes are supported for every agent (`node['teamcity']['agents'][agentname]`):

- `server_url`: The address of the TeamCity server. The same as is used to open TeamCity web interface in the browser. **This option has to be configured.**
- `name` (`nil`): The unique name of the agent used to identify this agent on the TeamCity server. Set to `nil` to let server generate it. By default, this name would be created from the build agent's host name
- `user` (`teamcity`): Username for teamcity agent
- `group` (`teamcity`): Username for teamcity agent
- `home` (`nil`): Home directory for teamcity agent, nil is expanded to `/home/$user`

- `system_dir` (`.`): Container directory for agent system files, absolute or relative path to home directory
- `work_dir` (`work`): Container directory to create default checkout directories for the build configurations, absolute or relative path to system_dir directory
- `temp_dir` (`tmp`): Container directory for the temporary directories. *Please note that the directory may be cleaned between the builds.*, absolute or relative path to system_dir directory

- `own_address` (`nil`): The IP address which will be used by TeamCity server to connect to the build agent. If `nil`, it is detected by build agent automatically, but if the machine has several network interfaces, automatic detection may fail.
- `own_port` (`9090`): A port that TeamCity server will use to connect to the agent. Please make sure that incoming connections for this port are allowed on the agent computer (e.g. not blocked by a firewall)
- `authorization_token` (`nil`): A token which is used to identify this agent on the TeamCity server. It is automatically generated and saved on the first agent connection to the server.

- `system_properties` (`{}`): Support for overwrite system properties, `system.` prefix is added by chef.
- `env_properties` (`{}`): Support for overwrite env properties, `env.` prefix is added by chef.

If `authorization_token` or `name` are nil and defined inside the agent config, these values are extracted and stored as node attributes.

To delete/remove a configured agent (e.g. the default agent) replace the hash with `nil`: `node['teamcity']['agent'][agentname] = nil`

This cookbooks requires that a Java JDK 6 is installed, configured and can be found per script. You can use the java cookbook to do this.

Recipes
=======

Agent
-----

This recipe installs and configures an agent per teamcity server.

Multiple agents per host are supported, but you need to set the attributes (expesially the paths) carefully to avoid problems between the different agents.

The recipe creates a user for teamcity. Afterwards it downloads the agent source code from the teamcity server and installs it inside the user home directory (per default, can be changed via attributes).


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
