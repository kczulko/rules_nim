# Nim rules for Bazel

![CI](https://github.com/kczulko/rules_nim/actions/workflows/workflow.yaml/badge.svg)
![osx_amd64](https://img.shields.io/badge/platform-linux__amd64-orange)

## Installation

From the release you wish to use:
<https://github.com/myorg/rules_nim/releases>
copy the WORKSPACE snippet into your `WORKSPACE` file.

To use a commit rather than a release, you can point at any SHA of the repo.

For example to use commit `abc123`:

1. Replace `url = "https://github.com/myorg/rules_mylang/releases/download/v0.1.0/rules_mylang-v0.1.0.tar.gz"` with a GitHub-provided source archive like `url = "https://github.com/myorg/rules_mylang/archive/abc123.tar.gz"`
1. Replace `strip_prefix = "rules_mylang-0.1.0"` with `strip_prefix = "rules_mylang-abc123"`
1. Update the `sha256`. The easiest way to do this is to comment out the line, then Bazel will
   print a message with the correct value. Note that GitHub source archives don't have a strong
   guarantee on the sha256 stability, see
   <https://github.blog/2023-02-21-update-on-the-future-stability-of-source-code-archives-and-hashes/>

## Public api

### Rules

- [nim_module](https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_module) Creates a module from a set of `*.nim` files.
- [nim_cc_binary](https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_binary) Creates executable binary from a Nim code.
- [nim_cc_library](https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_library) Creates a `cc_library` target from a Nim code.
- [nim_cc_test](https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_test) Creates test executable from a Nim code.

### Repository rules

- [nimble_install](https://github.com/kczulko/rules_nim/blob/master/docs/repo_rules.md#nimble_install) - Obtains dependencies throught running `nimble` executable.

## Usage examples

Check the [e2e examples](./e2e) directory:
- [nim_cc_binary](./e2e/nim_cc_binary) Simple example of [nim_cc_binary][nim_cc_binary] usage.
- [nim_cc_library](./e2e/nim_cc_library) Simple example of [nim_cc_library][nim_cc_library] usage.
- [nim_cc_test](./e2e/nim_cc_test) Simple example of [nim_cc_test][nim_cc_test] usage.
- [numericalnim](./e2e/numericalnim) Shows the usage of `rules_nim` for a [numericalnim][numericalnim] project.
- [c_invocation](./e2e/c_invocation) Shows the [backend C invocation in Nim][backend_c_invocation_example].
- [nim_invocation_from_c](./e2e/nim_invocation_from_c) Shows the [Nim invocation from C][nim_invocation_from_c].

[nim_module]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_module
[nimble_install]: https://github.com/kczulko/rules_nim/blob/master/docs/repo_rules.md#nimble_install
[nim_cc_test]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_test
[nim_cc_library]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_library
[nim_cc_binary]: https://github.com/kczulko/rules_nim/blob/master/docs/rules.md#nim_cc_binary
[numericalnim]: https://github.com/SciNim/numericalnim
[backend_c_invocation_example]: https://nim-lang.org/docs/backends.html#nim-code-calling-the-backend-c-invocation-example
[nim_invocation_from_c]: https://nim-lang.org/docs/backends.html#backend-code-calling-nim-nim-invocation-example-from-c
