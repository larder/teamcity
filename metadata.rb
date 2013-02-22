name             'teamcity'
maintainer       "Malte Swart"
maintainer_email "chef@maltswart.de"
license          "Apache License, Version 2.0"
description      "Provides integration with teamcity for getting bits from teamcity or setup build agents"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"

recommends "java"

recipe 'teamcity::agent', 'Installs an agent for a teamcity ci server'
