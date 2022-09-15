# Used by MODULES after load/reload to properly register
apa_core_task_register_module:
  type: task
  debug: false
  definitions: CONFIG_SCRIPT|INTERNAL_CONFIG_SCRIPT
  script:
  # Validates both config scripts have been inputed and stop if not
  - if <[INTERNAL_CONFIG_SCRIPT].if_null[NULL]> == NULL:
    - run <proc[APADEMIDE].context[TASK.DEBUG]> "context:MODULES.FATAL|An anonymous MODULE tried to register without its *internal* config script installed. Source of error: <queue.script.name> in <queue.script.relative_filename>."
    - stop
  - if <[CONFIG_SCRIPT].if_null[NULL]> == NULL:
    - run <proc[APADEMIDE].context[TASK.DEBUG]> "context:MODULES.FATAL|An anonymous MODULE tried to register without its config script installed. Source of error: <queue.script.name> in <queue.script.relative_filename>."
    - stop

  # Get the APADEMIDE CORE's internal config script
  - define GLOBAL_INTERNAL_CONFIG_SCRIPT <proc[apademide].context[internal_config]>
  # If the config allows the full analysis
  - if <proc[apademide].context[config].deep_get[initialization.full_module_analysis].if_null[true]>:
    # Config keys inside the internal MODULE config, required by the CORE (always required)
    - define REQUIRED_INTERNAL_CONFIG_KEYS <[GLOBAL_INTERNAL_CONFIG_SCRIPT].data_key[modules.internal_config.required]>

    # Loops through every required config key to confirm they exists // Error and stop if any misses
    - foreach <[REQUIRED_INTERNAL_CONFIG_KEYS].deep_keys> as:KEY:
      - if !<[INTERNAL_CONFIG_SCRIPT].data_key[<[KEY]>].exists>:
        - run apa_core_debug "context:MODULES.FATAL|The required *internal* config option '<[KEY].to_uppercase>' in '<[INTERNAL_CONFIG_SCRIPT].relative_filename>' is missing. If you are the author of this MODULE, please be sure everything is alright."
        - stop

    # Get all the scripts required by the module, if any
    - define REQUIRED_SCRIPTS <[INTERNAL_CONFIG_SCRIPT].data_key[scripts.required].if_null[NULL]>
    - if <[REQUIRED_SCRIPTS]> != NULL:
      # Confirms all required scripts are here, with the right type
      - foreach <[REQUIRED_SCRIPTS]> as:TYPE key:SCRIPT_NAME:
        - define SCRIPT <script[<[SCRIPT_NAME]>].if_null[NULL]>
        - if <[SCRIPT]> == NULL || <[SCRIPT].container_type> != <[TYPE]>:
          - run apa_core_debug "context:MODULE.FATAL|You seem to be missing some scripts that are required by a module. Source of error: <queue.script.name> in <queue.script.relative_filename>."
          - stop

    # Config keys inside the MODULE's user's config, required by the CORE (always required)
    - define GLOBAL_REQUIRED_CONFIG_KEYS <[GLOBAL_INTERNAL_CONFIG_SCRIPT].data_key[modules.config.required]>
    # Confirms all required config options are here, with the right type
    - foreach <[GLOBAL_REQUIRED_CONFIG_KEYS].deep_keys> as:KEY:
      - if !<[CONFIG_SCRIPT].data_key[<[KEY]>].exists>:
        - run apa_core_debug "context:MODULES.FATAL|The config option '<[KEY].to_uppercase>' in '<[CONFIG_SCRIPT].relative_filename>', which is required by the CORE, is missing."
        - stop

    # Config keys inside the MODULE's user's config, required by the MODULES's internal config (required if the MODULE contains any)
    - define REQUIRED_CONFIG_KEYS <[INTERNAL_CONFIG_SCRIPT].data_key[config.required]>
    - foreach <[REQUIRED_CONFIG_KEYS].deep_keys> as:KEY:
      - if !<[CONFIG_SCRIPT].data_key[<[KEY]>].exists>:
        - run apa_core_debug "context:MODULES.FATAL|The config option '<[KEY].to_uppercase>' in '<[CONFIG_SCRIPT].relative_filename>', which is required by the MODULE, is missing."
        - stop
  # - define GLOBAL_CONFIG <proc[APADEMIDE].context[config]>
  # - narrate <[GLOBAL_CONFIG]>
  # - narrate <script[apa_module_permissions_config].data_key[roles.moderator.permissions].deep_keys.parse[unescaped]>