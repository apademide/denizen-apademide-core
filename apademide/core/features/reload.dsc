# # Fires a custom reload event, mainly listened by MODULES
# - customevent id:APADEMIDE_CORE_RELOAD

# RELOADS APADEMIDE CORE ENTIRELY
apa_core_reload:
  type: world
  debug: false
  events:
    on custom event id:APADEMIDE_CORE_WANTS_RELOAD:
    - inject <script> path:RELOAD
  reload:
    # Get APADEMIDE CORE's user config script
    - define CONFIG_SCRIPT <script[apa_core_config].if_null[NULL]>

    # If the source of the reload is /ex reload and the config tells not to "reload on reload", stop
    - if <context.source.if_null[NULL]> == RELOAD_SCRIPTS && !<[CONFIG_SCRIPT].data_key[config.initialization.reload_on_reload].if_null[true]>:
      - stop

    # Error and stop if the config script is null
    - if <[CONFIG_SCRIPT]> == NULL:
      - run apa_core_debug "context:FATAL|Cannot innit APADEMIDE CORE without the config script installed."
      - stop

    # Disable APADEMIDE CORE before proceeding to checks
    # Resets all internal values
    - flag server _APA_CORE_FLAG:!

    # Get APADEMIDE CORE's internal config script // Error and stop if null
    - define INTERNAL_CONFIG_SCRIPT <script[apa_core_internal_data].if_null[NULL]>
    - if <[INTERNAL_CONFIG_SCRIPT]> == NULL:
      - run apa_core_debug "context:FATAL|Cannot innit APADEMIDE CORE without the *internal* config script installed."
      - stop

    # If the config allows the full analysis
    - if <[CONFIG_SCRIPT].data_key[initialization.full_analysis].if_null[true]>:
      # Get various required data from the config
      - define REQUIRED_CONFIG_KEYS <[INTERNAL_CONFIG_SCRIPT].data_key[config.required].if_null[NULL]>
      - define REQUIRED_SCRIPTS <[INTERNAL_CONFIG_SCRIPT].data_key[scripts.required].if_null[NULL]>
      # And errors if it's missing
      - if <[REQUIRED_CONFIG_KEYS]> == NULL || <[REQUIRED_SCRIPTS]> == NULL:
        - run apa_core_debug "context:FATAL|The internal config script seems to be incomplete. Please update the whole APADEMIDE CORE folder to be sure everything is as it should be."
        - stop

      # Loops through every required config key to confirm they exists // Error and stop if any misses
      - foreach <[REQUIRED_CONFIG_KEYS].deep_keys> as:KEY:
        - if !<[CONFIG_SCRIPT].data_key[config.<[KEY]>].exists>:
          - run apa_core_debug "context:FATAL|The required config option '<[KEY].to_uppercase>' in '<[CONFIG_SCRIPT].relative_filename>' is missing."
          - stop

      # Confirms all required scripts are here, with the right type
      - foreach <[REQUIRED_SCRIPTS]> as:TYPE key:SCRIPT_NAME:
        - define SCRIPT <script[<[SCRIPT_NAME]>].if_null[NULL]>
        - if <[SCRIPT]> == NULL || <[SCRIPT].container_type> != <[TYPE]>:
          - run apa_core_debug "context:FATAL|You seem to be missing some required scripts. Please do not rename internal scripts nor delete them."
          - stop

    # Get root flag name
    - define ROOT <[CONFIG_SCRIPT].data_key[config.flags.root]>

    # Sets initial activation values
    - flag server _APA_CORE_FLAG.ROOT:<[ROOT]>
    - flag server _APA_CORE_FLAG.INNIT:<util.time_now>
    - flag server _APA_CORE_FLAG.CONFIG:<[CONFIG_SCRIPT].data_key[config]>
    - flag server _APA_CORE_FLAG.INTERNAL_CONFIG_SCRIPT:<[INTERNAL_CONFIG_SCRIPT]>
    - flag server _APA_CORE_FLAG.LAST_RELOAD_SOURCE:<context.source.if_null[UNKNOWN]>

    # If the config allows to store the config in a flag
    - if <[CONFIG_SCRIPT].data_key[initialization.store_denizen_config].if_null[true]>:
      # Get and store Denizen's config in the internal flag // Mainly used by modules requiring special perms.
      - ~yaml load:config.yml id:_APA_DENIZEN_CONFIG
      - flag server _APA_CORE_FLAG.DENIZEN_CONFIG:<yaml[_APA_DENIZEN_CONFIG].read[]>
      - yaml unload id:_APA_DENIZEN_CONFIG

    # Outputs a confirmation
    - run <proc[APADEMIDE].context[TASK.DEBUG]> context:INNIT

    - customevent id:APADEMIDE_CORE_RELOADED
