include ~/fmix/forth-packages/ttester/1.1.0/ttester.4th

\ see examples:
\ https://forth-standard.org/standard/testsuite

T{ 1 2 3 SWAP -> 1 3 2 }T

\ fmix_utils.4th 
\ str_prepend

T{ s" 1" s" 2" str_prepend s" 21" COMPARE 0= -> TRUE }T

\ s" from.txt" touch_file
\ s" from.txt" s" from2.txt" copy_file
\ s" from.txt" delete_file
\ s" from2.txt" delete_file
\ s" echo abcd > test.txt" system
\ s" test.txt" s" ab" s" AB" sed

bye
