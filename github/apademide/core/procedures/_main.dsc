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
  # If no proc has been defined, always errors
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
    - define RESULTS <proc[apa_core_proc_input_validator].context[<list_single[<[DATA]>].include_single[<[REQUIRED_DATA]>]>]>
    - if !<[RESULTS.OK].is_truthy>:
      - run apa_core_debug "context:ERROR|Error in APADEMIDE CORE's procedure '<[INPUT_PROC]>': <[RESULTS.MESSAGE]>"
      - determine NULL
    - define <[DATA]> <[RESULTS.DATA]>

  - inject <script> path:subprocedures.<[INPUT_PROC]>.script

  subtasks:
    requires_data:
      - if !<[HAS_DATA]>:
        - run apa_core_debug "context:ERROR|Some context input is required to use APADEMIDE CORE's procedure '<[INPUT_PROC]>'. (<&lt>proc[APADEMIDE].context[<[INPUT_PROC]>|<red>{<[REQUIRED_DATA_TYPE].if_null[missing data here]>}<white>]<&gt>)"
        - determine NULL
  subprocedures:
    # Returns APADEMIDE CORE's config map
    config:
      script:
        # - inject <script> path:data.helpers.requires_data
        - determine <server.flag[_APA_CORE_FLAG.CONFIG]>
    # Returns APADEMIDE CORE's root flag name (determined in the config)
    root:
      script:
        - determine <server.flag[_APA_CORE_FLAG.ROOT]>
    # Returns APADEMIDE CORE's root permission for player commands
    permissions_root:
      script:
        - determine <proc[APADEMIDE].context[config].deep_get[commands.permissions.root]>
    # Returns a cuboidtag centered at the given location with the given size
    location_to_cuboid:
      required_data:
        LOCATION: location
        SIZE: integer
      script:
        - determine <[DATA.LOCATION].to_cuboid[<[DATA.LOCATION]>].expand[<[DATA.SIZE].if_null[0]>]>
    # Returns the input value cut at the specified length
    ellipsis:
      required_data:
        LENGTH: integer
        STRING: any
      script:
        - if <[DATA.STRING].length> <= <[DATA.LENGTH]>:
          - determine <[DATA.STRING]>
        - determine <[DATA.STRING].substring[0,<[DATA.LENGTH].sub[1]>]><[DATA.CHAR].if_null[…]>



# Takes a map of values and a map of validators and checks wether all values exists and have expected type
apa_core_proc_input_validator:
  type: procedure
  debug: false
  definitions: INPUT_DATA|VALIDATORS
  script:
    # New definition where updated values will be stored
    - define NEW_DATA <[INPUT_DATA]>
    - foreach <[VALIDATORS]> as:TYPE key:NAME:

      # Grab the value in the input map, if it exists // Error if no
      - define VALUE <[INPUT_DATA].get[<[NAME]>].if_null[NULL]>

      # If the data isn't set
      - if <[VALUE]> == NULL:
        - definemap RESULT:
            OK: false
            CAUSE: NULL_VALUE
            MISSING: <[NAME]>
            REQUIRED_TYPE: <[TYPE]>
            MESSAGE: Required key '<[NAME]>' isn't provided.
        - determine <[RESULT]>

      # Validates the type of input
      - choose <[TYPE]>:

        - case location:
          # If the input value as location is fine OR the value has a location (player, entity, …), it's fine. NULL otherwise
          - define PARSED_VALUE <[VALUE].as[location].if_null[<[VALUE].location.if_null[NULL]>]>
          - if <[PARSED_VALUE]> == NULL:
            - definemap RESULT:
                OK: false
                CAUSE: WRONG_TYPE
                REQUIRED_TYPE: location
                GIVEN_TYPE: <[VALUE].object_type>
                MESSAGE: The '<[NAME]>' key should be a location. '<[VALUE].object_type>' given. (Input: <proc[APADEMIDE].context[ellipsis|STRING=<[VALUE]>;LENGTH=50]>)
            - determine <[RESULT]>
          - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[PARSED_VALUE]>]>

        - case integer:
          - if !<[VALUE].is_integer>:
            - definemap RESULT:
                OK: false
                CAUSE: WRONG_TYPE
                REQUIRED_TYPE: integer
                GIVEN_TYPE: <[VALUE].object_type>
                MESSAGE: The '<[NAME]>' key should be an integer. '<[VALUE].object_type>' given. (Input: <proc[APADEMIDE].context[ellipsis|STRING=<[VALUE]>;LENGTH=50]>)
            - determine <[RESULT]>

        - case any:
          - if !<[VALUE].exists> || <[VALUE].is_empty.if_null[false]> || <[VALUE].length> == 0:
            - definemap RESULT:
                OK: false
                CAUSE: EMPTY_INPUT
                REQUIRED_TYPE: any
                GIVEN_TYPE: <[VALUE].object_type>
                MESSAGE: The '<[NAME]>' key should be set to anything not empty. (Input: <proc[APADEMIDE].context[ellipsis|STRING=<[VALUE].length.is_more_than[0].if_true[<[VALUE]>].if_false[<&lt>empty<&gt>]>;LENGTH=50]>)
            - determine <[RESULT]>

    - determine <map[OK=true].with[DATA].as[<[NEW_DATA]>]>
