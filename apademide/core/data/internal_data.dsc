apa_core_internal_data:
  type: data
  debug: false
  script:
    #- ALL REQUIRED SCRIPTS
    # This map is used on load/reload to confirm every absolutely required script is there
    required:
      apademide: procedure
      apa_core_proc_input_validator: procedure
      apa_core_procedures_data: data
      apa_core_reload: world
      apa_core_task_register_module: task
      apa_core_debug: task
  config:
    required:
      #- ALL REQUIRED CONFIG OPTIONS
      # This map is used to check wether all *required* config options are set in config.dsc
      console:
        succeed_humbly: bool
        debug: bool
      flags:
        root: string
      commands:
        permissions:
          root: string
      initialization:
        store_denizen_config: bool
