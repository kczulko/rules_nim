<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="nim_cc_binary"></a>

## nim_cc_binary

<pre>
load("@rules_nim//nim:defs.bzl", "nim_cc_binary")

nim_cc_binary(<a href="#nim_cc_binary-name">name</a>, <a href="#nim_cc_binary-deps">deps</a>, <a href="#nim_cc_binary-data">data</a>, <a href="#nim_cc_binary-additional_compiler_inputs">additional_compiler_inputs</a>, <a href="#nim_cc_binary-additional_linker_inputs">additional_linker_inputs</a>, <a href="#nim_cc_binary-conlyopts">conlyopts</a>,
              <a href="#nim_cc_binary-copts">copts</a>, <a href="#nim_cc_binary-cxxopts">cxxopts</a>, <a href="#nim_cc_binary-defines">defines</a>, <a href="#nim_cc_binary-includes">includes</a>, <a href="#nim_cc_binary-linkopts">linkopts</a>, <a href="#nim_cc_binary-linkstatic">linkstatic</a>, <a href="#nim_cc_binary-local_defines">local_defines</a>, <a href="#nim_cc_binary-main">main</a>, <a href="#nim_cc_binary-proj_cfg">proj_cfg</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nim_cc_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nim_cc_binary-deps"></a>deps |  The list of nim or cc dependencies of the current target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_binary-data"></a>data |  The list of files needed by this target at runtime. See general comments about data at 'Typical attributes' defined by most build rules.<br><br>If a data is the name of a generated file, then this target automatically depends on the generating target.<br><br>If a data is a rule name, then this target automatically depends on that rule, and that rule's outs are automatically added to this target's data files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_binary-additional_compiler_inputs"></a>additional_compiler_inputs |  List of additional files needed for compilation of srcs   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_binary-additional_linker_inputs"></a>additional_linker_inputs |  Pass these files to the C++ linker command.<br><br>For example, compiled Windows .res files can be provided here to be embedded in the binary target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_binary-conlyopts"></a>conlyopts |  Add these options to the C compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-copts"></a>copts |  Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization. Each string in this attribute is added in the given order to COPTS before compiling the binary target. The flags take effect only for compiling this target, not its dependencies, so be careful about header files included elsewhere. All paths should be relative to the workspace, not to the current package.<br><br>If the package declares the feature no_copts_tokenization, Bourne shell tokenization applies only to strings that consist of a single "Make" variable.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-cxxopts"></a>cxxopts |  Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-defines"></a>defines |  List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line to this target, as well as to every rule that depends on it. Be very careful, since this may have far-reaching effects. When in doubt, add define values to local_defines instead.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-includes"></a>includes |  List of include dirs to be added to the compile line. Subject to "Make variable" substitution. Each string is prepended with -isystem and added to COPTS. Unlike COPTS, these flags are added for this rule and every rule that depends on it. (Note: not the rules it depends upon!) Be very careful, since this may have far-reaching effects. When in doubt, add "-I" flags to COPTS instead.<br><br>Headers must be added to srcs or hdrs, otherwise they will not be available to dependent rules when compilation is sandboxed (the default).   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-linkopts"></a>linkopts |  Add these flags to the C++ linker command. Subject to "Make" variable substitution, Bourne shell tokenization and label expansion. Each string in this attribute is added to LINKOPTS before linking the binary target. Each element of this list that does not start with $ or - is assumed to be the label of a target in deps. The list of files generated by that target is appended to the linker options. An error is reported if the label is invalid, or is not declared in deps.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-linkstatic"></a>linkstatic |  "Link the artifact in static mode.<br><br>For nim_cc_binary and nim_cc_test: link the binary in static mode. For nim_cc_library.link_static: see below.<br><br>By default this option is on for cc_binary and off for the rest.<br><br>If enabled and this is a binary or test, this option tells the build tool to link in .a's instead of .so's for user libraries whenever possible. System libraries such as libc (but not the C/C++ runtime libraries, see below) are still linked dynamically, as are libraries for which there is no static library. So the resulting executable will still be dynamically linked, hence only mostly static.<br><br>There are really three different ways to link an executable:<br><br>- STATIC with fully_static_link feature, in which everything is linked statically; e.g. "gcc -static foo.o libbar.a libbaz.a -lm".   This mode is enabled by specifying fully_static_link in the features attribute. - STATIC, in which all user libraries are linked statically (if a static version is available), but where system libraries (excluding C/C++ runtime libraries) are linked dynamically, e.g. "gcc foo.o libfoo.a libbaz.a -lm".   This mode is enabled by specifying linkstatic=True. - DYNAMIC, in which all libraries are linked dynamically (if a dynamic version is available), e.g. "gcc foo.o libfoo.so libbaz.so -lm".   This mode is enabled by specifying linkstatic=False.<br><br>If the linkstatic attribute or fully_static_link in features is used outside of //third_party please include a comment near the rule to explain why.<br><br>The linkstatic attribute has a different meaning if used on a cc_library() rule. For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.<br><br>There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area.<br><br>For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.<br><br>There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area.   | Boolean | optional |  `True`  |
| <a id="nim_cc_binary-local_defines"></a>local_defines |  List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line for this target, but not to its dependents.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_binary-main"></a>main |  The nim file containg executable logic.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="nim_cc_binary-proj_cfg"></a>proj_cfg |  The project's configuration file.<br><br>Doesn't have to be named exactly as the 'main' file. rules_nim assures the name consistency during build phase.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="nim_cc_library"></a>

## nim_cc_library

<pre>
load("@rules_nim//nim:defs.bzl", "nim_cc_library")

nim_cc_library(<a href="#nim_cc_library-name">name</a>, <a href="#nim_cc_library-deps">deps</a>, <a href="#nim_cc_library-data">data</a>, <a href="#nim_cc_library-additional_compiler_inputs">additional_compiler_inputs</a>, <a href="#nim_cc_library-additional_linker_inputs">additional_linker_inputs</a>, <a href="#nim_cc_library-alwayslink">alwayslink</a>,
               <a href="#nim_cc_library-conlyopts">conlyopts</a>, <a href="#nim_cc_library-copts">copts</a>, <a href="#nim_cc_library-cxxopts">cxxopts</a>, <a href="#nim_cc_library-defines">defines</a>, <a href="#nim_cc_library-includes">includes</a>, <a href="#nim_cc_library-linkopts">linkopts</a>, <a href="#nim_cc_library-linkstatic">linkstatic</a>, <a href="#nim_cc_library-local_defines">local_defines</a>,
               <a href="#nim_cc_library-main">main</a>, <a href="#nim_cc_library-proj_cfg">proj_cfg</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nim_cc_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nim_cc_library-deps"></a>deps |  The list of nim or cc dependencies of the current target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_library-data"></a>data |  The list of files needed by this target at runtime. See general comments about data at 'Typical attributes' defined by most build rules.<br><br>If a data is the name of a generated file, then this target automatically depends on the generating target.<br><br>If a data is a rule name, then this target automatically depends on that rule, and that rule's outs are automatically added to this target's data files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_library-additional_compiler_inputs"></a>additional_compiler_inputs |  List of additional files needed for compilation of srcs   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_library-additional_linker_inputs"></a>additional_linker_inputs |  Pass these files to the C++ linker command.<br><br>For example, compiled Windows .res files can be provided here to be embedded in the binary target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_library-alwayslink"></a>alwayslink |  If 1, any binary that depends (directly or indirectly) on this C++ library will link in all the object files for the files listed in srcs, even if some contain no symbols referenced by the binary. This is useful if your code isn't explicitly called by code in the binary, e.g., if your code registers to receive some callback provided by some service.   | Boolean | optional |  `False`  |
| <a id="nim_cc_library-conlyopts"></a>conlyopts |  Add these options to the C compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-copts"></a>copts |  Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization. Each string in this attribute is added in the given order to COPTS before compiling the binary target. The flags take effect only for compiling this target, not its dependencies, so be careful about header files included elsewhere. All paths should be relative to the workspace, not to the current package.<br><br>If the package declares the feature no_copts_tokenization, Bourne shell tokenization applies only to strings that consist of a single "Make" variable.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-cxxopts"></a>cxxopts |  Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-defines"></a>defines |  List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line to this target, as well as to every rule that depends on it. Be very careful, since this may have far-reaching effects. When in doubt, add define values to local_defines instead.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-includes"></a>includes |  List of include dirs to be added to the compile line. Subject to "Make variable" substitution. Each string is prepended with -isystem and added to COPTS. Unlike COPTS, these flags are added for this rule and every rule that depends on it. (Note: not the rules it depends upon!) Be very careful, since this may have far-reaching effects. When in doubt, add "-I" flags to COPTS instead.<br><br>Headers must be added to srcs or hdrs, otherwise they will not be available to dependent rules when compilation is sandboxed (the default).   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-linkopts"></a>linkopts |  Add these flags to the C++ linker command. Subject to "Make" variable substitution, Bourne shell tokenization and label expansion. Each string in this attribute is added to LINKOPTS before linking the binary target. Each element of this list that does not start with $ or - is assumed to be the label of a target in deps. The list of files generated by that target is appended to the linker options. An error is reported if the label is invalid, or is not declared in deps.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-linkstatic"></a>linkstatic |  "Link the artifact in static mode.<br><br>For nim_cc_binary and nim_cc_test: link the binary in static mode. For nim_cc_library.link_static: see below.<br><br>By default this option is on for cc_binary and off for the rest.<br><br>If enabled and this is a binary or test, this option tells the build tool to link in .a's instead of .so's for user libraries whenever possible. System libraries such as libc (but not the C/C++ runtime libraries, see below) are still linked dynamically, as are libraries for which there is no static library. So the resulting executable will still be dynamically linked, hence only mostly static.<br><br>There are really three different ways to link an executable:<br><br>- STATIC with fully_static_link feature, in which everything is linked statically; e.g. "gcc -static foo.o libbar.a libbaz.a -lm".   This mode is enabled by specifying fully_static_link in the features attribute. - STATIC, in which all user libraries are linked statically (if a static version is available), but where system libraries (excluding C/C++ runtime libraries) are linked dynamically, e.g. "gcc foo.o libfoo.a libbaz.a -lm".   This mode is enabled by specifying linkstatic=True. - DYNAMIC, in which all libraries are linked dynamically (if a dynamic version is available), e.g. "gcc foo.o libfoo.so libbaz.so -lm".   This mode is enabled by specifying linkstatic=False.<br><br>If the linkstatic attribute or fully_static_link in features is used outside of //third_party please include a comment near the rule to explain why.<br><br>The linkstatic attribute has a different meaning if used on a cc_library() rule. For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.<br><br>There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area.<br><br>For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.<br><br>There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area.   | Boolean | optional |  `False`  |
| <a id="nim_cc_library-local_defines"></a>local_defines |  List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line for this target, but not to its dependents.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_library-main"></a>main |  The nim file containg executable logic.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="nim_cc_library-proj_cfg"></a>proj_cfg |  The project's configuration file.<br><br>Doesn't have to be named exactly as the 'main' file. rules_nim assures the name consistency during build phase.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="nim_cc_test"></a>

## nim_cc_test

<pre>
load("@rules_nim//nim:defs.bzl", "nim_cc_test")

nim_cc_test(<a href="#nim_cc_test-name">name</a>, <a href="#nim_cc_test-deps">deps</a>, <a href="#nim_cc_test-data">data</a>, <a href="#nim_cc_test-additional_compiler_inputs">additional_compiler_inputs</a>, <a href="#nim_cc_test-additional_linker_inputs">additional_linker_inputs</a>, <a href="#nim_cc_test-conlyopts">conlyopts</a>,
            <a href="#nim_cc_test-copts">copts</a>, <a href="#nim_cc_test-cxxopts">cxxopts</a>, <a href="#nim_cc_test-defines">defines</a>, <a href="#nim_cc_test-includes">includes</a>, <a href="#nim_cc_test-linkopts">linkopts</a>, <a href="#nim_cc_test-linkstatic">linkstatic</a>, <a href="#nim_cc_test-local_defines">local_defines</a>, <a href="#nim_cc_test-main">main</a>, <a href="#nim_cc_test-proj_cfg">proj_cfg</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nim_cc_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nim_cc_test-deps"></a>deps |  The list of nim or cc dependencies of the current target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_test-data"></a>data |  The list of files needed by this target at runtime. See general comments about data at 'Typical attributes' defined by most build rules.<br><br>If a data is the name of a generated file, then this target automatically depends on the generating target.<br><br>If a data is a rule name, then this target automatically depends on that rule, and that rule's outs are automatically added to this target's data files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_test-additional_compiler_inputs"></a>additional_compiler_inputs |  List of additional files needed for compilation of srcs   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_test-additional_linker_inputs"></a>additional_linker_inputs |  Pass these files to the C++ linker command.<br><br>For example, compiled Windows .res files can be provided here to be embedded in the binary target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_cc_test-conlyopts"></a>conlyopts |  Add these options to the C compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-copts"></a>copts |  Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization. Each string in this attribute is added in the given order to COPTS before compiling the binary target. The flags take effect only for compiling this target, not its dependencies, so be careful about header files included elsewhere. All paths should be relative to the workspace, not to the current package.<br><br>If the package declares the feature no_copts_tokenization, Bourne shell tokenization applies only to strings that consist of a single "Make" variable.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-cxxopts"></a>cxxopts |  Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-defines"></a>defines |  List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line to this target, as well as to every rule that depends on it. Be very careful, since this may have far-reaching effects. When in doubt, add define values to local_defines instead.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-includes"></a>includes |  List of include dirs to be added to the compile line. Subject to "Make variable" substitution. Each string is prepended with -isystem and added to COPTS. Unlike COPTS, these flags are added for this rule and every rule that depends on it. (Note: not the rules it depends upon!) Be very careful, since this may have far-reaching effects. When in doubt, add "-I" flags to COPTS instead.<br><br>Headers must be added to srcs or hdrs, otherwise they will not be available to dependent rules when compilation is sandboxed (the default).   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-linkopts"></a>linkopts |  Add these flags to the C++ linker command. Subject to "Make" variable substitution, Bourne shell tokenization and label expansion. Each string in this attribute is added to LINKOPTS before linking the binary target. Each element of this list that does not start with $ or - is assumed to be the label of a target in deps. The list of files generated by that target is appended to the linker options. An error is reported if the label is invalid, or is not declared in deps.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-linkstatic"></a>linkstatic |  "Link the artifact in static mode.<br><br>For nim_cc_binary and nim_cc_test: link the binary in static mode. For nim_cc_library.link_static: see below.<br><br>By default this option is on for cc_binary and off for the rest.<br><br>If enabled and this is a binary or test, this option tells the build tool to link in .a's instead of .so's for user libraries whenever possible. System libraries such as libc (but not the C/C++ runtime libraries, see below) are still linked dynamically, as are libraries for which there is no static library. So the resulting executable will still be dynamically linked, hence only mostly static.<br><br>There are really three different ways to link an executable:<br><br>- STATIC with fully_static_link feature, in which everything is linked statically; e.g. "gcc -static foo.o libbar.a libbaz.a -lm".   This mode is enabled by specifying fully_static_link in the features attribute. - STATIC, in which all user libraries are linked statically (if a static version is available), but where system libraries (excluding C/C++ runtime libraries) are linked dynamically, e.g. "gcc foo.o libfoo.a libbaz.a -lm".   This mode is enabled by specifying linkstatic=True. - DYNAMIC, in which all libraries are linked dynamically (if a dynamic version is available), e.g. "gcc foo.o libfoo.so libbaz.so -lm".   This mode is enabled by specifying linkstatic=False.<br><br>If the linkstatic attribute or fully_static_link in features is used outside of //third_party please include a comment near the rule to explain why.<br><br>The linkstatic attribute has a different meaning if used on a cc_library() rule. For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.<br><br>There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area.<br><br>For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.<br><br>There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area.   | Boolean | optional |  `True`  |
| <a id="nim_cc_test-local_defines"></a>local_defines |  List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line for this target, but not to its dependents.   | List of strings | optional |  `[]`  |
| <a id="nim_cc_test-main"></a>main |  The nim file containg executable logic.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="nim_cc_test-proj_cfg"></a>proj_cfg |  The project's configuration file.<br><br>Doesn't have to be named exactly as the 'main' file. rules_nim assures the name consistency during build phase.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="nim_module"></a>

## nim_module

<pre>
load("@rules_nim//nim:defs.bzl", "nim_module")

nim_module(<a href="#nim_module-name">name</a>, <a href="#nim_module-deps">deps</a>, <a href="#nim_module-srcs">srcs</a>, <a href="#nim_module-strip_import_prefix">strip_import_prefix</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nim_module-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nim_module-deps"></a>deps |  Other nim dependencies for this module.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nim_module-srcs"></a>srcs |  Nim sources that form a module.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="nim_module-strip_import_prefix"></a>strip_import_prefix |  The prefix to strip from the paths of the nim imports of this rule.   | String | optional |  `""`  |


<a id="nimble_lock_update"></a>

## nimble_lock_update

<pre>
load("@rules_nim//nim:defs.bzl", "nimble_lock_update")

nimble_lock_update(<a href="#nimble_lock_update-name">name</a>, <a href="#nimble_lock_update-nimble_repo">nimble_repo</a>, <a href="#nimble_lock_update-nimble_lock_file">nimble_lock_file</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nimble_lock_update-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="nimble_lock_update-nimble_repo"></a>nimble_repo |  <p align="center"> - </p>   |  none |
| <a id="nimble_lock_update-nimble_lock_file"></a>nimble_lock_file |  <p align="center"> - </p>   |  none |


