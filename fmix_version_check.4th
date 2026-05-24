\ fmix_version_check.4th
\
\ Reads the project's ./package.4th at load time and records any
\ runtime requirement on fmix itself, then provides
\ `fmix.assert-min-version` which bails out with a clear error when
\ the installed fmix doesn't satisfy the requirement.
\
\ As of fmix 0.7.1 all requirement parsing and matching is delegated to
\ the standalone `fsemver` package (vendored at
\ ./forth-packages/fsemver/0.1.0/). This file only owns:
\   - the mini-parser for ./package.4th (key-value / key-list DSL),
\   - the captured requirement string,
\   - the error messages and exit policy.
\
\ Supported requirement forms (delegated to fsemver — see its README
\ for the full operator table):
\
\   key-value fmix ~> 0.7          \ MAJOR pinned
\   key-value fmix ~> 0.7.2        \ MAJOR.MINOR pinned
\   key-value fmix >= 0.7.0        \ minimum
\   key-value fmix == 0.7.0        \ exact
\   key-value fmix >  0.6.5        \ strictly greater
\   key-value fmix <  1.0.0        \ strictly less
\   key-value fmix <= 0.7.5        \ less-or-equal
\   key-value fmix 0.7.0           \ bare = >= 0.7.0
\
\ The legacy fmix-0.6 form
\
\   key-list dependencies fmix 0.7.0
\
\ is no longer accepted: it conflated runtime tooling with library
\ dependencies, and there is no `fmix` package on theforth.net for
\ `fmix packages.get` to fetch. Loading a project that still uses it
\ aborts with an error and a migration hint.
\
\ This file is loaded by fmix.4th right after fmix_version.4th, so
\ `fmix-ver-data` already holds the installed version when we start.

require fmix_utils.4th
require fmix_version.4th
require forth-packages/fsemver/0.1.0/fsemver.4th

\ --- Stored requirement -------------------------------------------------

\ Raw requirement string from `key-value fmix <...>` (e.g. "~> 0.7").
\ Empty when the project doesn't pin fmix.
2variable fmix.required-fmix-req
0 0 fmix.required-fmix-req 2!

\ Flag set when we detect the legacy `key-list dependencies fmix ...`
\ form. Reported by assert-min-version with a migration hint.
variable fmix.legacy-self-dep?
0 fmix.legacy-self-dep? !

: fmix.set-required-fmix-req ( a u -- )
    fmix.str-dup fmix.required-fmix-req 2! ;

\ --- Mini-parser for ./package.4th, scoped via MARKER -------------------
\
\ While the project's ./package.4th is `included`, the words below
\ define its DSL. We drop them via MARKER right after the scan so they
\ cannot collide with the proper parser in fmix_packages_get.4th.

MARKER fmix.discard-vercheck-parser

: forth-package ;
: end-forth-package ;

\ Capture `key-value fmix <rest-of-line>`; ignore every other key-value.
: key-value
    parse-name 2dup s" fmix" compare 0= IF
        2drop 0 parse fsemver.strip-ws fmix.set-required-fmix-req
    ELSE
        2drop 0 parse 2drop
    THEN ;

\ Detect the legacy `key-list dependencies fmix <ver>` form so we can
\ surface a clear migration error.
: key-list
    parse-name 2dup s" dependencies" compare 0= IF
        2drop
        parse-name 2dup s" fmix" compare 0= IF
            2drop true fmix.legacy-self-dep? !
            0 parse 2drop
        ELSE
            2drop 0 parse 2drop
        THEN
    ELSE
        2drop 0 parse 2drop
    THEN ;

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

: fmix.warn-legacy
    cr s" [ERROR] Project's package.4th uses the legacy form:" type cr
    s"             key-list dependencies fmix <version>" type cr
    s"         As of fmix 0.7.0 this is no longer supported." type cr
    s"         fmix is a runtime/tooling requirement, not a library" type cr
    s"         dependency (and there is no `fmix` package on" type cr
    s"         theforth.net to fetch). Migrate to:" type cr
    s"             key-value fmix ~> <X.Y>" type cr
    s"         Examples:" type cr
    s"             key-value fmix ~> 0.7        \ accepts >=0.7.0 <1.0.0" type cr
    s"             key-value fmix ~> 0.7.2      \ accepts >=0.7.2 <0.8.0" type cr
    s"             key-value fmix 0.7.0         \ bare, accepts >=0.7.0" type cr ;

: fmix.warn-invalid-req
    cr s" [ERROR] Invalid fmix version requirement in package.4th:" type cr
    s"             key-value fmix " type fmix.required-fmix-req 2@ type cr
    s"         Expected one of: ~> X.Y, ~> X.Y.Z, >= X.Y.Z, == X.Y.Z," type cr
    s"                          >  X.Y.Z, <  X.Y.Z, <= X.Y.Z, or bare X.Y.Z" type cr ;

: fmix.warn-too-old
    cr s" [ERROR] This project requires fmix " type
    fmix.required-fmix-req 2@ type
    s" , but you have " type fmix-ver-data 2@ type cr
    s"         Update fmix (https://github.com/VitaSound/fmix) and retry." type cr ;

: fmix.assert-min-version
    fmix.legacy-self-dep? @ IF
        fmix.warn-legacy fmix.exit
    THEN
    fmix.required-fmix-req 2@ nip 0= IF EXIT THEN

    fmix.required-fmix-req 2@ fsemver.parse-req { rop rma rmi rpa rok }
    rok 0= IF
        fmix.warn-invalid-req fmix.exit
    THEN

    fmix-ver-data 2@ fsemver.parse-version-parts drop { sma smi spa }
    rma rmi rpa rop sma smi spa fsemver.req-matches? 0= IF
        fmix.warn-too-old fmix.exit
    THEN ;
