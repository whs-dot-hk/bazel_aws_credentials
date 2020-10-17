## Get started

### Create `credentials`
```text
credentials
---
[my-prod]
aws_access_key_id = ...
aws_secret_access_key = ...
```

### Update `BUILD`
Replace `[aws-account-id]`, `[aws-iam-username]` and `[aws-iam-role-name]`
```starlark
BUILD
---
...

load("profile.bzl", "assume_role", "credentials", "get_session_token", "profile")
load("otp.bzl", "gopass_otp")

gopass_otp(
    name = "my-prod-token",
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
    token = ":my-prod-token",
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

### Build `:output_credentials`
```sh
# Clean up expired credentials
rm -rf bazel-bin
# Unlock gopass
gopass my-prod
bazel build //:output_credentials
```

### Using docker
```sh
docker_run_flags=-v$(pwd)/bazel-bin/output_credentials:/my_aws_credentials\ -eAWS_SHARED_CREDENTIALS_FILE=/my_aws_credentials
```

```sh
docker pull amazon/aws-cli:2.0.54
```

#### Get caller identity
```sh
docker run -it --entrypoint= $docker_run_flags amazon/aws-cli:2.0.54 aws sts get-caller-identity --profile=my-prod-sts
```

#### List s3
```sh
docker run -it --entrypoint= $docker_run_flags amazon/aws-cli:2.0.54 aws s3 ls --profile=aqt-prod-sts --region=ap-east-1
```

```sh
unset docker_run_flags
```
