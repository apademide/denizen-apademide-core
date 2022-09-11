
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
    - choose <[TYPE].before[|]>:

      - case location:
        # If the input value as location is fine OR the value has a location (player, entity, …), it's fine. NULL otherwise
        - define PARSED_VALUE <[VALUE].as[location].if_null[<[VALUE].location.if_null[NULL]>]>
        - if <[PARSED_VALUE]> == NULL:
          - definemap RESULT:
              OK: false
              CAUSE: WRONG_TYPE
              REQUIRED_TYPE: location
              GIVEN_TYPE: <[VALUE].object_type>
              MESSAGE: The '<[NAME]>' key should be a location. '<[VALUE].object_type>' given. (Input: <proc[APADEMIDE].context[element.ellipsis|STRING=<[VALUE]>;LENGTH=50]>)
          - determine <[RESULT]>
        - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[PARSED_VALUE]>]>

      - case integer:
        - if !<[VALUE].is_integer>:
          - definemap RESULT:
              OK: false
              CAUSE: WRONG_TYPE
              REQUIRED_TYPE: integer
              GIVEN_TYPE: <[VALUE].object_type>
              MESSAGE: The '<[NAME]>' key should be an integer. '<[VALUE].object_type>' given. (Input: <[VALUE].length.is_more_than[0].if_true[<proc[APADEMIDE].context[element.ellipsis|STRING=<[VALUE]>;LENGTH=50]>].if_false[<&lt>empty<&gt>]>)
          - determine <[RESULT]>

      - case any:
        - if !<[VALUE].exists> || <[VALUE].is_empty.if_null[false]> || <[VALUE].length> == 0:
          - definemap RESULT:
              OK: false
              CAUSE: EMPTY_INPUT
              REQUIRED_TYPE: any
              GIVEN_TYPE: <[VALUE].object_type>
              MESSAGE: The '<[NAME]>' key should be set to anything not empty. (Input: <[VALUE].length.is_more_than[0].if_true[<proc[APADEMIDE].context[element.ellipsis|STRING=<[VALUE]>;LENGTH=50]>].if_false[<&lt>empty<&gt>]>)
          - determine <[RESULT]>

      - case enum:
        - define LIST <[TYPE].after[|].split[,]>
        - if !<[LIST].contains[<[VALUE]>]>:
          - definemap RESULT:
              OK: false
              CAUSE: NOT_IN_ENUM
              VALID_OPTIONS: <[LIST].formatted>
              GIVEN_OPTION: <[VALUE]>
              MESSAGE: Possible values for '<[NAME]>' key: <[LIST].formatted>. (Input: <[VALUE].length.is_more_than[0].if_true[<proc[APADEMIDE].context[element.ellipsis|STRING=<[VALUE]>;LENGTH=50]>].if_false[<&lt>empty<&gt>]>)
          - determine <[RESULT]>
  - determine <map[OK=true].with[DATA].as[<[NEW_DATA]>]>
