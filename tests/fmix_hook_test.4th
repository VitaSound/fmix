\ tests/fmix_hook_test.4th — hook marker detection

require ../fmix_utils.4th
require ../fmix_hook.4th

fmix.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmix.fs-join required

T{ s" # vitasound-fmix-hook" fmix.hook-marker? -> true }T
T{ s" other hook" fmix.hook-marker? -> false }T
