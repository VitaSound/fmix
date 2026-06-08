forth-package
    key-value name fmix
    key-value version 0.8.0
    key-value description Forth package/build tool (project scaffolding, dependency fetching, test runner)
    key-value license COPL
    key-value main fmix.4th
    key-value flint ~> 0.3
    key-value fcov ~> 0.3
    key-list fcov-exclude priv
    key-list fcov-exclude tests/fixtures
    key-list tags build-tool
    key-list tags package-manager
    key-list tags test-runner
    key-list tags gforth
    key-list dependencies fsemver git https://github.com/VitaSound/fsemver tag 0.1.0
    key-list dependencies ttester git https://github.com/VitaSound/ttester tag 1.2.1
    key-list dependencies f 0.2.4
end-forth-package