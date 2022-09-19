
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
  # Converts various notations of roots to r
  - define FORMULA <[FORMULA].replace_text[sqrt].with[r].replace_text[_].with[r]>
  # Trim potential equal signs before or after to handle (just in case) (equation)=
  - define FORMULA <[FORMULA].after[=].before_last[=]>
  # Confirms the formula contains only handled chars at this point
  - if <map[STRING=<[FORMULA]>;SET=0123456789⁰¹²³⁴⁵⁶⁷⁸⁹+-/*^r()].proc[APADEMIDE].context[CHARS.MATCHES_CHARACTER_SET]>:
    - definemap RESULT:
        OK: false
        MESSAGE: Your equation contains unhandled characters. (MATH.PARSE_FORMULA)
    - determine <[RESULT]>
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
  # Loop through the split formula
  - foreach <[ELEMENTS]> as:EL:

    # If we open a parenthesis, go deeper
    # and next
    - if <[EL].equals[(]>:
      - define NEST:++
      - define PATH:->:0
      - foreach next
    # If we close a parenthsis, come back shallower
    # and next
    - if <[EL].equals[)]>:
      - define NEST:--
      # Error if the parenthesis are unmatched pairs
      - if <[NEST]> == 0:
        - definemap RESULT:
            OK: false
            MESSAGE: Unmatched parenthesis. (MATH.PARSE_FORMULA)
        - determine <[RESULT]>
      - define PATH[last]:<-
      - foreach next

    # Reform numbers
    # > If the current value is either a dot, a minus sign or an integer,
    # > we want to check wether the previous one was too
    # > in order to recompose decimals and integers > 9
    - define EL_IS_DOT <[EL].equals[.]>
    - define EL_IS_MIN <[EL].equals[-]>
    - if <[EL].is_integer> || <[EL_IS_DOT]>:
      # Get the previous value (aka the current PATH since it wasn't increased yet)
      # A fallback is necessary for when we are in the first element of a submap
      # to handle PATH ending by .0 (which error)
      - define OLD <[MAP].deep_get[<[PATH].separated_by[.]>].if_null[NULL]>
      # We check wether the old value was a decimal
      # Formats like ##. returns true with is_decimal (even without a number after the dot),
      # automatically handlings the recomposition of decimals too
      - if <[OLD].is_decimal>:
        # in that case combine both values (to reform the whole number)
        - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[<[OLD]><[EL]>]>
        - foreach next
      # If the previous value wasn't a decimal and the current one is a dot,
      # it means we face a .## decimal.
      # We add the 0 before so Denizen can handle it
      - else if <[EL_IS_DOT]>:
        - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[0<[EL]>]>
        - foreach next
    # Increase the current value in the path
    - define PATH[<[NEST]>]:++

    # Add the current value to the map
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