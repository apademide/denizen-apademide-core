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

  # Tries to parse the input as a map to handle string-input maps
  - if <[DATA]> != NULL:
    - define DATA <map[<[DATA]>].if_null[<[DATA]>]>

  # If the proc has required data, validates it or errors
  - define INPUT_DATA <[PROC].get[input_data].if_null[NULL]>
  - if <[INPUT_DATA]> != NULL:
    # Validates all inputs thanks to the validator proc
    - define RESULTS <proc[apa_core_proc_input_validator].context[<list_single[<[DATA]>].include_single[<[INPUT_DATA]>]>]>
    - if !<[RESULTS.OK].is_truthy>:
      - run apa_core_debug "context:ERROR|Error in procedure '<[INPUT_PROC]>': <[RESULTS.MESSAGE]>"
      - determine NULL
    - define <[DATA]> <[RESULTS.DATA]>

  - inject <script> path:subprocedures.<[INPUT_PROC]>.script

  # Quicks helpers to inject in the subprocs to achieve various goals or get various data
  subtasks:
    helpers:
      use_data:
      - define PROC_DATA <script[apa_core_procedures_data]>


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

    # As the name implies, it's a helper subprocedure.
    # You can use <proc[apademide].context[help]>
    # with or without additionnal context (consisting of PATH:A.FULL.OR.PARTIAL.PATH.TO.A.SUBPROC)
    # to know what proc exists, and how to use it
    help:
      input_data:
        PATH:
          type: path
          null: true
      script:
        # Get this script's SUBPROCEDURES key (as in, the map of all procedures available)
        - define MAP <script.data_key[SUBPROCEDURES]>

        # If there is no path input, returns all the root procs
        - if !<[PATH].exists>:
          - determine "Available APADEMIDE CORE procedures and procedure categories are: <[MAP].keys.formatted>."

        # If the path is set, get the procedure at its position or NULL
        - define MAP <[MAP].deep_get[<[PATH]>].if_null[NULL]>

        # If the path returns null, stops there with an error message.
        - if <[MAP]> == NULL:
          - determine "There is no APADEMIDE CORE's procedure named '<[PATH]>'. Use the HELP procedure without context to get all root procedures."

        # If the path ends with on the the defined value, it means it conducts directly "inside a proc"
        # So the path is set back to one step baackward
        - if <list[script|input_data|help].contains[<[PATH].after_last[.]>]>:
          - define PATH <[PATH].before_last[.]>

        # If we can get the script key inside the path, it means it's a procedure already
        - if <[MAP].get[script].exists>:
          - determine "APADEMIDE CORE's procedure named '<[PATH]>' serves to: <[MAP].get[HELP].if_null[Unknown :( But it exists]>."
        # … and if we can't get the script key, by deduction it's a "category" of procs
        - determine "APADEMIDE CORE's category of procedures '<[PATH]>' contains: <[MAP].keys.formatted>."


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
        input_data:
          LOCATION:
            type: location
          SIZE:
            type: integer
        script:
          - determine <[DATA.LOCATION].to_cuboid[<[DATA.LOCATION]>].expand[<[DATA.SIZE].if_null[0]>]>

    # # ELEMENTS # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          ELEMENTS

    #- SUB-SUBPROCEDURES related to elements
    # A few utils to edit and manage elements (as strings)
    element:
      # Returns the input value cut at the specified length
      ellipsis:
        input_data:
          LENGTH:
            type: integer
          STRING:
            type: any
        script:
          - if <[DATA.STRING].length> <= <[DATA.LENGTH]>:
            - determine <[DATA.STRING]>
          - determine <[DATA.STRING].substring[0,<[DATA.LENGTH].sub[1]>]><[DATA.CHAR].if_null[…]>
      # Returns the input value as a "safe" element
      # i.e, French word Île (Island) becomes ILE, Garçon (Boy) becomes GARCON, Saint-André becomes SAINT_ANDRE)
      safe:
        input_data:
          CAPITALIZE:
            type: boolean


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
          input_data:
            AS:
              type: enum
              null: true
              enum: LIST|ELEMENT
            CASE:
              type: enum
              null: true
              enum: UPPERCASE|LOWERCASE|ALL
          script:
            - inject <script> path:subtasks.helpers.use_data
            - define CASE <[DATA.CASE].if_null[LOWERCASE]>
            - define AS <[DATA.AS].if_null[LIST]>
            - determine <[PROC_DATA].parsed_key[CHARS.ALPHA.<[CASE]>.<[AS]>]>
        alphanum:
          input_data:
            AS:
              type: enum
              null: true
              enum: LIST|ELEMENT
            CASE:
              type: enum
              null: true
              enum: UPPERCASE|LOWERCASE|ALL
          script:
            - inject <script> path:subtasks.helpers.use_data
            - define CASE <[DATA.CASE].if_null[LOWERCASE]>
            - define AS <[DATA.AS].if_null[LIST]>
            - determine <[PROC_DATA].parsed_key[CHARS.ALPHANUM.<[CASE]>.<[AS]>]>
        num:
          input_data:
            AS:
              type: enum
              null: true
              enum: LIST|ELEMENT
          script:
            - inject <script> path:subtasks.helpers.use_data
            - define AS <[DATA.AS].if_null[LIST]>
            - determine <[PROC_DATA].parsed_key[CHARS.NUM.<[AS]>]>
