apa_core_event_reload:
  type: world
  debug: false
  events:
    # Triggers a full reload
    on reload scripts:
    - customevent id:APADEMIDE_CORE_WANTS_RELOAD context:<map[SOURCE=RELOAD_SCRIPTS]>
    on server start:
    - customevent id:APADEMIDE_CORE_WANTS_RELOAD context:<map[SOURCE=SERVER_START]>
