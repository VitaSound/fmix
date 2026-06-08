\ fmix_check_config.4th — optional fcov-fail-under from ./package.4th

require fmix_utils.4th

variable fmix.check-fcov-fail-under
-1 fmix.check-fcov-fail-under !

: fmix.set-fcov-fail-under ( n -- )
    fmix.check-fcov-fail-under ! ;

: fmix.scan-check-config
    -1 fmix.check-fcov-fail-under ! ;
