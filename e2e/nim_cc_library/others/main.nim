proc NimMain() {.cdecl, importc.}

proc library_init() {.exportc, dynlib, cdecl.} =
  NimMain()
  echo "Hello from our dynamic library!"

proc library_do_something(arg: cint): cint {.exportc, dynlib, cdecl.} =
  echo "We got the argument ", arg
  echo "Returning 0 to indicate that everything went fine!"
  return 0 # This will be automatically converted to a cint

proc add5(arg: cint): cint {.exportc, dynlib, cdecl.} =
  return arg + 5

proc library_deinit() {.exportc, dynlib, cdecl.} =
  echo "Nothing to do here since we don't have any global memory"
  GC_FullCollect()