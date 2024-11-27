"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "2.2.0": {
        "download_url_template": "https://github.com/nim-lang/nightlies/releases/download/2024-10-02-version-2-2-78983f1876726a49c69d65629ab433ea1310ece1/nim-{version}-{platform}.tar.xz",
        "linux_x64": "sha384-fDcfk62ocoJH4jcfQ3YOmcxsMhTzy7wHtWrI/M5I3VbXLbvM6V618QSiOClSttq8",
        "macosx_x64": "sha384-dDcfk62ocoJH4jcfQ3YOmcxsMhTzy7wHtWrI/M5I3VbXLbvM6V618QSiOClSttq8",
        "linux_arm64": "sha384-eDcfk62ocoJH4jcfQ3YOmcxsMhTzy7wHtWrI/M5I3VbXLbvM6V618QSiOClSttq8",
    },
    "2.0.12": {
        "download_url_template": "https://github.com/nim-lang/nightlies/releases/download/2024-11-01-version-2-0-ce7c6f4f3365db2cc63bdd9d460c71ed937ee9e9/nim-{version}-{platform}.tar.xz",
        "linux_x64": "sha384-n8qh3KI2K74Ann7SMBdhIKZ2V33iWuTI57yG/sKod6j/GAvJ5SlvkQg8u+tWuUko",
        "macosx_x64": "sha384-bDcfk62ocoJH4jcfQ3YOmcxsMhTzy7wHtWrI/M5I3VbXLbvM6V618QSiOClSttq8",
        "linux_arm64": "sha384-cDcfk62ocoJH4jcfQ3YOmcxsMhTzy7wHtWrI/M5I3VbXLbvM6V618QSiOClSttq8",
    }
}
