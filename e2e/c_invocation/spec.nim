import unittest, math

proc addTwoIntegers(a, b: cint): cint {.importc.}

test "addTwoIntegers":
    check (addTwoIntegers(3, 7) == 10)
