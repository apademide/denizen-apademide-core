
apa_core_proc_parse_math:
  type: procedure
  debug: false
  definitions: FORMULA
  script:
  # Automatically converts ([{}]) to parenthesis
  - define FORMULA <[FORMULA].replace_text[<&lb>].with[(].replace_text[<&rb>].with[)].replace_text[<&lc>].with[(].replace_text[<&rc>].with[)]>
  # Automatically converts comma to dots
  - define FORMULA <[FORMULA].replace_text[,].with[.]>
  # Convert each element to a list entry
  - define ELEMENTS '<[FORMULA].to_list.filter[equals[ ].not]>'

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

    - if <[EL].equals[(]>:
      - if <[PATH].get[<[NEST]>].exists>:
        - debug LOG "<gold>PATHgetNEST <[PATH].get[<[NEST]>]> NEST <[NEST]> PATH <[PATH]>"
        - define PATH[<[NEST]>]:++
        - debug LOG "<gold>PATHgetNEST <[PATH].get[<[NEST]>]> NEST <[NEST]> PATH <[PATH]>"
      - else:
        - debug LOG "<aqua>NEST <[NEST]> PATH <[PATH]>"
        - define PATH:->:0
      - define NEST:++
      - foreach next
    - if <[EL].equals[)]>:
      # - define PATH[<[NEST]>]:<-
      - define NEST:--
      - define PATH <[PATH].remove[last]>
      - foreach next

    - debug LOG "<red><[PATH].separated_by[.].null_if[length.equals[0]].if_null[N]> (<[NEST]>)"

    # - debug LOG "<element[  ].repeat[<[NEST].sub[1]>]><dark_gray>↓ P: <[PATH].separated_by[.]> | N: <[NEST]>"
    - debug LOG "<element[  ].repeat[<[NEST].sub[1]>]><[EL]>"

    # - if <[EL].equals[(]>:
    #   - define NEST:++
    #   - if !<[PATH].get[<[NEST]>].exists>:
    #   #   - define PATH[<[NEST]>]:++
    #   # - else:
    #     - define PATH <[PATH].include[1]>
    #   - foreach next

    # - if <[EL].equals[)]>:
    #   - define NEST:--
    #   - define PATH <[PATH].remove[last]>
    #   # Error if parenthesis are unmatched
    #   - if <[NEST]> < 0:
    #     - determine "<map[OK=FALSE;MESSAGE=Unmatched parenthesis]>"
    #   - foreach next

    # - define PATH[<[NEST]>]:++
    # - define PATH <[PATH].overwrite[<[PATH].get[<[NEST]>]>].at[<[NEST]>]>
    # - debug LOG "<&color[#dddddd]><[PATH].separated_by[.].if_null[<[PATH]>]> (<[NEST]>)<&co>"

  - definemap RESULT:
      OK: true
      RESULT: uwu
  # - determine <map[OK=TRUE;RESULT=<[RESULT]>]>
  - determine <[RESULT.RESULT]>





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