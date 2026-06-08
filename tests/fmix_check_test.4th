\ tests/fmix_check_test.4th — quality gate helpers (no subprocess flint/fcov)

require ../fmix_utils.4th
require ../fmix_check_config.4th
require ../fmix_check.4th

fmix.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmix.fs-join required

\ fail-under: CLI overrides package.4th config
T{ -1 fmix.check-fail-under-cli ! 40 fmix.set-fcov-fail-under
    fmix.check-fail-under-threshold -> 40 }T
T{ 55 fmix.check-fail-under-cli ! 40 fmix.set-fcov-fail-under
    fmix.check-fail-under-threshold -> 55 }T
T{ -1 fmix.check-fail-under-cli ! -1 fmix.check-fcov-fail-under !
    fmix.check-fail-under-threshold -> -1 }T
