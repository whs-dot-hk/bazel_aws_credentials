load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")
load("@bazel_gazelle//:def.bzl", "gazelle")

# gazelle:prefix github.com/whs-dot-hk/bazel_aws_credentials
gazelle(name = "gazelle")

go_library(
    name = "bazel_aws_credentials_lib",
    srcs = ["profile.go"],
    importpath = "github.com/whs-dot-hk/bazel_aws_credentials",
    visibility = ["//visibility:private"],
    deps = [
        "@com_github_aws_aws_sdk_go//aws:go_default_library",
        "@com_github_aws_aws_sdk_go//aws/credentials:go_default_library",
        "@com_github_aws_aws_sdk_go//aws/session:go_default_library",
        "@com_github_aws_aws_sdk_go//service/sts:go_default_library",
        "@com_github_spf13_cobra//:go_default_library",
    ],
)

go_binary(
    name = "bazel_aws_credentials",
    embed = [":bazel_aws_credentials_lib"],
    visibility = ["//visibility:public"],
)
