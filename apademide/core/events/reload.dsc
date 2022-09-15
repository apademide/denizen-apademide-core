apa_core_event_reload:
  type: world
  debug: false
  events:
    # Triggers a full reload
    on reload scripts:
    - define DATA <map[SOURCE=RELOAD_SCRIPT]>
    - customevent id:APADEMIDE_CORE_WANTS_RELOAD context:<[DATA]>
    on server start:
    - define DATA <map[SOURCE=SERVER_START]>
    - customevent id:APADEMIDE_CORE_WANTS_RELOAD context:<[DATA]>
