{
    name = "",
    port = [] : List ../types/port.dhall,
    replicas = 0,
    imagePullSecrets = [] : List ../types/secret.dhall,
    image = "",
    branch = "",
    version = "",
    build = "",
    environmentVariables = [] : List { mapKey : Text, mapValue : Text },
    host = [] : List ../../dhall-k8s/api/Deployment/Host,
    mount = [] : List ../types/mount.dhall,
    nodeSelectors = [] : List { mapKey : Text, mapValue :Text },
    command = None (List Text),
    healthcheck = {
        port = 80,
        endpoint = "/",
        startTime = 1,
        retry = 1,
        interval = 1
    } : ../types/healthcheck.dhall
}
