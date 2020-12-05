# Getting started

## Create `credentials`
```text
credentials
---
[my-prod]
aws_access_key_id = ...
aws_secret_access_key = ...
```

## Update `BUILD`
Replace `[aws-account-id]`, `[aws-iam-username]` and `[aws-iam-role-name]`
```starlark
BUILD
---
...

load("profile.bzl", "assume_role", "credentials", "get_session_token", "profile")
load("otp.bzl", "gopass_otp")

gopass_otp(
    name = "my-prod-otp",
    entry = "Account/aws.amazon.com/my-prod",
)

profile(
    name = "my-prod",
    credentials = ":credentials",
)

get_session_token(
    name = "my-prod-sts",
    profile = ":my-prod",
    serial_number = "arn:aws:iam::[aws-account-id]:mfa/[aws-iam-username]",
    otp = ":my-prod-otp",
)

assume_role(
    name = "my-prod-role",
    profile = ":my-prod-sts",
    role_arn = "arn:aws:iam::[aws-account-id]:role/[aws-iam-role-name]",
)

credentials(
    name = "output_credentials",
    profiles = [
        ":my-prod-sts",
        ":my-prod-role",
    ],
)
```

## Build `:output_credentials`
```sh
# Clean up expired credentials
rm -rf bazel-out/k8-fastbuild/bin
# Unlock gopass
gopass my-prod
bazel build //:output_credentials
```

# Quick guide

[Create `Passwords.kdbx`](keepassxc.md)

```sh
git clone https://github.com/whs-dot-hk/bazel_aws_credentials.git
cd bazel_aws_credentials
tee -a credentials > /dev/null <<EOF
[my-prod]
aws_access_key_id = ...
aws_secret_access_key = ...
EOF
echo "newpassword" > password.txt
tee -a BUILD > /dev/null <<EOF
load("profile.bzl", "credentials", "get_session_token", "profile")
load("otp.bzl", "kpotp_otp")

kpotp_otp(
    name = "my-prod-otp",
    kdbx = ":Passwords.kdbx",
    password_file = ":password.txt",
    entry = "my-prod",
)

profile(
    name = "my-prod",
    credentials = ":credentials",
)

get_session_token(
    name = "my-prod-sts",
    profile = ":my-prod",
    serial_number = "arn:aws:iam::[aws-account-id]:mfa/[aws-iam-username]",
    otp = ":my-prod-otp",
)

credentials(
    name = "output_credentials",
    profiles = [
        ":my-prod-sts",
    ],
)
EOF
bazel build //:output_credentials
```

# Docker
```sh
docker pull amazon/aws-cli:2.0.54
```

```sh
docker_run_flags=-v$(pwd)/bazel-bin/output_credentials:/my_aws_credentials\ -eAWS_SHARED_CREDENTIALS_FILE=/my_aws_credentials
```

## Get caller identity
```sh
docker run -it --entrypoint= $docker_run_flags amazon/aws-cli:2.0.54 aws sts get-caller-identity --profile=my-prod-sts
```

## List s3
```sh
docker run -it --entrypoint= $docker_run_flags amazon/aws-cli:2.0.54 aws s3 ls --profile=aqt-prod-sts --region=ap-east-1
```

```sh
unset docker_run_flags
```

# Kpcli
```starlark
load("otp.bzl", "kpcli_otp")

kpcli_otp(
    name = "test-otp",
    kdb = ":test.kdbx",
    # pwfile contains the master password of test.kdbx
    pwfile = ":password",
    entry = "Internet/test",
)
```
