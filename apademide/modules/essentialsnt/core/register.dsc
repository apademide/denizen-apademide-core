apa_module_essentialsnt_register:
  type: world
  debug: false
  events:
    on custom event id:APADEMIDE_CORE_RELOADED server_flagged:_APA_CORE_FLAG.INIT:
    # Get MODULE's user config scripts
    - define CONFIG_SCRIPT <script[apa_module_enssentialsnt_config]>
    # Get MODULE's internal config script
    - define INTERNAL_CONFIG_SCRIPT <script[apa_module_essentialsnt_internal_data]>
    # Inject the script that'll try to register the module
    - inject <proc[apademide].context[MODULE.REGISTER]>