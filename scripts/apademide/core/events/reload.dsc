apa_core_event_reload:
  type: world
  debug: false
  events:
    after reload scripts:
    - define DATA <map[SOURCE=RELOAD_SCRIPT]>
    - customevent id:APADEMIDE_CORE_RELOAD context:<[DATA]>
    after server start:
    - define DATA <map[SOURCE=SERVER_START]>
    - customevent id:APADEMIDE_CORE_RELOAD context:<[DATA]>
