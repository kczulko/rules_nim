load("@rules_nim//nim/private:providers.bzl", "NimModule")

def _mk_linkstatic(default):
    return {
        "linkstatic": attr.bool(
            default = default,
            doc = """"Link the artifact in static mode.

            For nim_cc_binary and nim_cc_test: link the binary in static mode. For nim_cc_library.link_static: see below.

            By default this option is on for cc_binary and off for the rest.

            If enabled and this is a binary or test, this option tells the build tool to link in .a's instead of .so's for user libraries whenever possible. System libraries such as libc (but not the C/C++ runtime libraries, see below) are still linked dynamically, as are libraries for which there is no static library. So the resulting executable will still be dynamically linked, hence only mostly static.

            There are really three different ways to link an executable:

            - STATIC with fully_static_link feature, in which everything is linked statically; e.g. "gcc -static foo.o libbar.a libbaz.a -lm".
              This mode is enabled by specifying fully_static_link in the features attribute.
            - STATIC, in which all user libraries are linked statically (if a static version is available), but where system libraries (excluding C/C++ runtime libraries) are linked dynamically, e.g. "gcc foo.o libfoo.a libbaz.a -lm".
              This mode is enabled by specifying linkstatic=True.
            - DYNAMIC, in which all libraries are linked dynamically (if a dynamic version is available), e.g. "gcc foo.o libfoo.so libbaz.so -lm".
              This mode is enabled by specifying linkstatic=False.

            If the linkstatic attribute or fully_static_link in features is used outside of //third_party please include a comment near the rule to explain why.

            The linkstatic attribute has a different meaning if used on a cc_library() rule. For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.

            There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area. 

            For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.

            There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area. 
        """,
        ),
    }

_NIM_EXECUTABLE_LINKSTATIC = _mk_linkstatic(True)
_NIM_LIBRARY_LINKSTATIC = _mk_linkstatic(False)

_NIM_MODULE_ATTRS = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,
        doc = """Nim sources that form a module.""",
    ),
    "deps": attr.label_list(
        providers = [NimModule],
        doc = """Other nim dependencies for this module.""",
    ),
    "strip_import_prefix": attr.string(
        doc = """The prefix to strip from the paths of the nim imports of this rule.""",
    ),
}

_NIM_CC_RULE_ATTRS = {
    "main": attr.label(
        mandatory = True,
        allow_single_file = [
            ".nim",
        ],
        doc = "The nim file containg executable logic.",
    ),
    "proj_cfg": attr.label(
        allow_single_file = [
            ".cfg",
        ],
        doc = """
        The project's configuration file.

        Doesn't have to be named exactly as the 'main' file. rules_nim assures the name consistency during build phase.        
        """,
    ),
    "deps": attr.label_list(
        default = [],
        doc = "The list of nim or cc dependencies of the current target.",
        providers = [[NimModule], [CcInfo]],
    ),
    "data": attr.label_list(
        doc = """
        The list of files needed by this target at runtime. See general comments about data at 'Typical attributes' defined by most build rules.

If a data is the name of a generated file, then this target automatically depends on the generating target.

If a data is a rule name, then this target automatically depends on that rule, and that rule's outs are automatically added to this target's data files.
        """,
    ),
    "additional_compiler_inputs": attr.label_list(
        default = [],
        doc = """
        List of additional files needed for compilation of srcs
        """,
    ),
    "additional_linker_inputs": attr.label_list(
        default = [],
        doc = """
        Pass these files to the C++ linker command.

        For example, compiled Windows .res files can be provided here to be embedded in the binary target.
        """,
    ),
    "conlyopts": attr.string_list(
        default = [],
        doc = """
        Add these options to the C compilation command. Subject to "Make variable" substitution and Bourne shell tokenization. 
        """,
    ),
    "copts": attr.string_list(
        default = [],
        doc = """
        Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.
        Each string in this attribute is added in the given order to COPTS before compiling the binary target. The flags take effect only for compiling this target, not its dependencies, so be careful about header files included elsewhere. All paths should be relative to the workspace, not to the current package.

        If the package declares the feature no_copts_tokenization, Bourne shell tokenization applies only to strings that consist of a single "Make" variable.
        """,
    ),
    "cxxopts": attr.string_list(
        default = [],
        doc = """
        Add these options to the C++ compilation command. Subject to "Make variable" substitution and Bourne shell tokenization.
        """,
    ),
    "defines": attr.string_list(
        default = [],
        doc = """
        List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line to this target, as well as to every rule that depends on it. Be very careful, since this may have far-reaching effects. When in doubt, add define values to local_defines instead.
        """,
    ),
    "includes": attr.string_list(
        default = [],
        doc = """
        List of include dirs to be added to the compile line.
        Subject to "Make variable" substitution. Each string is prepended with -isystem and added to COPTS. Unlike COPTS, these flags are added for this rule and every rule that depends on it. (Note: not the rules it depends upon!) Be very careful, since this may have far-reaching effects. When in doubt, add "-I" flags to COPTS instead.

        Headers must be added to srcs or hdrs, otherwise they will not be available to dependent rules when compilation is sandboxed (the default).
        """,
    ),
    "linkopts": attr.string_list(
        default = [],
        doc = """
        Add these flags to the C++ linker command. Subject to "Make" variable substitution, Bourne shell tokenization and label expansion. Each string in this attribute is added to LINKOPTS before linking the binary target.
        Each element of this list that does not start with $ or - is assumed to be the label of a target in deps. The list of files generated by that target is appended to the linker options. An error is reported if the label is invalid, or is not declared in deps.
        """,
    ),
    "linkstatic": attr.bool(
        default = True,
        doc = """"Link the artifact in static mode.

        For a C++ library, linkstatic=True indicates that only static linking is allowed, so no .so will be produced. linkstatic=False does not prevent static libraries from being created. The attribute is meant to control the creation of dynamic libraries.

        There should be very little code built with linkstatic=False in production. If linkstatic=False, then the build tool will create symlinks to depended-upon shared libraries in the *.runfiles area. 
        """,
    ),
    "local_defines": attr.string_list(
        default = [],
        doc = """
        List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line for this target, but not to its dependents.
        """,
    ),
}

_NIM_CC_LIBRARY_ATTRS = {
    "alwayslink": attr.bool(
        default = False,
        doc = """
        If 1, any binary that depends (directly or indirectly) on this C++ library will link in all the object files for the files listed in srcs, even if some contain no symbols referenced by the binary. This is useful if your code isn't explicitly called by code in the binary, e.g., if your code registers to receive some callback provided by some service. 
        """,
    ),
}

_CC_LIB_ATTRS = {
    "include_prefix": attr.string(
        default = "",
        doc = """
        The prefix to add to the paths of the headers of this rule.
        When set, the headers in the hdrs attribute of this rule are accessible at is the value of this attribute prepended to their repository-relative path.

        The prefix in the strip_include_prefix attribute is removed before this prefix is added.
        """,
    ),
    "strip_include_prefix": attr.string(
        default = "",
        doc = """
        The prefix to strip from the paths of the headers of this rule.
        When set, the headers in the hdrs attribute of this rule are accessible at their path with this prefix cut off * stamp = -1: Embedding of build information is controlled by the --[no]stamp flag.

        Stamped binaries are not rebuilt unless their dependencies change.
        """,
    ),
}

def nim_module_attrs():
    return _NIM_MODULE_ATTRS

def nim_cc_rule_attrs():
    return _NIM_CC_RULE_ATTRS | _NIM_EXECUTABLE_LINKSTATIC

def nim_cc_library_rule_attrs():
    return _NIM_CC_RULE_ATTRS | _NIM_CC_LIBRARY_ATTRS | _NIM_LIBRARY_LINKSTATIC
