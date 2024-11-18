load("@rules_nim//nim/private:providers.bzl", "NimModule")

_NIM_MODULE_ATTRS = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,
        doc = """Nim sources that creates a module.""",
    ),
    "deps": attr.label_list(
        providers = [ NimModule ],
        doc = """Other nim dependencies for this module.""",
    ),
    "strip_import_prefix": attr.string(
        doc = """The prefix to strip from the paths of the nim imports of this rule.""",
    )
    # "public_hdrs": attr.label_list(
    #     allow_files = [
    #         ".h",
    #         ".hh",
    #         ".hpp",
    #         ".hxx",
    #         ".inc",
    #         ".inl",
    #         ".H",
    #     ],
    #     doc = """
    #     List of headers that may be included by dependent rules transitively.
    #     Notice: the cutoff happens during compilation.
    #     """,
    #     default = [],
    # ),
    # "private_hdrs": attr.label_list(
    #     allow_files = [
    #         ".h",
    #         ".hh",
    #         ".hpp",
    #         ".hxx",
    #         ".inc",
    #         ".inl",
    #         ".H",
    #     ],
    #     doc = """
    #     List of headers that CANNOT be included by dependent rules.
    #     Notice: the cutoff happens during compilation.
    #     """,
    #     default = [],
    # ),
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
            ".cfg"
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
        """
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
        """
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
        doc = "Link the binary in static mode.",
    ),
    "local_defines": attr.string_list(
        default = [],
        doc = """
        List of defines to add to the compile line. Subject to "Make" variable substitution and Bourne shell tokenization. Each string, which must consist of a single Bourne shell token, is prepended with -D and added to the compile command line for this target, but not to its dependents.
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
    )
}

def nim_module_attrs():
    return _NIM_MODULE_ATTRS
def nim_cc_rule_attrs():
    return _NIM_CC_RULE_ATTRS
