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

def _kpcli_otp_impl(ctx):
    command = """
otp() {
token=$(kpcli --kdb=%s --pwfile=%s --command=otp\ %s)
"$@" --token $token
}

for i in 1 2 3; do otp "$@" && break || sleep 5; done""" % (ctx.attr.kdb, ctx.attr.pwfile, ctx.attr.entry)

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

kpcli_otp = rule(
    implementation = _kpcli_otp_impl,
    executable = True,
    attrs = {
        "kdb": attr.string(
            mandatory = True,
        ),
        "pwfile": attr.string(
            mandatory = True,
        ),
        "entry": attr.string(
            mandatory = True,
        ),
    },
)
