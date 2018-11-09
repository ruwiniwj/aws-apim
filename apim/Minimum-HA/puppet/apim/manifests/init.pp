#----------------------------------------------------------------------------
#  Copyright (c) 2018 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------

class apim inherits apim::params {

  if $jdk_version == 'Oracle_JDK_8' {
    $jdk_type = "jdk-8u144-linux-x64.tar.gz"
    $jdk_path = "jdk1.8.0_144"
  }
  elsif $jdk_version == 'Open_JDK_8' {
    $jdk_type = "jdk-8u192-ea-bin-b02-linux-x64-19_jul_2018.tar.gz"
    $jdk_path = "jdk1.8.0_192"
  }

  # Create wso2 group
  group { $user_group:
    ensure => present,
    gid    => $user_group_id,
    system => true,
  }

  # Create wso2 user
  user { $user:
    ensure => present,
    uid    => $user_id,
    gid    => $user_group_id,
    home   => "/home/${user}",
    system => true,
  }

  # Ensure /opt/is directory is available
  file { "/opt/${service_name}":
    ensure => directory,
    owner  => $user,
    group  => $user_group,
  }

  file { "/usr/lib/wso2/":
    ensure => directory,
    owner  => $user,
    group  => $user_group,
  }

  file { "/usr/lib/wso2/wso2am/":
    ensure => directory,
    owner  => $user,
    group  => $user_group,
  }

  file { "/usr/lib/wso2/wso2am/2.1.0/":
    ensure => directory,
    owner  => $user,
    group  => $user_group,
  }

  # Copy the relevant installer to the /opt/is directory
  file { "/usr/lib/wso2/wso2am/2.1.0/${apim_package}":
    owner  => $user,
    group  => $user_group,
    mode   => '0644',
    source => "puppet:///modules/installers/${apim_package}",
  }

  # Install WSO2 APIM
  exec { 'unzip':
    command => 'unzip wso2am-2.1.0.zip',
    unless =>  '/usr/bin/test -d /usr/lib/wso2/wso2am/2.1.0/wso2am-2.1.0',
    cwd     => '/usr/lib/wso2/wso2am/2.1.0/',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  #jdk
  file { "/usr/lib/wso2/wso2am/2.1.0/${jdk_type}":
    owner  => $user,
    group  => $user_group,
    mode   => '0644',
    source => "puppet:///modules/installers/${jdk_type}",
  }

  # Install WSO2 APIM Server
  exec { 'tar':
    command => "tar -xvf ${jdk_type}",
    cwd     => '/usr/lib/wso2/wso2am/2.1.0/',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }


  # Copy configuration changes to the installed directory
  $template_list.each |String $template| {
    file { "/usr/lib/wso2/wso2am/2.1.0/wso2am-2.1.0/${template}":
      ensure  => file,
      owner   => $user,
      group   => $user_group,
      mode    => '0644',
      content => template("${module_name}/carbon-home/${template}.erb")
    }
  }

  # Copy wso2server.sh to installed directory
  file { "/usr/lib/wso2/wso2am/2.1.0/wso2am-2.1.0/${start_script_template}":
    ensure  => file,
    owner   => $user,
    group   => $user_group,
    mode    => '0754',
    content => template("${module_name}/carbon-home/${start_script_template}.erb")
  }

  # Copy mysql connector to the installed directory
  file { "/usr/lib/wso2/wso2am/2.1.0/wso2am-2.1.0/repository/components/lib/mysql-connector-java-5.1.41-bin.jar":
    owner  => $user,
    group  => $user_group,
    mode   => '0754',
    source => "puppet:///modules/installers/mysql-connector-java-5.1.41-bin.jar",
  }

  file { "/usr/local/bin/private_ip_extractor.py":
    owner  => $user,
    group  => $user_group,
    mode   => '0754',
    source => "puppet:///modules/installers/private_ip_extractor.py",
  }

 }
