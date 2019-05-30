{
    name = "",
    port = [] : List ../types/port.dhall,
    replicas = 0,
    imagePullSecrets = [] : List ../types/secret.dhall,
    image = "",
    branch = "",
    version = "",
    build = "",
    maxSurge = 1,
    maxUnavailable = 0,
    environmentVariables = [] : List { mapKey : Text, mapValue : Text },
    host = [] : List ../../dhall-k8s/api/Deployment/Host,
    mount = [] : List ../types/mount.dhall,
    nodeSelectors = [] : List { mapKey : Text, mapValue :Text },
    command = None (List Text),
    initCommands = [] : (List { mapKey : Text, mapValue : (List Text) }),
    healthcheck = None ../types/healthcheck.dhall
}
