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
  mail: io.cloudslang.base.mail


flow:
  name: get_branches_build_failure
  inputs:
    - token:
        sensitive: true
    - protocol:
        default: "https"
    - host:
        default: "circleci.com"
        private: true
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
    - username
    - project
    - committer_email
    - branch:
        default: ''
    - branches:
        default: ''
    - supervisor
    - hostname
    - port
    - from
    - to
    - cc:
        required: false

  workflow:
    - get_project_branches:
        do:
          get_project_branches:
            - url: ${protocol + '://' + host + '/api/v1/projects?circle-token=' + token}
            - protocol
            - host
            - token
            - proxy_host
            - proxy_port
            - trust_all_roots: "false"
            - x_509_hostname_verifier: "strict"
            - trust_keystore
            - trust_password
            - keystore
            - keystore_password
            - content_type
            - headers

        publish:
          - branches
          - error_message
          - return_result

        navigate:
          - SUCCESS: get_branches_build_failure
          - FAILURE: FAILURE

    - get_branches_build_failure:
        loop:
          for: branch in branches
          do:
            get_failed_build:
              - url: ${protocol + '://' + host + '/api/v1/project/' + username + '/' + project + '/tree/' + branch + '?circle-token=:' + token + '&limit=1&filter=failed'}
              - token
              - protocol
              - host
              - branch
              - committer_email
              - proxy_host
              - proxy_port
              - trust_all_roots: "false"
              - x_509_hostname_verifier: "strict"
              - trust_keystore
              - trust_password
              - keystore
              - keystore_password
              - username
              - project
              - branches
              - supervisor
              - hostname
              - port
              - from
              - to
              - cc: ${supervisor}

          publish:
            - return_result
            - return_code
            - status_code
            - error_message

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code

  results:
    - SUCCESS
    - FAILURE
