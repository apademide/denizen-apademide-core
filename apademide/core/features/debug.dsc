apa_core_debug:
  type: task
  debug: false
  definitions: TYPE|MESSAGE
  data:
    error_prefix: APADEMIDE CORE ERROR<&co>
    ok_prefix: <green><bold>APA -<&gt><white>
    warning_prefix: <red><bold>APA -<&gt><white>
    log_prefix: <dark_gray>APA -<&gt><white>
    separator_prefix: <dark_gray>——————

  # Injects the specific type of output
  script:
  - if !<[MESSAGE].exists>:
    - define MESSAGE "No message to show."
  - inject <script> path:<[TYPE].if_null[NULL]>

  # Script block that runs to output informations when APADEMIDE CORE is initialized
  init:
  # Get internal data from the internal flag
  - define DATA <server.flag[_APA_CORE_FLAG]>
  - define ROOT <[DATA].get[ROOT]>
  # Hide confirmation from console if config says so
  - if !<[DATA].deep_get[config.console.succeed_humbly]>:
    - define PREFIX <script.parsed_key[data.ok_prefix]>
    - define SEPARATOR <script.parsed_key[data.separator_prefix]>
    - debug APPROVAL "APADEMIDE CORE is now activated."
    - debug LOG "<[SEPARATOR]> Load/Reload info"
    - debug LOG "<[PREFIX]> Enabled at: <[DATA].get[INIT].format>"
    - debug LOG "<[PREFIX]> Load/Reload source: <[DATA].get[LAST_RELOAD_SOURCE]>"
    - if <[DATA].get[LAST_RELOAD_SOURCE_MODULE].exists>:
      - debug LOG "<[PREFIX]> Module: <[DATA].get[LAST_RELOAD_SOURCE_MODULE]>"
    - debug LOG "<[SEPARATOR]> Config options"
    - debug LOG "<[PREFIX]> Root flag name: <[ROOT]>"
    - debug LOG "<[PREFIX]> /apademide permission: <proc[APADEMIDE].context[CONFIG].deep_get[COMMANDS.PERMISSIONS.CORE]>"
    - debug LOG "<[PREFIX]> APADEMIDE COMMANDS permission: <proc[APADEMIDE].context[CONFIG].deep_get[COMMANDS.PERMISSIONS.ROOT]>"
  # Checks for potential problems
  - define WARNINGS <list>
  # If Denizen config can't be stored in a flag
  - if !<proc[APADEMIDE].context[CONFIG].deep_get[initialization.store_denizen_config]>:
    - define "WARNINGS:->:Your configuration disallows storing Denizen's config. Some MODULES may break because of missing permissions."
  # Warning if the root server flag doesn't exists
  # Could inform the user of a potential bug or typo in the config
  - if !<server.has_flag[<[ROOT]>]>:
    - define "WARNINGS:->:No data have been found at server flag '<[ROOT]>'. If you're initializing APADEMIDE CORE for the first time or you intentionnaly editted/deleted that flag, ignore this message."
  # Send reload warnings
  - if <[WARNINGS].any>:
    - define SEPARATOR <[SEPARATOR].if_null[<script.parsed_key[data.separator_prefix]>]>
    - debug LOG "<[SEPARATOR]> Warnings"
    - foreach <[WARNINGS]> as:WARNING:
      - debug LOG "<script.parsed_key[data.warning_prefix]> <[WARNING]>"
  - if !<[DATA].deep_get[config.console.succeed_humbly]>:
    - debug LOG "<[SEPARATOR]> Modules (if any)"

  no_apa:
  - debug ERROR "You can't use '<[MESSAGE]>'. APADEMIDE CORE isn't enabled. Check console for possible errors while enabling? (At server start or last reload)"

  # Informs the user that APADEMIDE CORE failed to init for some reason
  fatal:
  - debug ERROR "<script.parsed_key[data.error_prefix]> <[MESSAGE]> APADEMIDE CORE and MODULES are now disabled"

  warning:
  - debug LOG "<script.parsed_key[data.warning_prefix]> <[MESSAGE]>"

  # Handles simple errors. No additionnal message, just formatted.
  error:
  - debug ERROR "<script.parsed_key[data.error_prefix]> <[MESSAGE]>"

  log:
  - if <proc[APADEMIDE].context[DEBUG]>:
    - debug LOG "<script.parsed_key[data.log_prefix]> <[MESSAGE]>"

  NULL:
  - debug LOG "<script.parsed_key[data.log_prefix]> <[MESSAGE]>"
  modules:
    init:
    # Get internal data from the internal flag
    - define DATA <server.flag[_APA_CORE_FLAG]>
    # Hide confirmation from console if config says so
    - if !<[DATA].deep_get[config.console.succeed_humbly]>:
      - define PREFIX <script.parsed_key[data.ok_prefix]>
      - debug LOG "<[PREFIX]> Enabled: <[MESSAGE]>"

    fatal:
    - debug ERROR "<script.parsed_key[data.error_prefix]> <[MESSAGE]> This MODULE is now disabled"
    # bad_denizen_config:
    # - debug ERROR "<script.parsed_key[data.error_prefix]> Module '<[MODULE]>' requires the Denizen config option '<[CONFIG_KEY]>' to be '<[REQUIRED_VALUE]>' (Currently set to '<[CURRENT_VALUE]>')"
