load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "profile_lib",
    srcs = ["profile.go"],
    importpath = "github.com/whs-dot-hk/bazel_aws_credentials/profile",
    visibility = ["//visibility:private"],
    deps = [
        "@com_github_aws_aws_sdk_go//aws",
        "@com_github_aws_aws_sdk_go//aws/credentials",
        "@com_github_aws_aws_sdk_go//aws/session",
        "@com_github_aws_aws_sdk_go//service/sts",
        "@com_github_spf13_cobra//:cobra",
    ],
)

go_binary(
    name = "profile",
    embed = [":profile_lib"],
    visibility = ["//visibility:public"],
)
