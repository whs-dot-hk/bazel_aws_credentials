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
Replace `[aws-account-id]` and `[aws-iam-username]`
```starlark
BUILD
---
...

load("profile.bzl", "credentials", "get_session_token", "profile")
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

credentials(
    name = "output_credentials",
    profiles = [
        ":my-prod-sts",
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
