"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "2.2.0" : {
        "linux_x64": "sha384-fDcfk62ocoJH4jcfQ3YOmcxsMhTzy7wHtWrI/M5I3VbXLbvM6V618QSiOClSttq8"
        # "942e047879fd81193b2ff3c105436a0c5016800c4e97864f90039ae204f89ded"
    }
    # "1.14.2": {
    #     "x86_64-apple-darwin": "sha384-ws4+rANvv0YxM1SgIBUXSG9jT8dKw83nls6R5qYkEKzPUB+viBIEozSsyq2e6i+f",
    #     "aarch64-apple-darwin": "sha384-HcvJbxoJtGSavkGu0e7CyD00cBlmDb0TBWJ4JSaNa70zuU3N7XlMOYm3bbQcAv2U",
    #     "x86_64-pc-windows-msvc": "sha384-35YN6TKpT0L9qyRBmq48NucvyXEtHnkeC+txf2YZmmJTmOzrAKREA74BA0EZvpar",
    #     "x86_64-unknown-linux-gnu": "sha384-QgGOwTaetxY0h5HWCKc/3ZtBs4N/fgaaORthn7UcEv++Idm9W+ntCCZRwvBdwHPD",
    # },
}
