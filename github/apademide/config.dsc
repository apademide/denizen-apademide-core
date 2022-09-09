apa_core_config:
  type: data
  debug: false
  config:
    flags:
      #- APADEMIDE CORE flag's base name
      #  Every data that will be stored for APADEMIDE CORE and APADEMIDE MODULES will be stored under that root flag name
      #  > Only exception is the server flag "APA_CORE_FLAG", which is hard-coded and contains this value among some other internal ones
      #    > If you already use that server flag, well, stop.
      ## Can't be 'NULL' // Make it a flag-friendly name or let as-is
      root: APADEMIDE
    console:
      # If true, no output will be sent to the console when APADEMIDE CORE is succesfully enabled.
      succeed_humbly: false

    #- Configuration for players /commands
    commands:
      permissions:
        # Root permission
        # Will be used for all commands as the base name
        root: APADEMIDE