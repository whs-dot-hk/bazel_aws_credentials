def _gopass_otp_impl(ctx):
    command = """
otp() {
token=$(gopass otp %s -o)
"$@" --token $token
}

for i in 1 2 3; do otp "$@" && break || sleep 5; done""" % ctx.attr.entry

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = command,
        is_executable = True,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(),
        ),
    ]

gopass_otp = rule(
    implementation = _gopass_otp_impl,
    executable = True,
    attrs = {
        "entry": attr.string(
            mandatory = True,
        ),
    },
)
