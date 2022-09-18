apa_core_data:
  type: data
  debug: false
  chars:
    superscript:
      list: <list[⁰|¹|²|³|⁴|⁵|⁶|⁷|⁸|⁹]>
      element: ⁰¹²³⁴⁵⁶⁷⁸⁹
      map:
        0: ⁰
        1: ¹
        2: ²
        3: ³
        4: ⁴
        5: ⁵
        6: ⁶
        7: ⁷
        8: ⁸
        9: ⁹
    subscript:
      list: <list[₀|₁|₂|₃|₄|₅|₆|₇|₈|₉]>
      element: ₀₁₂₃₄₅₆₇₈₉
      map:
        0: ₀
        1: ₁
        2: ₂
        3: ₃
        4: ₄
        5: ₅
        6: ₆
        7: ₇
        8: ₈
        9: ₉
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
    safe:
      list: <list[_|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|0|1|2|3|4|5|6|7|8|9]>
      element: _abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
      equivalents:
        _:
          # (3 dashes types)
          - -
          - –
          - —
          - /
          - \
          - .
          - ,
          - ':'
          - ;
          - (
          - )
          - [
          - ]
          - '{'
          - '}'
          - ' '
        ae:
          - æ
        oe:
          - œ
        a:
          - à
          - â
          - á
          - ä
          - ã
          - å
          - ā
        c:
          - ç
          - ć
          - č
        e:
          - é
          - è
          - ê
          - ë
          - ę
          - ė
          - ē
          - €
        i:
          - î
          - ï
          - ì
          - í
          - į
          - ī
        l:
          - £
        n:
          - ñ
          - ń
        o:
          - ô
          - º
          - °
          - ö
          - ò
          - ó
          - õ
          - ø
          - ō
        s:
          - $
          - §
        u:
          - û
          - ù
          - ü
          - ú
          - ū
        y:
          - ÿ
