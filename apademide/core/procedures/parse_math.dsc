# Prepares a formula for use by other procs
# It replaces various text to handle multiple notations for the same operatiosn
# and trim spaces
apa_core_proc_math_formula_prepare:
  type: procedure
  debug: false
  definitions: FORMULA
  script:
    # # Converts ([{}]) to parenthesis
    # - define FORMULA <[FORMULA].replace_text[<&lb>].with[(].replace_text[<&rb>].with[)].replace_text[<&lc>].with[(].replace_text[<&rc>].with[)]>
    # # Converts comma to dots and remove spaces
    # - define FORMULA '<[FORMULA].replace_text[,].with[.].replace_text[ ]>'
    # # Converts all types of dashes to the normal one (minus sign)
    # - define FORMULA <[FORMULA].replace_text[–].with[-].replace_text[—].with[-]>
    # # Converts all possible multiplicators to * (equations aren't supported so x is *) and ÷ to /
    # - define FORMULA <[FORMULA].replace_text[·].with[*].replace_text[x].with[*].replace_text[×].with[*].replace_text[÷].with[/]>
    # # Converts various notations of square roots to r and ^ powers to p
    # - define FORMULA <[FORMULA].replace_text[sqrt].with[r].replace_text[_].with[r].replace_text[^].with[p]>
    # # Handles pi
    # # Replaces by |3.14…| instead of 3.14… to handle 3pi formats without the * between (3 * pi)
    # - define FORMULA <[FORMULA].replace_text[pi].with[|<util.pi>|].replace_text[π].with[|<util.pi>|]>

    # Inline version of all the above define commands
    - define FORMULA '<[FORMULA].replace_text[<&lb>].with[(].replace_text[<&rb>].with[)].replace_text[<&lc>].with[(].replace_text[<&rc>].with[)].replace_text[,].with[.].replace_text[ ].replace_text[–].with[-].replace_text[—].with[-].replace_text[·].with[*].replace_text[x].with[*].replace_text[×].with[*].replace_text[÷].with[/].replace_text[sqrt].with[r].replace_text[^].with[p].replace_text[pi].with[|<util.pi>|].replace_text[π].with[|<util.pi>|]>'

    - definemap RESULT:
        OK: true
        RESULT: <[FORMULA]>
    - determine <[RESULT]>

# Split operators to get a list of all the formula's elements
# Must be a ready to use formula prepared with apa_core_proc_math_formula_prepare
apa_core_proc_math_formula_split:
  type: procedure
  debug: false
  definitions: INPUT
  data:
    operators:
      - sin
      - tan
      - cos
      - p
      - r
      - /
      - *
      - -
      - +
      - )
      - (
  script:
    - define MAP <[INPUT].proc[apa_core_proc_math_formula_prepare]>
    - if !<[MAP.OK]>:
      - definemap RESULT:
          OK: false
          MESSAGE: <[MAP.MESSAGE]>
      - determine <[RESULT]>
    - define FORMULA <[MAP.RESULT]>

    # Get all operators (including parenthesis)
    - define OPERATORS <script.data_key[DATA.OPERATORS]>

    # Loop through every operator
    - foreach <[OPERATORS]> as:OP:
      # Replace all operators by themselve surrounded by pipes to listify the element
      - define FORMULA <[FORMULA].replace_text[<[OP]>].with[|<[OP]>|]>
    # Deduplicates pipes generated by following operators (i.e multiplying a parenthesis' content) and split pipes
    - define FORMULA <[FORMULA].replace_text[||].with[|].split[|]>

    - define NEW_FORMULA <list>
    - define LAST_WAS_CLOSING false
    - define NEXT_HAS_SIGN false
    - define SIGN <empty>
    # New loop to handle negative numbers and numbers next to parenthesis
    - foreach <[FORMULA]> as:EL:

      # If we set NEXT_HAS_SIGN to true during the previous round
      - if <[NEXT_HAS_SIGN]>:
        # If the current value is a decimal, we combine it with its sign
        - if <[EL].is_decimal>:
          - define NEW_FORMULA:->:<[SIGN]><[EL]>
          - define NEXT_HAS_SIGN false
          - foreach next
        # If it's not a decimal, it means there are too many following operators
        - definemap RESULT:
            OK: false
            MESSAGE: Too many operators following each other.
        - determine <[RESULT]>

      # If the previous value in the loop was a closing parenthesis…
      - if <[LAST_WAS_CLOSING]>:
        # … we reset the value
        - define LAST_WAS_CLOSING false
        # If the current element is a "double input operator", we simply add it
        - if <list[*|/|+|-|^|p].contains[<[EL]>]>:
          - define NEW_FORMULA:->:<[EL]>
          - foreach next
        # But if that's not the case, we apply the rule saying that 2 elements
        # next to each other without an operator are mulitplied
        # > i.e. #(#),  (#)(#) becomes
        # >      #*(#), (#)*(#)
        - define NEW_FORMULA:->:*
        - define NEW_FORMULA:->:<[EL]>
        - foreach next


      - if <[EL].is_decimal>:
        - define NEW_FORMULA:->:<[EL]>
        - foreach next

      # Get the previous element
      - define LAST <[NEW_FORMULA].last.if_null[NULL]>

      - if <[EL].equals[(]>:
        # Handle #() and ()() as #*() and ()*()
        - if <[LAST].is_decimal> || <[LAST].equals[)]>:
          - define NEW_FORMULA:->:*
        - define NEW_FORMULA:->:<[EL]>
        - foreach next

      # If we face a closing parenthesis, we pass the information to the next round
      - if <[EL].equals[)]>:
        - define NEW_FORMULA:->:)
        - define LAST_WAS_CLOSING true
        - foreach next

      # If the previous EL was an operator and we face either + or -
      # it means we face a number with a sign
      # > We pass the sign to the next loop and do nothing yet
      - if <[OPERATORS].contains[<[LAST]>]> && ( <[EL].equals[+]> || <[EL].equals[-]> ):
        - define NEXT_HAS_SIGN true
        - define SIGN <[EL]>
        - foreach next

      - define NEW_FORMULA:->:<[EL]>

    - definemap RESULT:
        OK: true
        RESULT: <[NEW_FORMULA]>
    - determine <[RESULT]>

apa_core_proc_math_formula_to_postfix:
  type: procedure
  debug: false
  definitions: INPUT
  data:
    precedence:
      'sin': 4
      'tan': 4
      'cos': 4
      'p': 4
      'r': 4
      '*': 3
      '/': 3
      '+': 2
      '-': 2
  script:
    - define MAP <[INPUT].proc[apa_core_proc_math_formula_split]>
    - if !<[MAP.OK]>:
      - definemap RESULT:
          OK: false
          MESSAGE: <[MAP.MESSAGE]>
      - determine <[RESULT]>
    - define FORMULA <[MAP.RESULT]>

    # Precedence map
    - define PRECEDENCE <script.data_key[DATA.PRECEDENCE]>
    # All operators EXCEPT parenthesis
    - define OPERATORS <[PRECEDENCE].keys>


    - define QUEUE <list>
    - define STACK <list>

    - foreach <[FORMULA]> as:EL:

      # Numbers
      - if <[EL].is_decimal>:
        - define QUEUE:->:<[EL]>
        - foreach next

      # Operators except parenthesis
      - if <[OPERATORS].contains[<[EL]>]>:
        # If the last element in the STACK is an operator, we check for its precedence
        - define LAST <[STACK].last.if_null[NULL]>
        - if <[OPERATORS].contains[<[LAST]>]> && <[PRECEDENCE.<[LAST]>]> >= <[PRECEDENCE.<[EL]>]>:
          # If the new item has a lower precedence than the previous item,
          # We move the previous operator from the STACK to the QUEUE
          - define QUEUE:->:<[LAST]>
          - define STACK[last]:<-
        # And we append the new operator to the STACK
        - define STACK:->:<[EL]>
        - foreach next

      # Openning parenthesis
      - if <[EL].equals[(]>:
        - define STACK:->:(
        - foreach next

      # Closing parenthesis
      - if <[EL].equals[)]>:
        # Security to prevent infinite loops in case of wrong formulas
        - define SECURITY 0
        - while <[SECURITY]> < 100:
          - define SECURITY:++

          # Get the last element in the STACK
          - define LAST <[STACK].last.if_null[NULL]>

          # If there's no more element in the stack but we're still in the loop,
          # parenthesis are unmatched
          - if <[LAST]> == NULL:
            - determine "<map[OK=false;MESSAGE=Mismatched parenthesis.]>"

          # When we find the closing parenthesis,
          # we remove it from the STACK and end the while loop
          - if <[LAST].equals[(]>:
            - define STACK[last]:<-
            - while stop
          # As long as the while loops, we take the last element in the STACK
          # and append it to the QUEUE
          - define QUEUE:->:<[LAST]>
          - define STACK[last]:<-
        - foreach next

    # When we've looped through all the formula,
    # we take the remaining elements of the stack and append them to the QUEUE
    - foreach <[STACK].reverse> as:EL:
      - define QUEUE:->:<[EL]>

    - definemap RESULT:
        OK: true
        RESULT: <[QUEUE]>
    - determine <[RESULT]>

apa_core_proc_math_formula_calculate:
  type: procedure
  debug: false
  definitions: INPUT
  script:
    - define MAP <[INPUT].proc[apa_core_proc_math_formula_to_postfix]>
    - if !<[MAP.OK]>:
      - definemap RESULT:
          OK: false
          MESSAGE: <[MAP.MESSAGE]>
      - determine <[RESULT]>
    - define FORMULA <[MAP.RESULT]>

    # All operators excepts single-input-operators that's handled differently
    - define OPERATORS <list[p|/|*|-|+]>
    # All single-input-operators
    - define S_OPERATORS <list[sin|tan|cos|r]>
    # The STACK of elements to be parsed and already parsed
    - define STACK <list>

    - foreach <[FORMULA]> as:EL:
      # Handle decimals
      # not much to think about, simply add to stack
      - if <[EL].is_decimal>:
        - define STACK:->:<[EL]>
        - foreach next
      # Handle single-input-operators
      # Square roots, sin, tan, …
      # They only need to mess with the following value
      - if <[S_OPERATORS].contains[<[EL]>]>:
        - define AFTER <[STACK].last>
        - define STACK[last]:<-
        - choose <[EL]>:
          - case tan:
            - define NEW_EL <[AFTER].tan>
          - case cos:
            - define NEW_EL <[AFTER].cos>
          - case sin:
            - define NEW_EL <[AFTER].sin>
          - case r:
            - define NEW_EL <[AFTER].sqrt>
        - define STACK:->:<[NEW_EL]>
        - foreach next
      - if <[OPERATORS].contains[<[EL]>]>:
        - define AFTER <[STACK].last.if_null[NULL]>
        - if <[AFTER]> == NULL:
          - definemap RESULT:
              OK: false
              MESSAGE: Too many operators.
          - determine <[RESULT]>
        - define STACK[last]:<-
        - define BEFORE <[STACK].last.if_null[NULL]>
        - if <[BEFORE]> == NULL:
          - definemap RESULT:
              OK: false
              MESSAGE: Too many operators.
          - determine <[RESULT]>
        - define STACK[last]:<-
        - choose <[EL]>:
          - case *:
            - define NEW_EL <[BEFORE].mul[<[AFTER]>]>
          - case /:
            - define NEW_EL <[BEFORE].div[<[AFTER]>]>
          - case +:
            - define NEW_EL <[BEFORE].add[<[AFTER]>]>
          - case -:
            - define NEW_EL <[BEFORE].sub[<[AFTER]>]>
          - case p:
            - define NEW_EL <[BEFORE].power[<[AFTER]>]>
        - define STACK:->:<[NEW_EL]>
        - foreach next
      # If no type matched, we have unhandled chars
      - definemap RESULT:
          OK: false
          MESSAGE: Formula contains unhandled characters. (<[EL]>)
      - determine <[RESULT]>
    - definemap RESULT:
        OK: true
        RESULT: <[STACK]>
    - determine <[RESULT]>

casjasakjhskajhksjahskjh:
  type: command
  name: c
  debug: false
  description: Does something
  usage: /c
  script:
    - announce to_console --------------------
    - announce to_console "<context.args.unseparated> ="
    - announce to_console <map[formula=<context.args.space_separated>].proc[apademide].context[math.calc]>
    - announce to_console --------------------


# apa_core_proc_parse_math:
#   type: procedure
#   debug: false
#   definitions: FORMULA
#   inject:
#     - determine '<map[OK=false;MESSAGE=<[MESSAGE]> (MATH.PARSE_FORMULA)]>'
#   script:
#     # Prepares the formula for parsing
#     - define FORMULA <[FORMULA].proc[apa_core_proc_prepare_formula]>

#     # Confirms the formula contains only handled chars at this point
#     - define OPERATORS +-/*^r
#     - if !<map[STRING=<[FORMULA]>;SET=0123456789⁰¹²³⁴⁵⁶⁷⁸⁹.()<[OPERATORS]>].proc[APADEMIDE].context[ELEMENT.MATCHES_CHARACTER_SET].is_truthy>:
#       - define MESSAGE "Your equation contains unhandled characters."
#       - inject <script> path:inject
#     # Since that point, we'll need operators as a list not an element
#     - define OPERATORS <[OPERATORS].to_list>
#     # Get superscripts as a list
#     - define SUPER <list[⁰|¹|²|³|⁴|⁵|⁶|⁷|⁸|⁹]>
#     # Convert each element to a list entry
#     - define ELEMENTS <[FORMULA].to_list>

#     # the current "depth" of the formula
#     - define NEST 1

#     # the map containing the exploded formula
#     - define MAP <map[0=<map>]>

#     # The current PATH to the element in the map
#     - define PATH <list[0]>

#     # The number of signs following each other
#     - define SIGNS 0

#     # Loop through the splitted formula
#     - foreach <[ELEMENTS]> as:EL:

#       # If there are too many operators following each other
#       - if <[SIGNS]> > 1:
#         - define MESSAGE "Too much operators following each other."
#         - inject <script> path:inject

#       # If we open a parenthesis, go deeper in the map
#       # and next
#       - if <[EL].equals[(]>:
#         # If there are too many operators following each other
#         - if <[SIGNS]> > 0:
#           - define MESSAGE "Too much operators before a parenthesis."
#           - inject <script> path:inject
#         - define PATH[<[NEST]>]:++
#         - define NEST:++
#         - define PATH:->:0
#         - foreach next
#       # If we close a parenthsis, come back shallower
#       # and next
#       - if <[EL].equals[)]>:
#         - if <[SIGNS]> > 0:
#           - define MESSAGE "Operators before a closing parenthesis."
#           - inject <script> path:inject
#         - define NEST:--
#         # Error if the parenthesis are unmatched pairs (minimum value of NEST should be 1)
#         - if <[NEST]> <= 0:
#           - define MESSAGE "Unmatched parenthesis."
#           - inject <script> path:inject
#         - define PATH[last]:<-
#         # When a parenthesis is closed, we can already do the maths for the closed block
#         # >                  | closed block's map
#         # >                                                                                      | tells the proc the formula is already a valid calc map
#         - define INT_VALUE <[MAP.<[PATH].separated_by[.]>].proc[apa_core_proc_calculate].context[true]>
#         - debug LOG <light_purple><[INT_VALUE]>
#         - foreach next

#       # The listtag path to an usable element PATH
#       - define MAP_PATH <[PATH].separated_by[.]>

#       # > If the current value is a minus or plus sign,
#       # > we want to check wether the previous one was an operator too
#       # > to handle negative numbers
#       - define EL_IS_SIGN <list[-|+].contains[<[EL]>]>

#       - if <[EL_IS_SIGN]>:
#         # Get the previous value (aka the current PATH since it wasn't increased yet)
#         # A fallback is necessary for when we are in the first element of a submap
#         # to handle PATH ending by .0 (which would error)
#         - define OLD <[MAP].deep_get[<[MAP_PATH]>].if_null[NULL]>

#         - if <[OLD]> in <[OPERATORS].include[NULL]>:
#           - define SIGNS:++
#           - define SIGN <[EL]>
#           - foreach next

#       # Reform numbers
#       # > If the current value is either a dot or an integer
#       # > we want to check wether the previous one was too
#       # > in order to recompose decimals and integers > 9
#       - define EL_IS_DOT <[EL].equals[.]>

#       - if <[EL].is_integer> || <[EL_IS_DOT]>:

#         - define OLD <[MAP].deep_get[<[MAP_PATH]>].if_null[NULL]>

#         # We check wether the old value was a decimal
#         # Formats like ##. returns true with is_decimal (even without a number after the dot),
#         # automatically handlings the recomposition of decimals too
#         - if <[OLD].is_decimal>:

#           # in that case combine both values (to reform the whole number)
#           - define MAP <[MAP].deep_with[<[MAP_PATH]>].as[<[OLD]><[EL]>]>
#           - foreach next

#         # If the previous value wasn't a decimal and the current one is a dot,
#         # it means we face a .## decimal.
#         # We add the 0 before so Denizen can handle it
#         - if <[EL_IS_DOT]>:
#           - define MAP <[MAP].deep_with[<[MAP_PATH]>].as[0<[EL]>]>
#           - foreach next


#       # Reform superscript powers
#       # > If the current value is a superscript
#       # > we want to check wether the previous one was too
#       - define EL_IS_SUPER <[SUPER].contains[<[EL]>]>
#       - if <[EL_IS_SUPER]>:
#         - define OLD <[MAP].deep_get[<[MAP_PATH]>].if_null[NULL]>

#         # We check wether the prev value was a superscript
#         # Substring 1,1 to get the first char
#         - if <[SUPER].contains[<[OLD].substring[1,1]>]>:

#           # in that case combine both values (to reform the whole number)
#           - define MAP <[MAP].deep_with[<[MAP_PATH]>].as[<[OLD]><[EL]>]>
#           - foreach next

#       # Increase the current value in the path
#       - define PATH[<[NEST]>]:++

#       # Add the current value to the map
#       # We can't use the <[MAP_PATH]> def since the PATH has been updated
#       # Also we handle negative numbers here
#       - if <[SIGNS]> > 0:
#         - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[<[SIGN]><[EL]>]>
#         - define SIGNS:--
#       - else:
#         - define MAP <[MAP].deep_with[<[PATH].separated_by[.]>].as[<[EL]>]>
#     - definemap RESULT:
#         OK: true
#         RESULT: <&nl><[MAP].to_yaml.replace_text[<&sq>].before_last[<&nl>]>
#     - determine <[RESULT]>
# # ⁰¹²³⁴⁵⁶⁷⁸⁹
# apa_core_proc_calculate:
#   type: procedure
#   debug: false
#   definitions: FORMULA|CHECKED
#   data:
#     super_list:
#       - ⁰
#       - ¹
#       - ²
#       - ³
#       - ⁴
#       - ⁵
#       - ⁶
#       - ⁷
#       - ⁸
#       - ⁹
#     super_map:
#       ⁰: 0
#       ¹: 1
#       ²: 2
#       ³: 3
#       ⁴: 4
#       ⁵: 5
#       ⁶: 6
#       ⁷: 7
#       ⁸: 8
#       ⁹: 9
#   subprocedures:
#     fix_value:
#       - if <[SUPER].contains[<[EL].substring[1,1]>]>:
#         - foreach <[SUPER]> as:S:
#           - define EL <[EL].replace_text[<[S]>].with[<[SUPER_MAP.<[S]>]>]>
#         - define FORMULA <[FORMULA].remove[<[LOOP_INDEX]>].insert[^|<[EL]>].at[<[LOOP_INDEX]>]>
#     do_the_math:
#       - choose <[P]>:
#         - case POWER_ROOT:
#           - while !<[HIT_THE_END]> && <[SECURITY]> < 1000:
#             - debug log <[LOOP_INDEX]>
#             - define SECURITY:++
#             - foreach <[FORMULA]> as:EL:
#               - if <[EL].is_decimal>:
#                 - foreach next
#               - if <[EL].equals[^]>:
#                 - inject <script> path:subprocedures.mathing.get_two_values
#                 - define NEW_EL <[BEFORE].power[<[AFTER]>]>
#                 - inject <script> path:subprocedures.mathing.set_two_values
#               - if <[EL].equals[r]>:
#                 - inject <script> path:subprocedures.mathing.get_one_value
#                 - define NEW_EL <[AFTER].abs.sqrt>
#                 - inject <script> path:subprocedures.mathing.set_one_value
#             - inject <script> path:subprocedures.mathing.its_the_end
#         - case MUL_DIV:
#           - while !<[HIT_THE_END]> && <[SECURITY]> < 1000:
#             - debug log <[LOOP_INDEX]>
#             - define SECURITY:++
#             - foreach <[FORMULA]> as:EL:
#               - if <[EL].is_decimal>:
#                 - foreach next
#               - if <[EL].equals[*]>:
#                 - inject <script> path:subprocedures.mathing.get_two_values
#                 - define NEW_EL <[BEFORE].mul[<[AFTER]>]>
#                 - inject <script> path:subprocedures.mathing.set_two_values
#               - if <[EL].equals[/]>:
#                 - inject <script> path:subprocedures.mathing.get_two_values
#                 - define NEW_EL <[BEFORE].div[<[AFTER]>]>
#                 - inject <script> path:subprocedures.mathing.set_two_values
#             - inject <script> path:subprocedures.mathing.its_the_end
#         - case ADD_SUB:
#           - while !<[HIT_THE_END]> && <[SECURITY]> < 1000:
#             - debug log <[LOOP_INDEX]>
#             - define SECURITY:++
#             - foreach <[FORMULA]> as:EL:
#               - if <[EL].is_decimal>:
#                 - foreach next
#               - if <[EL].equals[+]>:
#                 - inject <script> path:subprocedures.mathing.get_two_values
#                 - define NEW_EL <[BEFORE].add[<[AFTER]>]>
#                 - inject <script> path:subprocedures.mathing.set_two_values
#               - if <[EL].equals[-]>:
#                 - inject <script> path:subprocedures.mathing.get_two_values
#                 - define NEW_EL <[BEFORE].sub[<[AFTER]>]>
#                 - inject <script> path:subprocedures.mathing.set_two_values
#             - inject <script> path:subprocedures.mathing.its_the_end


#     mathing:
#       # Get and set subtasks pair for operations requiring two inputs
#       # i.e 1*2, 1^2
#       get_two_values:
#         - define BEFORE_INDEX <[LOOP_INDEX].sub[1]>
#         - define BEFORE <[FORMULA].get[<[BEFORE_INDEX]>]>
#         - define AFTER_INDEX <[LOOP_INDEX].add[1]>
#         - define AFTER <[FORMULA].get[<[AFTER_INDEX]>]>
#       set_two_values:
#         - define FORMULA <[FORMULA].remove[<[BEFORE_INDEX]>].to[<[AFTER_INDEX]>]>
#         - define FORMULA <[FORMULA].insert[<[NEW_EL]>].at[<[BEFORE_INDEX]>]>
#         - foreach stop
#       # Get and set subtasks pair for operations requiring one input
#       # i.e. r20 (square root)
#       get_one_value:
#         - define AFTER_INDEX <[LOOP_INDEX].add[1]>
#         - define AFTER <[FORMULA].get[<[AFTER_INDEX]>]>
#       set_one_value:
#         - define FORMULA <[FORMULA].remove[<[LOOP_INDEX]>].to[<[AFTER_INDEX]>]>
#         - define FORMULA <[FORMULA].insert[<[NEW_EL]>].at[<[LOOP_INDEX]>]>
#         - foreach stop
#       its_the_end:
#         - if <[FORMULA].length> <= 1:
#           - debug log <green><[LOOP_INDEX]>|||<[FORMULA]>
#           - define HIT_THE_END true


#   script:
#   - if !<[CHECKED]>:
#     - determine nô
#   - define SUPER <script.data_key[DATA.SUPER_LIST]>
#   - define SUPER_MAP <script.data_key[DATA.SUPER_MAP]>
#   - define PRIORITIES <list[POWER_ROOT|MUL_DIV|ADD_SUB]>
#   - define FORMULA <[FORMULA].values>
#   - foreach <[FORMULA]> as:EL:
#     - inject <script> path:subprocedures.fix_value
#   - foreach <[PRIORITIES]> as:P:
#     - define SECURITY 0
#     - define HIT_THE_END false
#     - inject <script> path:subprocedures.do_the_math
#     - debug log <yellow><[FORMULA]>
#   - determine <[FORMULA].first>