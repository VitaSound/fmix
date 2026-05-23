\ fmix_version_check.4th
\
\ Reads the project's ./package.4th at load time and records any
\ `key-list dependencies fmix <version>` requirement. Then provides
\ `fmix.assert-min-version`, which exits with a clear error message if
\ the currently installed fmix is older than what the project asks for.
\
\ Idea: tools like fmix / fcov / flint live in the user's $PATH but
\ projects pin a minimum version in their package.4th. When you `cd` into
\ a project that needs a newer fmix than the one in your $PATH, every
\ project-scoped command (test, packages.get) bails out up front instead
\ of misbehaving in subtle ways.
\
\ Supported dependency forms (matched against name `fmix`):
\
\   key-list dependencies fmix 0.5.1
\   key-list dependencies fmix git https://github.com/VitaSound/fmix tag 0.5.1
\
\ The `git ... branch <name>` form is *skipped* (no version => no check).
\
\ This file is loaded by fmix.4th right after fmix_version.4th, so
\ `fmix-ver-data` already holds the installed version when we start.

require fmix_utils.4th
require fmix_version.4th

\ --- Result variable -----------------------------------------------------

2variable fmix.required-fmix-ver
0 0 fmix.required-fmix-ver 2!

: fmix.set-required-fmix-ver ( a u -- )
    fmix.str-dup fmix.required-fmix-ver 2! ;

\ --- Semver parsing & comparison ----------------------------------------

\ ( a u -- a' u' n )  Parse a leading non-negative integer, return the
\ rest of the string and the parsed value. If the prefix is not a number,
\ returns n = 0.
: fmix.parse-uint-prefix
    0 0 2swap >number 2>r d>s 2r> rot ;

\ ( a u -- a' u' )  If the string starts with '.', drop one char.
: fmix.skip-dot
    dup 0= IF EXIT THEN
    over c@ [char] . = IF 1 /string THEN ;

\ ( a u -- major minor patch )  Best-effort parse of "X.Y.Z". Missing
\ components default to 0. Non-numeric components also collapse to 0,
\ which means we never crash on a weird version string — we just compare
\ conservatively.
: fmix.parse-semver
    fmix.parse-uint-prefix >r
    fmix.skip-dot
    fmix.parse-uint-prefix >r
    fmix.skip-dot
    fmix.parse-uint-prefix >r
    2drop
    r> r> r> swap rot ;

\ ( a-ma a-mi a-pa b-ma b-mi b-pa -- {-1|0|1} )  Compare a vs b.
: fmix.semver-cmp { am ami apa bm bmi bpa -- n }
    am bm <  IF -1 EXIT THEN
    am bm >  IF  1 EXIT THEN
    ami bmi < IF -1 EXIT THEN
    ami bmi > IF  1 EXIT THEN
    apa bpa < IF -1 EXIT THEN
    apa bpa > IF  1 EXIT THEN
    0 ;

\ --- Mini-parser for ./package.4th, scoped via MARKER -------------------
\
\ While ./package.4th is `included`, the words below define its DSL. After
\ scanning we drop them via MARKER so they cannot collide with the proper
\ parser in fmix_packages_get.4th.

MARKER fmix.discard-vercheck-parser

: forth-package ;
: end-forth-package ;
: key-value 0 parse 2drop ;

\ Parses the rest of a `key-list dependencies fmix ...` line (we have
\ already consumed `dependencies` and `fmix`).
: fmix.parse-fmix-dep-rest
    parse-name 2dup nip 0= IF 2drop EXIT THEN
    2dup s" git" compare 0= IF
        2drop
        parse-name 2drop                         \ skip URL
        parse-name 2dup s" tag" compare 0= IF
            2drop parse-name fmix.set-required-fmix-ver
        ELSE
            2drop parse-name 2drop               \ branch <name> — no version
        THEN
    ELSE
        fmix.set-required-fmix-ver               \ `dependencies fmix X.Y.Z`
    THEN
    0 parse 2drop ;

: key-list
    parse-name 2dup s" dependencies" compare 0= IF
        2drop
        parse-name 2dup s" fmix" compare 0= IF
            2drop fmix.parse-fmix-dep-rest
        ELSE
            2drop 0 parse 2drop
        THEN
    ELSE
        2drop 0 parse 2drop
    THEN ;

\ Scan the project's package.4th if present. Silent no-op outside a project.
: fmix.scan-required-version
    fmix.project-path s" package.4th" fmix.fs-join
    2dup file-status nip 0= IF
        included
    ELSE
        2drop
    THEN ;

fmix.scan-required-version

fmix.discard-vercheck-parser

\ --- Public: enforce self >= required at command entry ------------------

: fmix.assert-min-version
    fmix.required-fmix-ver 2@ nip 0= IF EXIT THEN
    fmix-ver-data            2@ fmix.parse-semver    \ a = self
    fmix.required-fmix-ver 2@ fmix.parse-semver      \ b = required
    fmix.semver-cmp -1 = IF                          \ self < required → fail
        cr s" [ERROR] This project requires fmix " type
        fmix.required-fmix-ver 2@ type
        s"  or higher, but you have " type
        fmix-ver-data 2@ type cr
        s"        Update fmix (https://github.com/VitaSound/fmix) and retry." type cr
        fmix.exit
    THEN ;
