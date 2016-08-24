####################################################
#!!
#! @description: Wrapper over the files/create_folder operation.
#! @input directory_name: name of directory to be created
#! @output error_msg: error message
#!!#
####################################################

namespace: Fol
imports:
  files: io.cloudslang.base.files
  print: io.cloudslang.base.print
flow:
  name: create_directory11
  inputs:
    - directory_name
  workflow:
    - print_start:
        do:
          print.print_text:
            - text: "${'Creating directory ' + directory_name}"
    - create_directory:
        do:
          files.create_folder:
            - folder_name: '${directory_name}'
        publish:
          - message
  outputs:
    - error_msg: "${'Failed to create directory with name ' + directory_name + ',error is ' + message}"
extensions:
  graph:
    steps:
      print_start:
        x: 84
        y: 159
      create_directory:
        x: 300
        y: 100
    results:
      SUCCESS:
        f82ee9bc-e94d-fdce-48a3-54aaeb9d76bf:
          x: 500
          y: 100
