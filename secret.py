#!/usr/bin/python

import subprocess, json, sys

if __name__ == "__main__":
    secrets = json.loads(subprocess.check_output("./bin/dhall-to-json <<< ./secret.dhall", shell=True))
    for secret in secrets:
        if sys.argv[1] == 'create':
            print "Creating secret %s for %s" % (secret['username'], secret['domain'])
            subprocess.call(
                    "kubectl create secret docker-registry %s --docker-server=%s --docker-username=%s --docker-password=%s" % (secret['username'], secret['domain'], secret['username'], secret['password']), 
                    shell=True)
        elif sys.argv[1] == 'delete':
            print "Deleting secret %s for %s" % (secret['username'], secret['domain'])
            subprocess.call(
                    "kubectl delete secret %s" % (secret['username']),
                    shell=True)
