# Nim rules for Bazel

![CI](https://github.com/kczulko/rules_nim/actions/workflows/workflow.yaml/badge.svg)
![linux_amd64](https://img.shields.io/badge/platform-linux__amd64-orange)
![osx_amd64](https://img.shields.io/badge/platform-osx__amd64-orange)

## Installation

`rules_nim` has not been yet published to BCR. Please add following `git_override` to your `MODULE.bazel`:

```python
git_override(
    module_name = "rules_nim",
    remote = "https://github.com/kczulko/rules_nim",
    commit = PUT_SPECIFIC_COMMIT_HERE,
)

# Nim toolchain registration - choose one of supported Nim versions.
nim = use_extension("@rules_nim//nim:extensions.bzl", "nim")
nim.toolchain(nim_version = "2.2.0")
use_repo(nim, "nim_toolchains")
register_toolchains("@nim_toolchains//:all")

```

## Public api

### Rules

- [nim_module][nim_module] - Creates a module from a set of `*.nim` files.
- [nim_cc_binary][nim_cc_binary] - Creates executable binary from a Nim code.
- [nim_cc_library][nim_cc_library] - Creates a `cc_library` target from a Nim code.
- [nim_cc_test][nim_cc_test] - Creates test executable from a Nim code.

### Repository rules

- [nimble_lock][nimble_install] - Obtains dependencies from `nimble.lock` (native Bazel repository cache support).
- [nimble_install][nimble_install] - Obtains dependencies through running `nimble` executable (no caching).

## Usage examples

Check the [e2e examples](./e2e) directory:
- [nim_cc_binary](./e2e/nim_cc_binary) - Simple example of [nim_cc_binary][nim_cc_binary] usage.
- [nim_cc_library](./e2e/nim_cc_library) - Simple example of [nim_cc_library][nim_cc_library] usage.
- [nim_cc_test](./e2e/nim_cc_test) - Simple example of [nim_cc_test][nim_cc_test] usage.
- [numericalnim](./e2e/numericalnim) - Shows the usage of `rules_nim` for a [numericalnim][numericalnim] project.
- [c_invocation](./e2e/c_invocation) - Shows the [backend C invocation in Nim][backend_c_invocation_example].
- [nim_invocation_from_c](./e2e/nim_invocation_from_c) - Shows the [Nim invocation from C][nim_invocation_from_c].

[nim_module]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_module
[nimble_install]: https://github.com/kczulko/rules_nim/blob/master/docs/repo_rules.md#nimble_install
[nimble_lock]: https://github.com/kczulko/rules_nim/blob/master/docs/repo_rules.md#nimble_lock
[nim_cc_test]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_test
[nim_cc_library]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_library
[nim_cc_binary]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_binary
[numericalnim]: https://github.com/SciNim/numericalnim
[backend_c_invocation_example]: https://nim-lang.org/docs/backends.html#nim-code-calling-the-backend-c-invocation-example
[nim_invocation_from_c]: https://nim-lang.org/docs/backends.html#backend-code-calling-nim-nim-invocation-example-from-c
