#- CENTER PROCEDURE OF APADEMIDE CORE

apademide:
  type: procedure
  debug: false
  definitions: INPUT_PROC|INPUT_DATA
  script:
  # Stops if APADEMIDE CORE isn't enabled
  - if !<server.has_flag[_APA_CORE_FLAG.INNIT]>:
    - run apa_core_debug "context:NO_APA|APADEMIDE CORE's procedures"
    - determine NULL

  # If no proc has been defined in the input, always errors
  - if !<[INPUT_PROC].exists>:
    - run apa_core_debug "context:ERROR|You must input a procedure name to use APADEMIDE CORE's procedures."
    - determine NULL

  # Checks the input proc name actually exists
  - define PROC <script.data_key[subprocedures.<[INPUT_PROC]>].if_null[NULL]>
  - if <[PROC]> == NULL:
    - run apa_core_debug "context:ERROR|No procedure named '<[INPUT_PROC].if_null[NULL]>' exists in APADEMIDE CORE."
    - determine NULL

  # Determines the status of transfered data
  - define DATA <[INPUT_DATA].if_null[NULL]>
  - if <[DATA]> == NULL:
    - define HAS_DATA false
  - else:
    - define HAS_DATA true
    # Tries to parse the input as a map to handle string-input maps
    - define DATA <map[<[DATA]>].if_null[<[DATA]>]>

  # If the proc has required data, validates it or errors
  - define REQUIRED_DATA <[PROC].get[required_data].if_null[NULL]>
  - if <[REQUIRED_DATA]> != NULL:
    - if !<[HAS_DATA]>:
      - run apa_core_debug "context:ERROR|Error in procedure '<[INPUT_PROC]>': No data has been inputted. (Required keys: <[REQUIRED_DATA].parse_value_tag[<&lt><[PARSE_VALUE].before[|]><&gt>].to_list[: ].comma_separated>)"
      - determine NULL
    - define RESULTS <proc[apa_core_proc_input_validator].context[<list_single[<[DATA]>].include_single[<[REQUIRED_DATA]>]>]>
    - if !<[RESULTS.OK].is_truthy>:
      - run apa_core_debug "context:ERROR|Error in procedure '<[INPUT_PROC]>': <[RESULTS.MESSAGE]>"
      - determine NULL
    - define <[DATA]> <[RESULTS.DATA]>

  - inject <script> path:subprocedures.<[INPUT_PROC]>.script

  subtasks:
    helpers:
      requires_data:
        - if !<[HAS_DATA]>:
          - run apa_core_debug "context:ERROR|Some context input is required to use procedure '<[INPUT_PROC]>'. (<&lt>proc[APADEMIDE].context[<[INPUT_PROC]>|<red>{<[REQUIRED_DATA_TYPE].if_null[missing data here]>}<white>]<&gt>)"
          - determine NULL


  subprocedures:
    # # APADEMIDE CORE # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          APADEMIDE CORE
    # Returns APADEMIDE CORE's config map
    config:
      script:
        # - inject <script> path:subtasks.helpers.requires_data
        - determine <server.flag[_APA_CORE_FLAG.CONFIG]>
    # Returns APADEMIDE CORE's root flag name (determined in the config)
    root:
      script:
        - determine <server.flag[_APA_CORE_FLAG.ROOT]>
    # Returns wether debug is enabled for APADEMIDE CORE
    debug:
      script:
        - determine <server.flag[_APA_CORE_FLAG.CONFIG.CONSOLE.DEBUG]>

    # Returns APADEMIDE CORE's root permission for player commands
    permissions_root:
      script:
        - determine <proc[APADEMIDE].context[config].deep_get[commands.permissions.root]>
    # Returns a cuboidtag centered at the given location with the given size

    # # LOCATIONS # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #           LOCATIONS

    #- SUB-SUBPROCEDURES related to locations
    # A few utils to edit and manage locations
    # Note that location inputs may also be objects that return a location with '.location' (entities, players, …)
    location:
      # Creates a cuboid of the size specified
      # with .expand, which means it expands by the specified size *in all directions*
      # (so the actual end size is "size * 2 + 1", theorically)
      to_cuboid:
        required_data:
          LOCATION: location
          SIZE: integer
        script:
          - determine <[DATA.LOCATION].to_cuboid[<[DATA.LOCATION]>].expand[<[DATA.SIZE].if_null[0]>]>

    # # ELEMENTS # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          ELEMENTS

    #- SUB-SUBPROCEDURES related to elements
    # A few utils to edit and manage elements (as strings)
    element:
      # Returns the input value cut at the specified length
      ellipsis:
        required_data:
          LENGTH: integer
          STRING: any
        script:
          - if <[DATA.STRING].length> <= <[DATA.LENGTH]>:
            - determine <[DATA.STRING]>
          - determine <[DATA.STRING].substring[0,<[DATA.LENGTH].sub[1]>]><[DATA.CHAR].if_null[…]>

    # # TASKS  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          TASKS

    #- SUB-SUBPROCEDURES related to tasks
    # They mainly but not only refer to specific task names easily
    task:
      debug:
        script:
          - determine apa_core_debug

    # # MODULES # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #           MODULES

    #- SUB-SUBPROCEDURES related to modules
    module:
      register:
        script:
          - determine apa_core_task_register_module

    # # UTILS # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #           UTILS

    #- SUB-SUBPROCEDURES that provide much utils of all kinds
    # Various utils
    utils:
      # Utils mainly providing glyphsets
      chars:
        # Only Alphabetical glyphs
        alpha:
          required_data:
            AS: enum|LIST,ELEMENT
          script:
            - choose <[DATA.CASE].if_null[LOWERCASE]>_<[DATA.AS]>:
              - case LOWERCASE_ELEMENT LOWER_ELEMENT:
                - determine abcdefghijklmnopqrstuvwxyz
              - case UPPERCASE_ELEMENT UPPER_ELEMENT:
                - determine ABCDEFGHIJKLMNOPQRSTUVWXYZ
              - case ALL_ELEMENT ANY_ELEMENT:
                - determine abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
              - case LOWERCASE_LIST LOWER_LIST:
                - determine <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z]>
              - case UPPERCASE_LIST UPPER_LIST:
                - determine <list[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z]>
              - case ALL_LIST ANY_LIST:
                - determine <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z]>
              - default:
                - determine abcdefghijklmnopqrstuvwxyz
        alphanum:
          required_data:
            AS: enum|LIST,ELEMENT
          script:
            - choose <[DATA.CASE].if_null[LOWERCASE]>_<[DATA.AS]>:
              - case LOWERCASE_ELEMENT LOWER_ELEMENT:
                - determine abcdefghijklmnopqrstuvwxyz0123456789
              - case UPPERCASE_ELEMENT UPPER_ELEMENT:
                - determine ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
              - case ALL_ELEMENT ANY_ELEMENT:
                - determine abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
              - case LOWERCASE_LIST LOWER_LIST:
                - determine <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|0|1|2|3|4|5|6|7|8|9]>
              - case UPPERCASE_LIST UPPER_LIST:
                - determine <list[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|0|1|2|3|4|5|6|7|8|9]>
              - case ALL_LIST ANY_LIST:
                - determine <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|0|1|2|3|4|5|6|7|8|9]>
              - default:
                - determine abcdefghijklmnopqrstuvwxyz0123456789
        # Only numbers
        num:
          script:
            - determine 0123456789
