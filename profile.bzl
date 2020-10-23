ProfileInfo = provider(fields = ["name"])

def _profile_impl(ctx):
    credentials = ctx.file.credentials

    profile_name = ctx.attr.profile_name or ctx.attr.name

    return [
        DefaultInfo(
            files = depset([credentials]),
        ),
        ProfileInfo(
            name = profile_name,
        ),
    ]

profile = rule(
    implementation = _profile_impl,
    attrs = {
        "credentials": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "profile_name": attr.string(),
    },
)

def _get_session_token_impl(ctx):
    args = ctx.actions.args()

    args.add("--input-credentials-path", ctx.file.profile.path)
    args.add("--input-profile-name", ctx.attr.profile[ProfileInfo].name)

    output_credentials = ctx.actions.declare_file(ctx.attr.name)
    args.add("--output-credentials-path", output_credentials.path)

    output_profile_name = ctx.attr.output_profile_name or ctx.attr.name
    args.add("--output-profile-name", output_profile_name)

    args.add("--serial-number", ctx.attr.serial_number)

    ctx.actions.run(
        inputs = [ctx.file.profile],
        outputs = [output_credentials],
        arguments = [ctx.executable._profile.path, "get-session-token", args],
        executable = ctx.executable.otp,
        tools = [ctx.executable._profile],
        use_default_shell_env = True,
    )

    return [
        DefaultInfo(
            files = depset([output_credentials]),
        ),
        ProfileInfo(
            name = output_profile_name,
        ),
    ]

get_session_token = rule(
    implementation = _get_session_token_impl,
    attrs = {
        "_profile": attr.label(
            executable = True,
            cfg = "host",
            default = "//profile",
        ),
        "output_profile_name": attr.string(),
        "profile": attr.label(
            providers = [ProfileInfo],
            allow_single_file = True,
            mandatory = True,
        ),
        "serial_number": attr.string(
            mandatory = True,
        ),
        "otp": attr.label(
            allow_files = True,
            executable = True,
            cfg = "host",
            mandatory = True,
        ),
    },
)

def _assume_role_impl(ctx):
    args = ctx.actions.args()

    args.add("--input-credentials-path", ctx.file.profile.path)
    args.add("--input-profile-name", ctx.attr.profile[ProfileInfo].name)

    output_credentials = ctx.actions.declare_file(ctx.attr.name)
    args.add("--output-credentials-path", output_credentials.path)

    output_profile_name = ctx.attr.output_profile_name or ctx.attr.name
    args.add("--output-profile-name", output_profile_name)

    args.add("--role-arn", ctx.attr.role_arn)

    is_mfa = ctx.attr.serial_number != "" and ctx.attr.otp != None

    if is_mfa:
        args.add("--serial-number", ctx.attr.serial_number)

        ctx.actions.run(
            inputs = [ctx.file.profile],
            outputs = [output_credentials],
            arguments = [ctx.executable._profile.path, "assume-role", args],
            executable = ctx.executable.otp,
            tools = [ctx.executable._profile],
            use_default_shell_env = True,
        )
    else:
        ctx.actions.run(
            inputs = [ctx.file.profile],
            outputs = [output_credentials],
            arguments = ["assume-role", args],
            executable = ctx.executable._profile,
        )

    return [
        DefaultInfo(
            files = depset([output_credentials]),
        ),
        ProfileInfo(
            name = output_profile_name,
        ),
    ]

assume_role = rule(
    implementation = _assume_role_impl,
    attrs = {
        "_profile": attr.label(
            executable = True,
            cfg = "host",
            default = "//profile",
        ),
        "output_profile_name": attr.string(),
        "profile": attr.label(
            providers = [ProfileInfo],
            allow_single_file = True,
            mandatory = True,
        ),
        "role_arn": attr.string(
            mandatory = True,
        ),
        "serial_number": attr.string(),
        "otp": attr.label(
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
    },
)

def _credentials_impl(ctx):
    profiles = [f for f in ctx.files.profiles]

    output_credentials_name = ctx.attr.output_credentials_name or ctx.attr.name

    output_credentials = ctx.actions.declare_file(output_credentials_name)

    profile_paths = " ".join([f.path for f in ctx.files.profiles])

    ctx.actions.run_shell(
        inputs = profiles,
        outputs = [output_credentials],
        command = "cat %s > %s" % (profile_paths, output_credentials.path),
    )

    return [
        DefaultInfo(
            files = depset([output_credentials]),
        ),
    ]

credentials = rule(
    implementation = _credentials_impl,
    attrs = {
        "profiles": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "output_credentials_name": attr.string(),
    },
)
