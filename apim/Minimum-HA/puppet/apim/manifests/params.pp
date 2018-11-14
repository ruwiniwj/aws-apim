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

class apim::params {

  $user = 'wso2carbon'
  $user_id = 802
  $user_group = 'wso2'
  $user_home = '/home/$user'
  $user_group_id = 802
  $service_name = 'wso2am'
  $hostname = 'CF_ELB_DNS_NAME'
  $mgt_hostname = 'CF_ELB_DNS_NAME'
  $enable_test_mode = 'ENABLE_TEST_MODE'
  $jdk_version = 'JDK_TYPE'
  $aws_access_key = 'access-key'
  $aws_secret_key = 'secretkey'
  $aws_region = 'REGION_NAME'
  $local_member_host = $::ipaddress
  $http_proxy_port  = '80'
  $https_proxy_port = '443'
  $apim_package = 'wso2am-2.1.0.zip'

  # Define the templates
  $start_script_template = 'bin/wso2server.sh'

  $template_list = [
    'repository/conf/api-manager.xml',
    'repository/conf/datasources/master-datasources.xml',
    'repository/conf/carbon.xml',
    'repository/conf/registry.xml',
    'repository/conf/user-mgt.xml',
    'repository/conf/axis2/axis2.xml',
    'repository/conf/identity/identity.xml',
    # 'repository/conf/security/authenticators.xml',
    'repository/conf/tomcat/catalina-server.xml',
  ]

  # Configuration Params
  if $jdk_version == 'Oracle_JDK_8' {
    $jdk_type = "jdk-8u144-linux-x64.tar.gz"
    $jdk_path = "jdk1.8.0_144"
  } elsif $jdk_version == 'Open_JDK_8' {
    $jdk_type = "jdk-8u192-ea-bin-b02-linux-x64-19_jul_2018.tar.gz"
    $jdk_path = "jdk1.8.0_192"
  }

  # Master-datasources.xml
  $wso2_reg_db = {
    url               => 'jdbc:mysql://CF_RDS_URL:3306/WSO2AM_COMMON_DB?autoReconnect=true&amp;useSSL=false',
    username          => 'CF_DB_USERNAME',
    password          => 'CF_DB_PASSWORD',
    driver_class_name => 'com.mysql.jdbc.Driver',
  }

  $wso2_um_db = {
    url               => 'jdbc:mysql://CF_RDS_URL:3306/WSO2AM_COMMON_DB?autoReconnect=true&amp;useSSL=false',
    username          => 'CF_DB_USERNAME',
    password          => 'CF_DB_PASSWORD',
    driver_class_name => 'com.mysql.jdbc.Driver',
  }

  $wso2_am_db = {
    url               => 'jdbc:mysql://CF_RDS_URL:3306/WSO2AM_APIMGT_DB?autoReconnect=true&amp;useSSL=false',
    username          => 'CF_DB_USERNAME',
    password          => 'CF_DB_PASSWORD',
    driver_class_name => 'com.mysql.jdbc.Driver',
  }

  $api_store = {
    url        => 'https://CF_ELB_DNS_NAME:${mgt.transport.https.port}/store',
    server_url => 'https://CF_ELB_DNS_NAME:${mgt.transport.https.port}${carbon.context}services/',
    username   => '${admin.username}',
    password   => '${admin.password}'
  }

  $api_publisher = {
    url => 'https://CF_ELB_DNS_NAME:${mgt.transport.https.port}/publisher'
  }

  $api_gateway = {
    server_url          => 'https://localhost:${mgt.transport.https.port}${carbon.context}services/',
    username            => '${admin.username}',
    password            => '${admin.password}',
    gateway_endpoint    => 'http://CF_ELB_DNS_NAME:${http.nio.port},https://CF_ELB_DNS_NAME:${https.nio.port}',
    gateway_ws_endpoint => 'ws://${carbon.local.ip}:9099'
  }

  $clustering               = {
    enabled => true,
  }

  # Carbon.xml
  $ports_offset = 0

  # user-mgt.xml
  $enable_scim = true

  $key_store = {
    type         => 'JKS',
    password     => 'wso2carbon',
    key_alias    => 'wso2carbon',
    location     => '${carbon.home}/repository/resources/security/wso2carbon.jks',
    key_password => 'wso2carbon',
  }

  $trust_store = {
    location => '${carbon.home}/repository/resources/security/client-truststore.jks',
    type     => 'JKS',
    password => 'wso2carbon'
  }
}