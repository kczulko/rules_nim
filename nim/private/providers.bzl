NimModule = provider(
    doc = "Information nim modules.",
    fields = {
        "dependencies": "Module direct dependencies",
        "srcs": "Module sources.",
        "strip_import_prefix": "Path prefix to remove when importing module files.",
        "include_path": "Execution context relative path to the module.",
    },
)

def create_nim_module_provider(deps, srcs, strip_import_prefix, include_path):
    return NimModule(
        dependencies = depset(
            deps,
            transitive = [
                dep[NimModule].dependencies
                for dep in deps
            ],
        ),
        srcs = srcs,
        strip_import_prefix = strip_import_prefix,
        include_path = include_path,
    )
