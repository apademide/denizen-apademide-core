
apa_core_proc_parse_math:
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
  # Confirms the formula contains only handled chars at this point
  - define OPERATORS +-/*^r
  - if !<map[STRING=<[FORMULA]>;SET=0123456789⁰¹²³⁴⁵⁶⁷⁸⁹()<[OPERATORS]>].proc[APADEMIDE].context[ELEMENT.MATCHES_CHARACTER_SET].is_truthy>:
    - definemap RESULT:
        OK: false
        MESSAGE: Your equation contains unhandled characters. (MATH.PARSE_FORMULA)
    - determine <[RESULT]>
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
  - define NEGATIVE_NUMBER false

  # Loop through the split formula
  - foreach <[ELEMENTS]> as:EL:

    # If we open a parenthesis, go deeper
    # and next
    - if <[EL].equals[(]>:
      # # Handles
      # - if <[NEGATIVE_NUMBER]>:
      #   - define NEGATIVE_NUMBER false
      #   - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[-]>
      #   - define PATH[<[NEST]>]:++

      - define NEST:++
      - define PATH:->:0
      - foreach next
    # If we close a parenthsis, come back shallower
    # and next
    - if <[EL].equals[)]>:
      - define NEGATIVE_NUMBER false
      - define NEST:--
      # Error if the parenthesis are unmatched pairs
      - if <[NEST]> == 0:
        - definemap RESULT:
            OK: false
            MESSAGE: Unmatched parenthesis. (MATH.PARSE_FORMULA)
        - determine <[RESULT]>
      - define PATH[last]:<-
      - foreach next

    # The listtag path to an usable element PATH
    - define MAP_PATH <[PATH].separated_by[.]>

    # Reform numbers
    # > If the current value is either a dot or an integer
    # > we want to check wether the previous one was too
    # > in order to recompose decimals and integers > 9
    - define EL_IS_DOT <[EL].equals[.]>

    # Handle negative numbers
    - if <[NEGATIVE_NUMBER]>:
      - define NEGATIVE_NUMBER false
      - if <[EL].is_integer> || <[EL_IS_DOT]>:
        - define MAP <[MAP].deep_with[<[MAP_PATH]>].as[-<[EL]>]>
        - define PATH[<[NEST]>]:++
        - foreach next

    # > If the current value is a minus sign,
    # > we want to check wether the previous one was an operator too
    # > to handle negative numbers
    - define EL_IS_MIN <[EL].equals[-]>

    - if <[EL].is_integer> || <[EL_IS_DOT]> || <[EL_IS_MIN]>:

      # Get the previous value (aka the current PATH since it wasn't increased yet)
      # A fallback is necessary for when we are in the first element of a submap
      # to handle PATH ending by .0 (which would error)
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

      # If the current value is a minus sign and the OLD one was either an operator or a submap
      # it means we face a negative number
      - if <[EL_IS_MIN]> && ( ( <[OLD]> in <[OPERATORS]> ) || ( <[OLD].object_type> == MAP ) ):
        - debug log <green><[EL]>|<[OLD]>
        # This def will be checked next loop to know whether to add a minus sign
        - define NEGATIVE_NUMBER true
        - foreach next

    # Increase the current value in the path
    - define PATH[<[NEST]>]:++

    # Add the current value to the map
    # We can't use the <[MAP_PATH]> def since the PATH has been updated
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
  - announce to_console <map[formula=<context.args.first>].proc[apademide].context[math.parse_formula]>
  - announce to_console --------------------


# (2*(3+4^5))+6-(7/8)

#   1:
#     1: 2
#     2: *
#     3:
#       1: 3
#       2: +
#       3: 4
#       4: ^
#       5: 5
#   2: +
#   3: 6
#   4: -
#   5:
#     1: 7
#     2: /
#     3: 8


  # 1+2
  # 1-2
  # 1*2
  # 1/2
  # 1^2