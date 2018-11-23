# ----------------------------------------------------------------------------
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
# ----------------------------------------------------------------------------

# Class: apim
# Init class of API Manager default profile
class apim (
  $user                  = $apim::params::user,
  $user_id               = $apim::params::user_id,
  $user_group            = $apim::params::user_group,
  $user_group_id         = $apim::params::user_group_id,
  $service_name          = $apim::params::service_name,
  $template_list         = $apim::params::template_list,
  $start_script_template = $apim::params::start_script_template,

  # api-manager.xml configs
  $auth_manager          = $apim::params::auth_manager,
  $api_gateway           = $apim::params::api_gateway,
  $analytics             = $apim::params::analytics,
  $api_store             = $apim::params::api_store,
  $api_publisher         = $apim::params::api_publisher,

  # Master-datasource configs
  $wso2am_db             = $apim::params::wso2am_db,
  $wso2am_stat_db        = $apim::params::wso2am_stat_db,
  $wso2_mb_store_db      = $apim::params::wso2_mb_store_db,

  # carbon.xml configs
  $ports                 = $apim::params::ports,
  $key_store             = $apim::params::key_store,
)

  inherits apim::params {

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
  # Ensure the installation directory is available
  file { "/opt/${service_name}":
    ensure => 'directory',
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

  file { "/usr/lib/wso2/wso2am/2.6.0/":
    ensure => directory,
    owner  => $user,
    group  => $user_group,
  }

  # Copy the relevant installer to the /opt/is directory
  file { "/usr/lib/wso2/wso2am/2.6.0/${am_package}":
    owner  => $user,
    group  => $user_group,
    mode   => '0644',
    source => "puppet:///modules/installers/${am_package}",
  }

  # Install WSO2 Identity Server
  exec { 'unzip':
    command => 'unzip wso2am-2.6.0.zip',
    cwd     => '/usr/lib/wso2/wso2am/2.6.0/',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  #jdk JDK
  file { "/usr/lib/wso2/wso2am/2.6.0/${jdk_type}":
    owner  => $user,
    group  => $user_group,
    mode   => '0644',
    source => "puppet:///modules/installers/${jdk_type}",
  }

  # Install WSO2 Identity Server
  exec { 'tar':
    command => "tar -xvf ${jdk_type}",
    cwd     => '/usr/lib/wso2/wso2am/2.6.0/',
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }


  # Copy configuration changes to the installed directory
  $template_list.each | String $template | {
    file { "/usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/${template}":
      ensure  => file,
      owner   => $user,
      group   => $user_group,
      mode    => '0644',
      content => template("${module_name}/carbon-home/${template}.erb")
    }
  }

  # Copy wso2server.sh to installed directory
  file { "/usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/${start_script_template}":
    ensure  => file,
    owner   => $user,
    group   => $user_group,
    mode    => '0754',
    content => template("${module_name}/carbon-home/${start_script_template}.erb")
  }

  # Copy mysql connector to the installed directory
  file { "/usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/repository/components/lib/mysql-connector-java-5.1.41-bin.jar":
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

  # Copy the unit file required to deploy the server as a service
  file { "/etc/systemd/system/${service_name}.service":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0754',
    content => template("${module_name}/${service_name}.service.erb"),
  }

}
