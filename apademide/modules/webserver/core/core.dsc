apa_module_webserver_register:
  type: world
  debug: false
  events:
    after custom event id:APADEMIDE_CORE_RELOADED server_flagged:_APA_CORE_FLAG.INNIT:
    # Defines the module ID
    - define MODULE WebServer
    # Get MODULE's user config scripts
    - define CONFIG_SCRIPT <script[apa_module_webserver_config].if_null[NULL]>
    # Get MODULE's internal config script
    - define INTERNAL_CONFIG_SCRIPT <script[apa_module_webserver_internal_data].if_null[NULL]>

    - inject <proc[apademide].context[MODULE.REGISTER]>

apa_module_webserver_world:
  type: world
  debug: false
  events:
    on custom event id:APADEMIDE_CORE_RELOADED:
    - announce moo 