import unittest, math

test "Equality ==":
    let v1 = true
    let v2 = true
    check (v1 == v2) == true
    check (v1 == v1) == true