apa_module_webserver_internal_data:
  type: data
  debug: false

  # Purely for display use
  title: WebServer

  # Used to store data @ <[ROOT_FLAG_NAME]>.MODULES.<[AUTHOR]>.<[NAMESPACE]>
  # which, by default, is server flag APADEMIDE.MODULES.APADEMIDE.WEBSERVER
  #                                   ^ core flag
  #                                             ^ module-dedicated subflag
  #                                                     ^ modules grouped by author (to allow prefixless namespace)
  #                                                               ^ module namespace
  # Name starting with _ are prohibited for both author and namespace
  # if your nickname is _xX_Gäm€r_Xx_, first of all consider renaming yourself, then consider filling 'author:' with xx_gamer_xx
  # (to be precise, if you don't do it on your own, the system will do it itself)
  author: Apademide
  namespace: WEBSERVER

  # KEY: path to the config option
  # VALID: a tag to be parsed that should return a boolean wether it is the expected value
  # EXPECTED: the value expected, mainly used in debug
  # <[VALUE]> is the value in the config file
  required_denizen_config:
    Commands.WebServer.Allow:
      valid: <[VALUE]>
      expected: true