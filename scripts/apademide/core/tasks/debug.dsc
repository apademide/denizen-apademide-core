apa_core_debug:
  type: task
  debug: false
  definitions: TYPE|MESSAGE
  data:
    error_prefix: APADEMIDE CORE ERROR<&co>
    ok_prefix: <green><bold>APA -<&gt><white>
    warning_prefix: <gold><bold>APA -<&gt><white>

  # Injects the specific type of output
  script:
  - inject <script> path:<[TYPE].if_null[DEFAULT]>


  # Script block that runs to output informations when APADEMIDE CORE is initialized
  innit:
  # Get internal data from the internal flag
  - define DATA <server.flag[APA_CORE_FLAG]>
  - define ROOT <[DATA].get[ROOT]>
  # Hide confirmation from console if config says so
  - if !<[DATA].get[CONFIG].data_key[console.succeed_humbly]>:
    - define PREFIX <script.parsed_key[data.ok_prefix]>
    - debug APPROVAL "APADEMIDE CORE is now activated."
    - debug LOG "<[PREFIX]> Enabled at: <[DATA].get[INNIT].format>"
    - debug LOG "<[PREFIX]> Root flag name: <[ROOT]>"
    - debug LOG "<[PREFIX]> Load/Reload source: <[DATA].get[LAST_RELOAD_SOURCE]>"
  # Warning if the root server flag doesn't exists
  # Could inform the user of a potential bug or typo in the config
  - if !<server.has_flag[<[ROOT]>]>:
    - debug LOG "<script.parsed_key[data.warning_prefix]> No data has been found at server flag '<[ROOT]>'. If you're initializing APADEMIDE CORE for the first time or you intentionnaly editted/deleted that flag, ignore this message."


  # Informs the user that APADEMIDE CORE failed to innit for some reason
  fatal:
  - debug ERROR "<script.parsed_key[data.error_prefix]> <[MESSAGE]> APADEMIDE CORE and MODULES are now disabled"