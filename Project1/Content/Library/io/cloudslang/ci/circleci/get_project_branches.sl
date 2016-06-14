#   (c) Copyright 2016 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#


namespace: io.cloudslang.ci.circleci

imports:
  rest: io.cloudslang.base.http
  json: io.cloudslang.base.json
  lists: io.cloudslang.base.lists

flow:
  name: get_project_branches
  inputs:
    - token:
        sensitive: true
    - host:
        default: "circleci.com"
        private: true
    - protocol:
        default: "https"
    - proxy_host:
        required: false
    - proxy_port:
        default: "8080"
        required: false
    - trust_keystore:
        default: ${get_sp('io.cloudslang.base.http.trust_keystore')}
        required: false
    - trust_password:
        default: ${get_sp('io.cloudslang.base.http.trust_password')}
        required: false
        sensitive: true
    - keystore:
        default: ${get_sp('io.cloudslang.base.http.keystore')}
        required: false
    - keystore_password:
        default: ${get_sp('io.cloudslang.base.http.keystore_password')}
        required: false
        sensitive: true
    - content_type:
        default: "application/json"
        private: true
    - headers:
        default: "Accept:application/json"
        private: true

  workflow:
    - get_project_info:
        do:
          rest.http_client_get:
            - url: ${protocol + '://' + host + '/api/v1/projects?circle-token=' + token}
            - protocol
            - host
            - proxy_host
            - proxy_port
            - content_type
            - headers
            - trust_all_roots: "false"
            - x_509_hostname_verifier: "strict"
            - trust_keystore
            - trust_password
            - keystore
            - keystore_password

        publish:
          - return_result
          - return_code
          - status_code
          - error_message

        navigate:
          - SUCCESS: get_branches
          - FAILURE: FAILURE

    - get_branches:
        do:
          json.get_keys:
            - json_input: ${return_result}
            - json_path: [0, 'branches']

        publish:
          - branches: ${keys}
          - error_message

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code
    - branches

  results:
    - SUCCESS
    - FAILURE
