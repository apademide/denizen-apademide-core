apa_module_essentialsnt_internal_data:
  type: data
  debug: false

  # Purely for display use
  display:
    title: Essentialsn't
    author: Apademide
    description: Every not-so-essentials Essential's commands.

  # Used to store data @ <[ROOT_FLAG_NAME]>.MODULES.<[AUTHOR]>.<[NAMESPACE]>
  # which here would be the server flag APADEMIDE.MODULES.APADEMIDE.ESSENTIALSNT
  #                                     ^ core flag
  #                                               ^ module-dedicated subflag
  #                                                       ^ modules grouped by author (to allow prefixless namespace)
  #                                                                 ^ module namespace
  # Technically:
  # > Names starting with _ are prohibited for both author and namespace
  # > if your nickname is _xX_Gäm€r_Xx_, first of all consider renaming yourself, then consider filling 'author:' with xx_gamer_xx
  # In reality:
  # > You can put whatever you want because the value is passed through APADEMIDE CORE's element.safe procedure
  #
  # To automatically get the value that'll be used internally, you can use <map[STRING=YOUR MODULE'S NAME HERE].proc[apademide].context[element.safe]>
  # This way, you'll be sure the name that is actually used is the same as what you input
  author: APADEMIDE
  namespace: ESSENTIALSNT

  # # KEY NAME: path to the config option
  # # VALID: a tag to be parsed that should return a boolean wether it is the expected value
  # # EXPECTED: the value expected, used for debug purpose
  # # <[VALUE]> is the value in the config file
  # required_denizen_config:
  #   Commands.WebServer.Allow:
  #     valid: <[VALUE]>
  #     expected: true

  # Here you can define what config options are required in the MODULE config.
  # If a key is missing in the config the user editted, the module will be disabled and an error will show in the console telling them to add it.
  # It enables you to safely query with config.data_key without having to add fallbacks
  # If no option is required (as in, you put fallbacks where defaults values are okay), you can safely delete that part.
  # Some config keys are still required, but the map of internally required keys isn't saved here so you don't have to add them.
  config:
    required:
      commands:
        permissions:
          root: warn
  scripts:
    # ALL REQUIRED SCRIPTS
    # This map is used on load/reload to confirm every absolutely required script is there (if full_module_analysis config is set to true)
    # You can list the scripts that are required by your module here
    # > They key name is the script's name, and the value is the intended type of the script
    # You may also include some APADEMIDE CORE scripts, i.e. the main 'APADEMIDE' procedure even though it's redundant most of the time
    # > It may be relevant to add in case the full analysis is disabled for the CORE but enabled for MODULES.
    required:
      apademide: procedure


# commandes:
# suicide
# tree: spawns a tree where you're looking
# bigtree: spawns a big tree where you're looking
# break: break the block you're looking
# ping: Pong
# tnt
# fireball
# kittycannon
# beezooka
# nuke
#
#
#
#
#