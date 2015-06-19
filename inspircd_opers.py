#!/usr/bin/env python

import base64
import getpass
import hmac
import hashlib
import os
import sys

def HMAC_shim():
    with open(os.path.join(sys.argv[1],sys.argv[2]),'w') as f:
        f.write(genHMAC(sys.argv[3]))

def genHMAC(prompt):
    password = getpass.getpass(prompt)
    salt = os.urandom(16)
    digest = hmac.new(salt, password, hashlib.sha256).digest()
    return base64.b64encode(salt).rstrip("=")+"$"+base64.b64encode(digest).rstrip("=")

def main():
    name= []
    password = []
    host = []
    opertype = []

    while(True):
        name.append(raw_input("What is the oper's username? "))
        password.append(genHMAC("What is the password for " + name[len(name)-1]))
        host.append(raw_input("What is the oper's host? (If unsure leave blank) "))
        opertype.append(raw_input("What is the oper's type? (If unsure use OVERLORD) "))

        if raw_input("Another oper? [Y/n] ") == 'n':
            with open(os.path.join(sys.argv[1],"inspircd_opers.yml"), 'w') as f:
                f.write("---\n")
                f.write("inspircd_opers:\n")
                for j in range(0, len(name)):
                    f.write("  - name: '%s'\n" % name[j])
                    f.write("    password: '%s'\n" % password[j])
                    f.write("    host: '%s'\n" % host[j])
                    f.write("    type: '%s'\n" % opertype[j])
            break

if __name__ == "__main__":
    main()
