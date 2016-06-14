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
  lists: io.cloudslang.base.lists

flow:
  name: get_failed_build
  inputs:
    - token:
        sensitive: true
    - protocol
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
    - username
    - project
    - branch
    - content_type:
        default: "application/json"
        private: true
    - headers:
        default: "Accept:application/json"
        private: true
    - committer_email
    - supervisor
    - hostname
    - port
    - from
    - to
    - cc:
        required: false

  workflow:
    - get_failed_build:
        do:
          rest.http_client_get:
            - url: ${protocol + '://' + host + '/api/v1/project/' + username + '/' + project + '/tree/' + branch + '?circle-token=' + token + '&limit=1&filter=failed'}
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
          - SUCCESS: match_if_failed
          - FAILURE: FAILURE

    - match_if_failed:
        do:
          lists.compare_lists:
            - list_1: ${return_result}
            - list_2: '[]'

        navigate:
          - SUCCESS: mail_success_build
          - FAILURE: get_username

    - get_username:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'username']

        publish:
          - username: ${value}
          - error_message

        navigate:
          - SUCCESS: get_committer_email
          - FAILURE: FAILURE

    - get_committer_email:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'committer_email']

        publish:
          - committer_email: ${value}
          - error_message

        navigate:
          - SUCCESS: get_branch
          - FAILURE: FAILURE

        navigate:
          - SUCCESS: get_branch
          - FAILURE: FAILURE

    - get_branch:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'branch']

        publish:
          - branch: ${value}
          - error_message

        navigate:
          - SUCCESS: get_subject
          - FAILURE: FAILURE

    - get_subject:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'subject']

        publish:
          - ci_subject: ${value}
          - error_message

        navigate:
          - SUCCESS: get_build_num
          - FAILURE: FAILURE

    - get_build_num:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'build_num']

        publish:
          - build_num: ${value}
          - error_message

        navigate:
          - SUCCESS: get_commit
          - FAILURE: FAILURE

    - get_commit:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'vcs_revision']

        publish:
          - commit: ${value}
          - error_message

        navigate:
          - SUCCESS: get_outcome
          - FAILURE: FAILURE

    - get_outcome:
        do:
          json.get_value:
            - json_input: ${return_result}
            - json_path: [0,'outcome']

        publish:
          - outcome: ${value}
          - error_message

        navigate:
          - SUCCESS: mail_failed_build
          - FAILURE: FAILURE

    - mail_success_build:
         do:
           mail.send_mail:
             - hostname
             - port
             - from
             - to: ${committer_email}
             - subject: ${'[Build' + '] ' + 'Success:' + username + '/' + project + '/' + branch}
             - body: ${'Latest build finished successfully.'}
             - username
             - password

         navigate:
                - SUCCESS: SUCCESS
                - FAILURE: FAILURE

    - mail_failed_build:
         do:
           mail.send_mail:
             - hostname
             - port
             - from
             - to: ${committer_email}
             - cc: ${supervisor}
             - subject: ${'[Build' + '] ' + 'Failed:' + username + '/' + project + '/' + branch}
             - htmlEmail: True
             - body: >
                  ${'<p align=center>' + 'Build failure on repository:' + project + '-' + 'branch:' + branch + '</p>'
                  '<table align="center" border="1" cellpadding="0" cellspacing="0" width="400">' +
                  '<tr>' +
                  '<td>' +
                  'Repository:' +
                  '</td>' +
                  '<td bgcolor="#70bbd9">' +
                  project +
                  '</td>' +
                  '</tr>' +
                  '<tr>' +
                  '<td>' +
                  'Branch:' +
                  '</td>' +
                  '<td>' +
                  branch +
                  '</td>' +
                  '</tr>' +
                  '<tr>' +
                  '<td>' +
                  'Username:' +
                  '</td>' +
                  '<td>' +
                  username +
                  '</td>' +
                  '</tr>' +
                  '<tr>' +
                  '<td>' +
                  'Commiter email:' +
                  '</td>' +
                  '<td>' +
                  committer_email +
                  '</td>' +
                  '</tr>' +
                  '<tr>' +
                  '<td>' +
                  'Subject:' +
                  '</td>' +
                  '<td>' +
                  ci_subject +
                  '</td>' +
                  '</tr>' +
                  '<tr>' +
                  '<td>' +
                  'Status:' +
                  '</td>' +
                  '<td bgcolor="#ee4c50">' +
                  outcome +
                  '</td>' +
                  '</tr>' +
                  '</table>'}
         navigate:
           - SUCCESS: SUCCESS
           - FAILURE: FAILURE

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code

  results:
    - SUCCESS
    - FAILURE
