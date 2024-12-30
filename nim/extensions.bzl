"""Extensions for bzlmod.

Installs a nim toolchain.
Every module can define a toolchain version under the default name, "nim".
The latest of those versions will be selected (the rest discarded),
and will always be registered by rules_nim.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load("@bazel_skylib//lib:modules.bzl", "modules")
load(":repositories.bzl", "nim_register_toolchains")
load(":nimble.bzl", "nimble_lock", "nimble_install")

_DEFAULT_NAME = "nim"

nim_toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one nim toolchain to be registered.
Overriding the default is only permitted in the root module.
""", default = _DEFAULT_NAME),
    "nim_version": attr.string(doc = "Explicit version of nim.", mandatory = True),
})

nimble_lock_tag_def = tag_class(
    attrs = {
        "name": attr.string(
            doc = """
            """,
            mandatory = True,
        ),
        "lock_file": attr.label(
            doc = """""",
            mandatory = True,
        ),
    }
)

nimble_install_tag_def = tag_class(
    attrs = {
        "name": attr.string(
            doc = """
            """,
            mandatory = True,
        ),
        "nimble_file": attr.label(
            doc = """""",
            mandatory = True,
        ),
        "nimble_attrs": attr.string_list(
            doc = """""",
            default = ["--noLockFile"]
        ),
        "quiet": attr.bool(
            doc = """""",
            default = False
        ),
        "pkgs_dir_prefix": attr.string(
            doc = """""",
            default = "pkgs2"
        )
    }
)

def _toolchain_extension(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != _DEFAULT_NAME and not mod.is_root:
                fail("""\
                Only the root module may override the default name for the nim toolchain.
                This prevents conflicting registrations in the global namespace of external repos.
                """)
            if toolchain.name not in registrations.keys():
                registrations[toolchain.name] = []
            registrations[toolchain.name].append(toolchain.nim_version)
    for name, versions in registrations.items():
        if len(versions) > 1:
            # TODO: should be semver-aware, using MVS
            selected = sorted(versions, reverse = True)[0]

            # buildifier: disable=print
            print("NOTE: nim toolchain {} has multiple versions {}, selected {}".format(name, versions, selected))
        else:
            selected = versions[0]

        nim_register_toolchains(
            name = name,
            nim_version = selected,
            register = False,
        )

def _nimble_extension(module_ctx):
    for mod in module_ctx.modules:
        for nimble_lock_def in mod.tags.lock:
            nimble_lock(
                name = nimble_lock_def.name,
                lock_file = nimble_lock_def.lock_file,
            )
        for nimble_install_def in mod.tags.install:
            nimble_install(
                name = nimble_install_def.name,
                nimble_file = nimble_install_def.nimble_file,
                nimble_attrs = nimble_install_def.nimble_attrs,
                quiet = nimble_install_def.quiet,
                pkgs_dir_prefix = nimble_install_def.pkgs_dir_prefix,
            )
    return modules.use_all_repos(module_ctx)

nim = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {
        "toolchain": nim_toolchain,
    },
)

nimble = module_extension(
    implementation = _nimble_extension,
    tag_classes = {
        "lock": nimble_lock_tag_def,
        "install": nimble_install_tag_def,
    }
)
