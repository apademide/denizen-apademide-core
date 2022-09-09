apa_module_permissions_config:
  type: data
  debug: false

  # Fallback value used to complete missing data from other roles.
  display:
    name: Player
    prefix: <gray>
    suffix: foo
  roles:
    admin:
      name: Admin
      prefix: <red>
      suffix: <&[BASE]>aaaaa
      permissions:
        '*': true
    moderator:
      name: Modo
      permissions:
        foo.bar: true
        foo.rab: false
        something:
          nice: true
          not_nice: false
        very.nice:
          test:
            test.test2: true
            test.test3: true
          test.test.test4: true