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
      # If false, no debug will be sent to the console when various APADEMIDE CORE features are used.
      debug: false
    #- Configuration for players /commands
    commands:
      permissions:
        # Root permission
        # Will be used for all commands as the base permission
        # This permission is used by commands *handled by* APADEMIDE CORE
        # i.e, the /money APADEMIDE COMMAND has the 'MONEY' permission by default
        # > it means a player should actually have APADEMIDE.MONEY to run it
        # It is the 'namespace' of all APADEMIDE COMMANDS
        root: APADEMIDE
        # The permission to use the /apademide command,
        # which should be an admin- or at least moderator-permission
        # This permission could notably allow people to reload the CORE
        core: APA_CORE

    #- Configuration of various behaviors on load/reload
    initialization:
      # Toggles the full reload of APADEMIDE CORE after a Denizen reload
      # > It'll still be reloaded after a server restart or with the APADEMIDE CORE's reload command
      # Defaults to true
      reload_on_reload: true

      # Allows to store the Denizen config in APADEMIDE CORE's internal flag
      # It is used by MODULES that require specific config options to work properly
      # i.e: The WebServer module (which may or may not exists as you read it) requires Commands.WebServer.Allow set to true to work

      # If true, Denizen's config will be stored in the internal flag and modules will read that flag to confirm the config is correctly set for them to work
      # If false, Denizen's config will not be read, affected modules will be enabled by default and probably break
      store_denizen_config: true

      # Enables or disables full analysis on reload.
      # The reload script checks and validates various data
      # >   Checks if some required scripts are present, confirms all required config options are there, …
      # It also enables proper debug
      # >   APADEMIDE CORE has built-in debug features powered by Denizen's debug command.
      # >   However, for that debug to work, a few internal scripts are required
      # >   Without the full analysis, if you happen to have missing scripts or data somewhere, not only it's almost certain things will break, but you won't have any debug to help you figure out where.

      # You can still disable it if you know what you're doing and why you're doing it.
      # If you do so, keep in mind that many tags have no fallback since that analysis is supposed to confirm the values are fine
      full_analysis: true
      # Same as above, but for MODULES
      full_module_analysis: true
