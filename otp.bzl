def _gopass_otp_impl(ctx):
    command = """
otp() {
token=$(gopass otp -o %s)
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
    runfiles_path = "$0.runfiles/"

    kdb_file_root = runfiles_path + ctx.workspace_name + "/"

    kdb_file_path = kdb_file_root + ctx.file.kdb.path
    pwfile_file_path = kdb_file_root + ctx.file.pwfile.path

    command = """
otp() {
token=$(kpcli --kdb=%s --pwfile=%s --command=otp\\ %s)
"$@" --token $token
}

for i in 1 2 3; do otp "$@" && break || sleep 5; done""" % (kdb_file_path, pwfile_file_path, ctx.attr.entry)

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
        "kdb": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "pwfile": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "entry": attr.string(
            mandatory = True,
        ),
    },
)
