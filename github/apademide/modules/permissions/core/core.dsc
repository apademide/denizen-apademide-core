apa_module_permissions_register:
  type: task
  debug: false
  script:
    - define GLOBAL_CONFIG <proc[APADEMIDE].context[config]>
    - narrate <[GLOBAL_CONFIG]>
    - narrate <script[apa_module_permissions_config].data_key[roles.moderator.permissions].deep_keys.parse[unescaped]>

apa_module_permissions_world:
  type: world
  debug: false
  events:
    on custom event id:APADEMIDE_CORE_RELOADED:
    - announce moop