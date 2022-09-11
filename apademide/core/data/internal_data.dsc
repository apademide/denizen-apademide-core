apa_core_internal_data:
  type: data
  debug: false
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
