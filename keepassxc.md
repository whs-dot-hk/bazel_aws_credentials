![Welcome screen](keepassxc-1-welcome-screen.png)

Create new database

![New database](keepassxc-2-new-database.png)

```
# New database
ctrl-shift-n
# Continue
enter
enter
# New password
newpassword
tab
newpassword
enter
# Save
enter
```

Create new entry

![New entry](keepassxc-3-new-entry.png)

```
# New entry
ctrl-n
# Title
my-prod
```

![Otp](keepassxc-4-otp.png)

```
# Advanced
shift-tab
shift-tab
down
# Add
tab
tab
tab
enter
# New attribute
otp
enter
tab
otpauth://totp/my-prod:none?secret=[mysecret]&period=30&digits=6&issuer=my-prod
# OK
ctrl-enter
```
