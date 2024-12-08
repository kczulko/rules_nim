# Copyright (C) Dominik Picheta. All rights reserved.
# BSD License. Look at license.txt for more info.

{.used.}

import unittest, os
import testscommon
from nimblepkg/common import cd

suite "check command":
  test "can succeed package":
    cd (rfilesPath("binaryPackage/v1")):
      let (outp, exitCode) = execNimble("check")
      check exitCode == QuitSuccess
      check outp.processOutput.inLines("success")
      check outp.processOutput.inLines("\"binaryPackage\" is valid")

    cd (rfilesPath("packageStructure/a")):
      let (outp, exitCode) = execNimble("check")
      check exitCode == QuitSuccess
      check outp.processOutput.inLines("success")
      check outp.processOutput.inLines("\"a\" is valid")

    cd (rfilesPath("packageStructure/b")):
      let (outp, exitCode) = execNimble("check")
      check exitCode == QuitSuccess
      check outp.processOutput.inLines("success")
      check outp.processOutput.inLines("\"b\" is valid")

    cd (rfilesPath("packageStructure/c")):
      let (outp, exitCode) = execNimble("check")
      check exitCode == QuitSuccess
      check outp.processOutput.inLines("success")
      check outp.processOutput.inLines("\"c\" is valid")

    cd (rfilesPath("packageStructure/x")):
      let (outp, exitCode) = execNimble("check")
      check exitCode == QuitSuccess
      check outp.processOutput.inLines("success")
      check outp.processOutput.inLines("\"x\" is valid")
