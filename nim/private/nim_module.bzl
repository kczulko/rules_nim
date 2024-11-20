load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_nim//nim/private:providers.bzl", "NimModule", "create_nim_module_provider")
load("@rules_nim//nim/private:attrs.bzl", "nim_module_attrs")

def _nim_module_impl(ctx):
    path = paths.join(
        ctx.label.workspace_root,
        ctx.label.package,
        ctx.attr.strip_import_prefix,
    )

    return [
        create_nim_module_provider(
            ctx.attr.deps,
            ctx.files.srcs,
            ctx.attr.strip_import_prefix,
            path,
        ),
        DefaultInfo(files = depset(ctx.files.srcs))
    ]

nim_module = rule(
    implementation = _nim_module_impl,
    attrs = nim_module_attrs(),
    provides = [ NimModule ],
)
