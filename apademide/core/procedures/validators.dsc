
# Takes a map of values and a map of validators and checks wether all values exists and have expected type
apa_core_proc_input_validator:
  type: procedure
  debug: false
  definitions: INPUT_DATA|VALIDATORS
  script:
  # Copy of the input data or an empty map
  # New values (possibly updated) will be stored in it, and is what gets determined
  - if <[INPUT_DATA]> == NULL:
    - define NEW_DATA <map>
  - else:
    - define NEW_DATA <[INPUT_DATA]>

  # Loops through all validators to check the value in the input map is valid
  # Looping through *validators* means values in the input map that don't
  # require getting checked (as in, the one who have no pair key in the validator map)
  # won't be touched at all and returned as is
  - foreach <[VALIDATORS]> as:TYPE_MAP key:NAME:

    # Grab the value in the input map or NULL in inexistant
    - define VALUE <[INPUT_DATA].get[<[NAME]>].if_null[NULL]>

    # If the value isn't set…
    - if <[VALUE]> == NULL:
      # … checks wether having no data is fine …
      - define NULL_IS_FINE <[TYPE_MAP].get[NULL].if_null[NULL]>

      # … if it's not okay, error
      - if <[NULL_IS_FINE]> == NULL:
        - definemap RESULT:
            OK: false
            CAUSE: NULL_VALUE
            MISSING: <[NAME]>
            REQUIRED_TYPE: <[TYPE_MAP.TYPE]>
            MESSAGE: Required key '<[NAME]>' isn't provided.
        - determine <[RESULT]>

      # … if it didn't end already, by deduction it's fine…
      # … so we check if there is a default fallback value…
      - if <[TYPE_MAP.FALLBACK].exists>:

        - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[TYPE_MAP.FALLBACK]>]>

      # … and we don't go into further checks
      - foreach next

    # Validates the type of input
    - choose <[TYPE_MAP].get[TYPE]>:

      - case location:
        # If the input value as location is fine OR the value has a location (player, entity, …), it's fine. NULL otherwise
        - define PARSED_VALUE <[VALUE].as[location].if_null[<[VALUE].location.if_null[NULL]>]>
        - if <[PARSED_VALUE]> == NULL:
          - definemap RESULT:
              OK: false
              CAUSE: WRONG_TYPE
              REQUIRED_TYPE: location
              GIVEN_TYPE: <[VALUE].object_type>
              MESSAGE: The '<[NAME]>' key should be a location. '<[VALUE].object_type>' given. (Input: <map[STRING=<[VALUE]>;LENGTH=50].proc[APADEMIDE].context[element.ellipsis]>)
          - determine <[RESULT]>
        - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[PARSED_VALUE]>]>

      - case integer:
        - if !<[VALUE].is_integer>:
          - definemap RESULT:
              OK: false
              CAUSE: WRONG_TYPE
              REQUIRED_TYPE: integer
              GIVEN_TYPE: <[VALUE].object_type>
              MESSAGE: The '<[NAME]>' key should be an integer. '<[VALUE].object_type>' given. (Input: <[VALUE].length.is_more_than[0].if_true[<map[STRING=<[VALUE]>;LENGTH=50].proc[APADEMIDE].context[element.ellipsis]>].if_false[<&lt>empty<&gt>]>)
          - determine <[RESULT]>

      - case any:
        - if !<[VALUE].exists> || <[VALUE].is_empty.if_null[false]> || <[VALUE].length> == 0:
          - definemap RESULT:
              OK: false
              CAUSE: EMPTY_INPUT
              REQUIRED_TYPE: any
              GIVEN_TYPE: <[VALUE].object_type>
              MESSAGE: The '<[NAME]>' key should be set to anything not empty. (Input: <[VALUE].length.is_more_than[0].if_true[<map[STRING=<[VALUE]>;LENGTH=50].proc[APADEMIDE].context[element.ellipsis]>].if_false[<&lt>empty<&gt>]>)
          - determine <[RESULT]>

      - case enum:
        - define ENUM <[TYPE_MAP.ENUM].split[|]>
        - if !<[ENUM].contains[<[VALUE]>]>:
          - definemap RESULT:
              OK: false
              CAUSE: NOT_IN_ENUM
              VALID_OPTIONS: <[ENUM].formatted>
              GIVEN_OPTION: <[VALUE]>
              MESSAGE: Possible values for '<[NAME]>' key: <[ENUM].formatted>. (Input: <[VALUE].length.is_more_than[0].if_true[<map[STRING=<[VALUE]>;LENGTH=50].proc[APADEMIDE].context[element.ellipsis]>].if_false[<&lt>empty<&gt>]>)
          - determine <[RESULT]>

      # Handles Denizen's path sythax.
      # Converts li@lists|of|elements to lists.of.elements
      # Converts el@elements/with/slashes to elements.with.dots
      # And transforms everything to uppercase (personnal preferences)
      # Errors for anything else
      - case path:
        - choose <[VALUE].object_type>:
          - case List:
            - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[VALUE].separated_by[.].to_uppercase>]>
          - case Element:
            - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[VALUE].replace_text[/].with[.].to_uppercase>]>
          - default:
            - definemap RESULT:
                OK: false
                CAUSE: WRONG_TYPE
                REQUIRED_TYPE: path
                GIVEN_TYPE: <[VALUE].object_type>
                MESSAGE: The '<[NAME]>' key should be a Denizen path. '<[VALUE].object_type>' given. (Input: <map[STRING=<[VALUE]>;LENGTH=50].proc[APADEMIDE].context[element.ellipsis]>)
            - determine <[RESULT]>

      # If the value is intended to be a boolean, force it into a boolean
      - case bool boolean:
        - define NEW_DATA <[NEW_DATA].with[<[NAME]>].as[<[VALUE].is_truthy>]>
  - determine <map[OK=true].with[DATA].as[<[NEW_DATA]>]>
