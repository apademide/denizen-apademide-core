apa_core_procedures_data:
  type: data
  debug: false
  chars:
    alpha:
      all:
        list: <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z]>
        element: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
      uppercase:
        list: <list[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z]>
        element: ABCDEFGHIJKLMNOPQRSTUVWXYZ
      lowercase:
        list: <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z]>
        element: abcdefghijklmnopqrstuvwxyz
    alphanum:
      all:
        list: <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|0|1|2|3|4|5|6|7|8|9]>
        element: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
      uppercase:
        list: <list[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|0|1|2|3|4|5|6|7|8|9]>
        element: ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
      lowercase:
        list: <list[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|0|1|2|3|4|5|6|7|8|9]>
        element: abcdefghijklmnopqrstuvwxyz0123456789
    num:
      list: <list[0|1|2|3|4|5|6|7|8|9]>
      element: 0123456789