apa_module_enssentialsnt_config:
  type: data
  debug: false

  # This permission will be added to commands inside this MODULE by default *after the CORE permission*
  # > For exemple, the default root permission for *APADEMIDE CORE* is "APADEMIDE"
  # > Assuming you didn't change it, the permission here would be added to form "APADEMIDE.ESSENTIALSNT" as the basic permission required.
  # The result is all permissions defined in this MODULE's commands would be appended to APADEMIDE.ESSENTIALSNT
  commands:
    permissions:
      root: ESSENTIALSNT