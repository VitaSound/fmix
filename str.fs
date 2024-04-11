\ string words

\ : char+ 

\ place string to variable
\ Example:
\  create callsign 10 chars allot
\  S" UA3MQJ/B" callsign place_str
: place_str over over >r >r char+ swap chars cmove r> r> c! 
  drop drop drop
;

\ append const to string variable
\ Example:
\  s" UA3MQJ/B " message append_str
\ append var to string variable
\  callsign count message append_str
: append_str                         ( a1 n2 a2 --)
    over over                  \ duplicate target and count           
    >r >r                      \ save them on the return stack
    count chars +              \ calculate offset target
    swap chars move            \ now move the source string
    r> r>                      \ get target and count
    dup >r                     \ duplicate target and save one
    c@ +                       \ calculate new count
    r> c!                      \ get address and store
;

\ print string variable
\ Example:
\  message print_str
: print_str count type ;