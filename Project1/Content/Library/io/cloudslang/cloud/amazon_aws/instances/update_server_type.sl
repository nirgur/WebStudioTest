#   (c) Copyright 2016 Hewlett-Packard Enterprise Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#!!
#! @description: Performs an Amazon Web Services Elastic Compute Cloud (EC2) command to update the type of a specified instance
#! @input provider: the cloud provider on which the instance is - Default: 'amazon'
#! @input endpoint: the endpoint to which first request will be sent - Default: 'https://ec2.amazonaws.com'
#! @input identity: optional - the Amazon Access Key ID
#! @input credential: optional - the Amazon Secret Access Key that corresponds to the Amazon Access Key ID
#! @input proxy_host: optional - the proxy server used to access the provider services
#! @input proxy_port: optional - the proxy server port used to access the provider services - Default: '8080'
#! @input region: optional - the region where the server (instance) to be updated can be found. "regions/list_regions" operation
#!                           can be used in order to get all regions - Default: 'us-east-1'
#! @input server_id: the ID of the server (instance) you want to update
#! @input server_type: optional - the new server type to be used when updating the instance. The complete list of instance
#!                                types can be found at: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html
#!                              - Example: 't2.medium', 'm3.large' - Default: 't2.micro'
#! @input operation_timeout: optional - the total time (in milliseconds) that operation will wait to complete the execution
#! @input pooling_interval: optional - the time (in milliseconds) that operation will wait until next check of the instance
#!                                     state
#! @output return_result: contains the exception in case of failure, success message otherwise
#! @output return_code: '0' if operation was successfully executed, '-1' otherwise
#! @output error_message: error message if there was an error when executing, empty otherwise
#! @result SUCCESS: the server (instance) was successfully updated
#! @result FAILURE: an error occurred when trying to update a server (instance)
#!!#
####################################################
namespace: io.cloudslang.cloud.amazon_aws.instances

operation:
  name: update_server_type

  inputs:
    - provider: 'amazon'
    - endpoint: 'https://ec2.amazonaws.com'
    - identity:
        default: ''
        required: false
        sensitive: true
    - credential:
        default: ''
        required: false
        sensitive: true
    - proxy_host:
        required: false
    - proxyHost:
        default: ${get("proxy_host", "")}
        private: true
    - proxy_port:
        required: false
    - proxyPort:
        default: ${get("proxy_port", "8080")}
        private: true
    - region:
        default: 'us-east-1'
        required: false
    - server_id
    - serverId: ${server_id}
    - server_type:
        required: false
    - serverType:
        default: ${get("server_type", "")}
        private: true
    - operation_timeout:
        required: false
    - operationTimeout:
        default: ${get("operation_timeout", "")}
        private: true
    - pooling_interval:
        required: false
    - poolingInterval:
        default: ${get("pooling_interval", "")}
        private: true

  java_action:
    gav: 'io.cloudslang.content:score-jClouds:0.0.4'
    class_name: io.cloudslang.content.jclouds.actions.instances.UpdateServerTypeAction
    method_name: execute

  outputs:
    - return_result: ${returnResult}
    - return_code: ${returnCode}
    - exception: ${'' if exception not in locals() else exception}

  results:
    - SUCCESS: ${returnCode == '0'}
    - FAILURE
