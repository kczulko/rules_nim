load("@bazel_skylib//lib:paths.bzl", "paths")
load("@aspect_bazel_lib//lib:paths.bzl", "to_repository_relative_path")
load("@rules_nim//nim/private:providers.bzl", "NimModule", "create_nim_module_provider")
load("@rules_nim//nim/private:attrs.bzl", "nim_module_attrs")

def _nim_module_impl(ctx):
    module_dir_name = "nim_module_{}".format(ctx.attr.name)
    include_path = paths.join(
        ctx.genfiles_dir.path,
        ctx.label.workspace_root,
        ctx.label.package,
        module_dir_name,
        ctx.attr.strip_import_prefix,
    )

    files = []
    for src in ctx.files.srcs:
        symlink_path = paths.join(
            module_dir_name,
            to_repository_relative_path(src),
        )
        symlink = ctx.actions.declare_file(symlink_path)
        ctx.actions.symlink(output = symlink, target_file = src)
        files.append(symlink)

    return [
        create_nim_module_provider(
            ctx.attr.deps,
            files,
            ctx.attr.strip_import_prefix,
            include_path,
        ),
        DefaultInfo(files = depset(files))
    ]

nim_module = rule(
    implementation = _nim_module_impl,
    attrs = nim_module_attrs(),
    provides = [ NimModule ],
)
