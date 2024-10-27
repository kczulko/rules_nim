load("@bazel_binaries//:defs.bzl", "bazel_binaries")
load(
    "@rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_test",
    "integration_test_utils",
)

def bazel_integration_spec(workspace_path, test_runner):
    bazel_integration_test(
        name = "{}_spec".format(workspace_path),
        bazel_version = bazel_binaries.versions.current,
        test_runner = test_runner,
        workspace_path = workspace_path,
        workspace_files = integration_test_utils.glob_workspace_files(workspace_path) + [
            "//:local_repository_files",
        ],
        tags = integration_test_utils.DEFAULT_INTEGRATION_TEST_TAGS + [
            "no-sandbox",
        ],
    )
