load("@rules_nim//nim/private/nimble:nimble_install.bzl", _nimble_install = "nimble_install")
load("@rules_nim//nim/private/nimble:nimble_lock.bzl", _nimble_lock = "nimble_lock")

nimble_install = _nimble_install
nimble_lock = _nimble_lock
