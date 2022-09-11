# Used by MODULES after load/reload to properly register
apa_core_task_register_module:
  type: task
  debug: false
  definitions: MODULE|CONFIG_SCRIPT|INTERNAL_CONFIG_SCRIPT
  script:
  - if <[CONFIG_SCRIPT]> == NULL:
    - run <proc[APADEMIDE].context[TASK.DEBUG]> "context:MODULES.FATAL|Cannot innit APADEMIDE MODULE '<[MODULE]>' without its config script installed."
    - stop

  - if <[INTERNAL_CONFIG_SCRIPT]> == NULL:
    - run <proc[APADEMIDE].context[TASK.DEBUG]> "context:MODULES.FATAL|Cannot innit APADEMIDE MODULE '<[MODULE]>' without its *internal* config script installed."
    - stop

  - define GLOBAL_CONFIG <proc[APADEMIDE].context[config]>
  - narrate <[GLOBAL_CONFIG]>
  - narrate <script[apa_module_permissions_config].data_key[roles.moderator.permissions].deep_keys.parse[unescaped]>