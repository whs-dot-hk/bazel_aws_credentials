import argparse

from pykeepass import PyKeePass
import pyotp

parser = argparse.ArgumentParser()

parser.add_argument("--entry", required = True)
parser.add_argument("--kdbx", required = True)
parser.add_argument("--password-file", required = True)

def main():
    args = parser.parse_args()

    f = open(args.password_file)
    pw = f.read().strip()

    kp = PyKeePass(args.kdbx, password = pw)

    entry = kp.find_entries(title = args.entry, first = True)

    uri = entry.get_custom_property("otp")

    totp = pyotp.parse_uri(uri)

    print(totp.now())

if __name__ == "__main__":
    main()
