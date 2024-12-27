"""This module implements the language-specific toolchain rule.
"""

NimInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "target_tool_path": "Path to the tool executable for the target platform.",
        "tool_files": """Files required in runfiles to make the tool executable available.

May be empty if the target_tool_path points to a locally installed tool binary.""",
        "nimbase": "Location of nimbase.h file.",
        "nimrtl": "Location of nimrtl.nim file.",
        "libsrcs": "lib|dist|compiler|config and other sources required during compiletime",
    },
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _nim_toolchain_impl(ctx):
    if ctx.attr.target_tool and ctx.attr.target_tool_path:
        fail("Can only set one of target_tool or target_tool_path but both were set.")
    if not ctx.attr.target_tool and not ctx.attr.target_tool_path:
        fail("Must set one of target_tool or target_tool_path.")

    tool_files = ctx.files.libsrcs
    target_tool_path = ctx.attr.target_tool_path

    if ctx.attr.target_tool:
        tool_files = ctx.attr.target_tool.files.to_list() + tool_files
        target_tool_path = _to_manifest_path(ctx, tool_files[0])

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "NIM_BIN": target_tool_path,
    })
    tool_files += ctx.files.nimbase
    tool_files += ctx.files.nimrtl

    default = DefaultInfo(
        files = depset(direct = tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    niminfo = NimInfo(
        target_tool_path = target_tool_path,
        tool_files = tool_files,
        nimbase = ctx.file.nimbase,
        nimrtl = ctx.file.nimrtl,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        niminfo = niminfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

nim_toolchain = rule(
    implementation = _nim_toolchain_impl,
    attrs = {
        "target_tool": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = False,
            allow_single_file = True,
        ),
        "target_tool_path": attr.string(
            doc = "Path to an existing executable for the target platform.",
            mandatory = False,
        ),
        "nimbase": attr.label(
            doc = "Path to an existing nimbase.h for the target platform.",
            mandatory = True,
            allow_single_file = True,
        ),
        "nimrtl": attr.label(
            doc = "Path to an existing nimrtl.nim file for the target platform",
            mandatory = True,
            allow_single_file = True,
        ),
        "libsrcs": attr.label_list(
            allow_files = True,
        ),
    },
    doc = """Defines a nim compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
