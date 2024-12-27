load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")

def nimble_lock_update(
        name,
        nimble_repo,
        nimble_lock_file):
    write_source_files(
        name = name,
        files = {
            nimble_lock_file: "{}//:nimble.bazel.lock".format(nimble_repo),
        },
        diff_test = False,
    )
