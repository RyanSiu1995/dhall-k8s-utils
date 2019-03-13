#!/usr/bin/python

import json, os
from subprocess import check_output

if __name__ == "__main__":
    config = json.loads(check_output("./bin/dhall-to-json --omitNull <<< ./config.dhall", shell=True))
    with open('utils/template/service.template.dhall', 'r') as f:
        service_template = f.read()
    with open('utils/template/deployment.template.dhall', 'r') as f:
        deployment_template = f.read()
    for key, value in config.iteritems():
        print "Generating service file for: %s" % key
        service_dhall = service_template.replace("{{{service}}}", key)
        with open('build/%s-service.yaml' % key, 'w+') as f:
            f.write(check_output('./bin/dhall-to-yaml --omitNull <<< \'%s\'' % service_dhall, shell=True))
        print "Generating deployment file for: %s" % key
        deployment_dhall = deployment_template.replace("{{{service}}}", key)
        with open('build/%s-deployment.yaml' % key, 'w+') as f:
            f.write(check_output('./bin/dhall-to-yaml --omitNull <<< \'%s\'' % deployment_dhall, shell=True))
