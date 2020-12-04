load("@rules_python//python:defs.bzl", "py_binary")
load("@kpotp_deps//:requirements.bzl", "requirement")

py_binary(
    name = "kpotp",
    srcs = ["kpotp.py"],
    visibility = ["//visibility:public"],
    deps = [
        requirement("pykeepass"),
        requirement("pyotp"),
    ],
)
