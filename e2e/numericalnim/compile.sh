#!/usr/bin/env bash

nim c -d:release \
    --nimcache:./nim-rtl \
    --usenimcache \
    /nix/store/b8nbxmznr5h4g892jfz5aj5pxcyx9css-nim-unwrapped-2.0.4/nim/lib/nimrtl.nim

# nim compileToC \
#     --compileOnly \
#     --out:./test_vector \
#     --nimcache:./rules_nim_test_vector_compilation_cache \
#     --usenimcache \
#     --path: ./nimble/pkgs2/nimblas-0.3.1-e1ecdea4bb8176f12d66efd4aa0c7b3bea970027 \
#     --path: ./nimble/pkgs2/nimlapack-0.3.1-fcb25795c6fb43f9251b7f34c3ad84c39e645afd \
#     --path: ./nimble/pkgs2/zip-0.3.1-747aab3c43ecb7b50671cdd0ec3b2edc2c83494c \
#     --path: ./nimble/pkgs2/untar-0.1.0-ceb12634783156ddd511410242dc7855ae2f4a14 \
#     --path: ./nimble/pkgs2/stb_image-2.5-abf5fd03e72ee4c316c50a0538b973e355dcb175 \
#     --path: ./nimble/pkgs2/cdt-0.1.1-195f0270aaf5d363925f7fdf8a4cc125e4832417 \
#     --path: ./nimble/pkgs2/arraymancer-0.7.33-c37fb5d98fce8661ade439d89d0a6a3c9d65c8fc \
#     tests/test_vector.nim
