#- CENTER PROCEDURE OF APADEMIDE CORE

apademide:
  type: procedure
  debug: false
  definitions: INPUT_A|INPUT_B
  script:
  # Stops if APADEMIDE CORE isn't enabled
  - if !<server.has_flag[_APA_CORE_FLAG.INIT]>:
    - run apa_core_debug "context:NO_APA|APADEMIDE CORE's procedures"
    - determine NULL

  
  # If there's only one def set, it means the input data in that case is actually the proc without data input
  - if !<[INPUT_B].exists>:
    # If no input is set, always errors
    - if !<[INPUT_A].exists>:
      - run apa_core_debug "context:ERROR|You must input a procedure name to use APADEMIDE CORE's procedures."
      - determine NULL
    - define INPUT_PROC <[INPUT_A]>
  # If INPUT_B exists, INPUT_A exists too
  # In which case, we try to determine which one is which
  - else:
    # Tries to parse the first input as a map (which in most cases should be the actual data input with format <[THING].proc[APADEMIDE].context[<[PROC]>]>)
    - define MAP <map[<[INPUT_A]>].if_null[NULL]>
    # If it was null, …
    - if <[MAP]> == NULL:
      # Try again with second INPUT…
      - define MAP <map[<[INPUT_B]>].if_null[NULL]>
      # If still NULL, it means no input is a valid map which isn't normal if both defs were specified, so error
      - if <[MAP]> == NULL:
        - run apa_core_debug "context:ERROR|Couldn't determine which input was which in APADEMIDE CORE's procedure. (Input A: <[INPUT_A]>, Input B: <[INPUT_B]>)"
        - determine NULL
      # If map is valid, it means INPUT_B is the data and INPUT_A the proc
      - define INPUT_DATA <[MAP]>
      - define INPUT_PROC <[INPUT_A]>
      - run apa_core_debug "context:LOG|Procedure determined INPUT A was the procedure (<[INPUT_A]>) and INPUT B was the data (<[INPUT_B]>)."
    # else it means the map is valid, which means INPUT_A is the data and INPUT_B the proc
    - else:
      - define INPUT_DATA <[MAP]>
      - define INPUT_PROC <[INPUT_B]>
      - run apa_core_debug "context:LOG|Procedure determined INPUT B was the procedure (<[INPUT_B]>) and INPUT A was the data (<[INPUT_A]>)."


  # Checks the input proc name actually exists
  - define PROC <script.data_key[subprocedures.<[INPUT_PROC]>].if_null[NULL]>
  - if <[PROC]> == NULL:
    - run apa_core_debug "context:ERROR|No procedure named '<[INPUT_PROC]>' exists in APADEMIDE CORE."
    - determine NULL
  - if !<[PROC].get[script].exists>:
    - run apa_core_debug "context:ERROR|'<[INPUT_PROC]>' is a category of procedures, not a procedure."
    - determine NULL
  # Determines the status of transfered data
  - define DATA <[INPUT_DATA].if_null[NULL]>

  # Tries to parse the input as a map to handle string-input maps
  - if <[DATA]> != NULL:
    - define DATA <map[<[DATA]>].if_null[<[DATA]>]>

  # If the proc has required data, validates it or errors
  - define REQUIRED_DATA <[PROC].get[input_data].if_null[NULL]>
  - if <[REQUIRED_DATA]> != NULL:
    # Validates all inputs thanks to the validator proc
    - define RESULTS <proc[apa_core_proc_input_validator].context[<list_single[<[DATA]>].include_single[<[REQUIRED_DATA]>]>]>
    - if !<[RESULTS.OK].is_truthy>:
      - run apa_core_debug "context:ERROR|Error in procedure '<[INPUT_PROC]>': <[RESULTS.MESSAGE]>"
      - determine NULL
    - define DATA <[RESULTS.DATA]>
  - inject <script> path:subprocedures.<[INPUT_PROC]>.script

  # Quicks helpers to inject in the subprocs to achieve various goals or get various data
  subtasks:
    helpers:
      use_data:
      - define PROC_DATA <script[apa_core_data]>


  subprocedures:
    # # APADEMIDE CORE # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          APADEMIDE CORE
    # Returns APADEMIDE CORE's config map
    config:
      script:
        - determine <server.flag[_APA_CORE_FLAG.CONFIG]>
    # Returns APADEMIDE CORE's internal config script
    internal_config:
      script:
        - determine <server.flag[_APA_CORE_FLAG.INTERNAL_CONFIG_SCRIPT]>
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
        - determine <server.flag[_APA_CORE_FLAG.CONFIG.COMMANDS.PERMISSIONS.ROOT]>
    # Returns the given path in APADEMIDE CORE's data script
    get_data:
      input_data:
        PATH:
          type: path
        PARSED:
          type: bool
          null: true
          fallback: false
      script:
        - if <[DATA.PARSED]>:
          - determine <script[apa_core_data].parsed_key[<[DATA.PATH]>].if_null[NULL]>
        - determine <script[apa_core_data].data_key[<[DATA.PATH]>].if_null[NULL]>

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
        - define PATH <[DATA.PATH].if_null[NULL]>

        # If there is no path input, returns all the root procs
        - if <[PATH]> == NULL:
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
          - determine "What APADEMIDE CORE's procedure named '<[PATH]>' does is: <[MAP].get[HELP].parsed.if_null[Unknown :( But it exists !]>"
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
        help: Creates a cuboid of the given size centered at the given location.
        input_data:
          LOCATION:
            type: location
          SIZE:
            type: integer
            null: true
            fallback: 2
        script:
          - determine <[DATA.LOCATION].to_cuboid[<[DATA.LOCATION]>].expand[<[DATA.SIZE]>]>

    # # ELEMENTS # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          ELEMENTS

    #- SUB-SUBPROCEDURES related to elements
    # A few utils to edit and manage elements
    element:
      # Returns the input value cut at the specified length
      ellipsis:
        help: Shortens a string and adds an ellipsis if the string is too long.
        input_data:
          LENGTH:
            type: integer
          STRING:
            type: any
          CHAR:
            type: any
            null: true
            fallback: …
        script:
          - if <[DATA.STRING].length> <= <[DATA.LENGTH]>:
            - determine <[DATA.STRING]>
          - determine <[DATA.STRING].substring[0,<[DATA.LENGTH].sub[1]>]><[DATA.CHAR]>
      # Returns the input value as a "safe" element
      # i.e, French word Île (Island) becomes ILE, Garçon (Boy) becomes GARCON, Saint-André becomes SAINT_ANDRE)
      # and "OI*+Uskjnj2j12owu1na a      a a sjha######ioduq≠}≠w (+yoijd" becomes OIUSKJNJ2J12OWU1NA_A_A_A_SJHAIODUQ_W_YOIJD
      safe:
        help: Converts an element to a <&dq>safe<&dq> version of it without spaces, unicodes and separated by underscores. Useful to generate <&dq>safe IDs<&dq> or flag names for exemple.
        input_data:
          CAPITALIZE:
            type: bool
            null: true
            fallback: true
          STRING:
            type: any
        script:
          # Get the map containing chars to replace
          - define SAFE_MAP <map[PATH=CHARS.SAFE.EQUIVALENTS].proc[apademide].context[get_data]>
          # Put in a simpler def for convenience
          - define RESULT <[DATA.STRING]>
          # Replace all "complicated" chars by their basic equivalent
          # éè -> e, $ -> s, …
          - foreach <[SAFE_MAP]> as:LIST key:REPLACEMENT:
            - foreach <[LIST]> as:NEEDLE:
              - define RESULT <[RESULT].replace_text[<[NEEDLE]>].with[<[REPLACEMENT]>]>
          # trim the result to remove remaining unwanted chars (unicodes, emojis, …)
          - define RESULT <[RESULT].trim_to_character_set[<map[PATH=CHARS.SAFE.ELEMENT].proc[apademide].context[get_data]>]>
          # split _, filter empty values and convert back to element to remove duplicated underscores
          - define RESULT <[RESULT].split[_].filter_tag[<[FILTER_VALUE].length.is_more_than[0]>].separated_by[_]>
          # Return the result capitalized or not depending on the input
          - if <[DATA.CAPITALIZE]>:
            - determine <[RESULT].to_uppercase>
          - determine <[RESULT]>
      is_safe:
        help: Returns a boolean whether the input string is already safe according to ELEMENT.SAFE's logic.
        input_data:
          STRING:
            type: any
        script:
          - if <[DATA.STRING]> == <[DATA.STRING].trim_to_character_set[<map[PATH=CHARS.SAFE.ELEMENT].proc[apademide].context[get_data]>].split[_].filter_tag[<[FILTER_VALUE].length.is_more_than[0]>].separated_by[_]>:
            - determine true
          - determine false
      trim_to_character_set:
        help: An advanced version of Denizen's same named tag, handling all chars instead of ASCII only.
        input_data:
          STRING:
            type: any
          SET:
            type: any
        script:
        - if <[DATA.SET].object_type> != LIST:
          - define DATA.SET <[DATA.SET].to_list>
        - define RESULT <empty>
        - foreach <[DATA.STRING].to_list> as:EL:
          - if <[EL]> in <[DATA.SET]>:
            - define RESULT <[RESULT]><[EL]>
        - determine <[RESULT]>
      matches_character_set:
        help: An advanced version of Denizen's same named tag, handling all chars instead of ASCII only.
        input_data:
          STRING:
            type: any
          SET:
            type: any
        script:
        - if <[DATA.SET].object_type> != LIST:
          - define DATA.SET <[DATA.SET].to_list>
        ## After some testing, this method seems to be slighty more efficient that the foreach loop
        # Aprox 1700-1800ms VS 1800-1950ms
        - define PARSED <[DATA.STRING].to_list.parse_tag[<[DATA.SET].contains[<[PARSE_VALUE]>]>]>
        - determine <[PARSED].contains[false].not>
        # - foreach <[DATA.STRING].to_list> as:EL:
        #   - if <[EL]> !in <[DATA.SET]>:
        #     - determine false
        # - determine true
        # Test tag:
        # <util.list_numbers_to[4500].parse_tag[<map[STRING=ABCDEFGHIJKLMNOPQRSTUVWXYZ+*ç%&/()=?`±“#Ç[];SET=ABCDEFGHIJKLMNOPQRSTUVWXYZ].proc[apademide].context[element.matches_character_set]>]>
    # # TASKS  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #          TASKS

    #- SUB-SUBPROCEDURES related to tasks
    # They mainly but not only refer to specific task names easily
    task:
      debug:
        script:
          - determine <script[apa_core_debug]>

    # # MODULES # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #           MODULES

    #- SUB-SUBPROCEDURES related to modules
    module:
      register:
        help: Returns the script tag you may inject to register a new APADEMIDE MODULE.
        script:
          - determine <script[apa_core_task_register_module]>
    # # MATHS # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #           MATHS
    #- SUB-SUBPROCEDURES that provide math utils
    math:
      prepare_formula:
        help: Takes an element input and converts it to a ready-to-use formula. (Mainly used by MATH.SPLIT_FORMULA for MATH.CALC)
        input_data:
          FORMULA:
            type: any
        script:
          - determine <proc[apa_core_proc_math_formula_prepare].context[<[DATA.FORMULA]>]>
      split_formula:
        help: Takes a prepared formula input and converts it to a list where each element is a formula's element. (Mainly used by MATH.CALC)
        input_data:
          FORMULA:
            type: any
        script:
          - determine <proc[apa_core_proc_math_formula_split].context[<[DATA.FORMULA]>]>
      calc:
        help: Parses a complex math formula and returns its result.
        input_data:
          FORMULA:
            type: any
        script:
          - define RESULT <proc[apa_core_proc_math_formula_calculate].context[<[DATA.FORMULA]>]>
          - if <[RESULT.OK]>:
            - determine <[RESULT.RESULT]>
          - run apa_core_debug context:ERROR|<[RESULT.MESSAGE]>
          - determine NULL
      # calculate:
      #   help: Calculates single-level math operations (1+1, 3*5-3, 2^4/5, no parenthesis).
      #   input_data:
      #     FORMULA:
      #       type: any
      #     CHECKED:
      #       type: bool
      #       null: true
      #       fallback: false
      #   script:
      #     - determine <[DATA.FORMULA].proc[apa_core_proc_calculate].context[<[DATA.CHECKED]>]>


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
              fallback: ELEMENT
              enum: LIST|ELEMENT
            CASE:
              type: enum
              null: true
              fallback: ALL
              enum: UPPERCASE|LOWERCASE|ALL
          script:
            - inject <script> path:subtasks.helpers.use_data
            - define CASE <[DATA.CASE]>
            - define AS <[DATA.AS]>
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
