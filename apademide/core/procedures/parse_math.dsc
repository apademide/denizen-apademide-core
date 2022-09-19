apa_core_proc_prepare_formula:
  type: procedure
  debug: false
  definitions: FORMULA
  script:
    # Converts ([{}]) to parenthesis
    - define FORMULA <[FORMULA].replace_text[<&lb>].with[(].replace_text[<&rb>].with[)].replace_text[<&lc>].with[(].replace_text[<&rc>].with[)]>
    # Converts comma to dots and remove spaces
    - define FORMULA '<[FORMULA].replace_text[,].with[.].replace_text[ ]>'
    # Converts all types of dashes to the normal one (minus sign)
    - define FORMULA <[FORMULA].replace_text[–].with[-].replace_text[—].with[-]>
    # Converts all possible multiplicators to * (equations aren't supported so x is *)
    - define FORMULA <[FORMULA].replace_text[·].with[*].replace_text[x].with[*].replace_text[×].with[*]>
    # Converts various notations of square roots to r
    - define FORMULA <[FORMULA].replace_text[sqrt].with[r].replace_text[_].with[r]>

    - determine <[FORMULA]>
apa_core_proc_parse_math:
  type: procedure
  debug: false
  definitions: FORMULA
  inject:
    - determine '<map[OK=false;MESSAGE=<[MESSAGE]> (MATH.PARSE_FORMULA)]>'
  script:
    - define FORMULA <[FORMULA].proc[apa_core_proc_prepare_formula]>
    # Confirms the formula contains only handled chars at this point
    - define OPERATORS +-/*^r
    - if !<map[STRING=<[FORMULA]>;SET=0123456789⁰¹²³⁴⁵⁶⁷⁸⁹.()<[OPERATORS]>].proc[APADEMIDE].context[ELEMENT.MATCHES_CHARACTER_SET].is_truthy>:
      - define MESSAGE "Your equation contains unhandled characters."
      - inject <script> path:inject
    # Since that point, we'll need operators as a list not an element
    - define OPERATORS <[OPERATORS].to_list>
    # Convert each element to a list entry
    - define ELEMENTS <[FORMULA].to_list>

    # the current "depth" of the formula
    # 1+1 will be 1,
    # 1+(2+3) will be 1 for "1" and "+", but will be 2 since "("
    - define NEST 1
    # the map containing the exploded formula
    # 1+1 will be
      # 1: 1
      # 2: +
      # 3: 1
    # 1+(2+3) will be
      # 1: 1
      # 2: +
      # 3:
      #   1: 2
      #   2: +
      #   3: 3
    - define MAP <map[0=<map>]>

    # The current PATH to the element in the map
    - define PATH <list[0]>

    # Sets the default state for the def
    - define SIGNS 0

    # Loop through the splitted formula
    - foreach <[ELEMENTS]> as:EL:
      - debug log <red><[LOOP_INDEX]><white>__<green><[EL]>
      # If there are too many operators following each other
      - if <[SIGNS]> > 1:
        - define MESSAGE "Too much operators following each other."
        - inject <script> path:inject
      # If we open a parenthesis, go deeper
      # and next
      - if <[EL].equals[(]>:
        # If there are too many operators following each other
        - if <[SIGNS]> > 0:
          - define MESSAGE "Too much operators before a parenthesis."
          - inject <script> path:inject
        - define NEST:++
        - define PATH:->:0
        - foreach next
      # If we close a parenthsis, come back shallower
      # and next
      - if <[EL].equals[)]>:
        - if <[SIGNS]> > 0:
          - define MESSAGE "Operators before a closing parenthesis."
          - inject <script> path:inject
        - define NEST:--
        # Error if the parenthesis are unmatched pairs
        - if <[NEST]> == 0:
          - define MESSAGE "Unmatched parenthesis."
          - inject <script> path:inject
        - define PATH[last]:<-
        - foreach next

      # The listtag path to an usable element PATH
      - define MAP_PATH <[PATH].separated_by[.]>

      # > If the current value is a minus or plus sign,
      # > we want to check wether the previous one was an operator too
      # > to handle negative numbers
      - define EL_IS_SIGN <list[-|+].contains[<[EL]>]>

      - if <[EL_IS_SIGN]>:
        # Get the previous value (aka the current PATH since it wasn't increased yet)
        # A fallback is necessary for when we are in the first element of a submap
        # to handle PATH ending by .0 (which would error)
        - define OLD <[MAP].deep_get[<[MAP_PATH]>].if_null[NULL]>

        - if <[OLD]> in <[OPERATORS]> || <[LOOP_INDEX]> == 1:
          - define SIGNS:++
          - define SIGN <[EL]>
          - foreach next

      # Reform numbers
      # > If the current value is either a dot or an integer
      # > we want to check wether the previous one was too
      # > in order to recompose decimals and integers > 9
      - define EL_IS_DOT <[EL].equals[.]>

      - if <[EL].is_integer> || <[EL_IS_DOT]>:

        - define OLD <[MAP].deep_get[<[MAP_PATH]>].if_null[NULL]>

        # We check wether the old value was a decimal
        # Formats like ##. returns true with is_decimal (even without a number after the dot),
        # automatically handlings the recomposition of decimals too
        - if <[OLD].is_decimal>:

          # in that case combine both values (to reform the whole number)
          - define MAP <[MAP].deep_with[<[MAP_PATH]>].as[<[OLD]><[EL]>]>
          - foreach next

        # If the previous value wasn't a decimal and the current one is a dot,
        # it means we face a .## decimal.
        # We add the 0 before so Denizen can handle it
        - if <[EL_IS_DOT]>:
          - define MAP <[MAP].deep_with[<[MAP_PATH]>].as[0<[EL]>]>
          - foreach next

      # Increase the current value in the path
      - define PATH[<[NEST]>]:++

      # Add the current value to the map
      # We can't use the <[MAP_PATH]> def since the PATH has been updated
      # Also we handle negative numbers here
      - if <[SIGNS]> > 0:
        - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[<[SIGN]><[EL]>]>
        - define SIGNS:--
      - else:
        - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[<[EL]>]>
    - definemap RESULT:
        OK: true
        RESULT: <&nl><[MAP].to_yaml.replace_text[<&sq>].before_last[<&nl>]>
    - determine <[RESULT]>



casjasakjhskajhksjahskjh:
  type: command
  name: c
  debug: false
  description: Does something
  usage: /c
  script:
  - announce to_console --------------------
  - announce to_console "<context.args.first> ="
  - announce to_console <map[formula=<context.args.space_separated>].proc[apademide].context[math.parse_formula]>
  - announce to_console --------------------
