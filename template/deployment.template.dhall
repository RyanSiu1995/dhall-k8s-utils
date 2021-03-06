let global = ./config.dhall
let serviceConfig = global.{{{service}}}
let map = ./utils/prelude/list_map.dhall
let filter = ./utils/prelude/list_filter.dhall
let optionalNull = ./utils/prelude/optional_null.dhall
let optionalMap = ./utils/prelude/optional_map.dhall

let Secret = ./utils/types/secret.dhall
let Mount = ./utils/types/mount.dhall
let Port = ./utils/types/port.dhall
let HealthCheck = ./utils/types/healthcheck.dhall
let Probe = ./dhall-k8s/api/Deployment/Probe

let secretMapper = \(a: Secret) -> a.username
let pathVolumeMapper = \(a: List Mount) ->
   map Mount { name : Text, path : Text }(\(a: Mount) -> { name = a.name, path = a.target }) (filter Mount (\(b: Mount) -> b.nfs == False && b.secret == False) a)
let secretVolumeMapper = \(a: List Mount) ->
   map Mount { name : Text }(\(a: Mount) -> { name = a.target }) (filter Mount (\(b: Mount) -> b.secret) a)
let nfsVolumeMapper = \(a: List Mount) ->
   map Mount { name : Text, ip : Text }(\(a: Mount) -> { name = a.name, ip = a.target }) (filter Mount (\(b: Mount) -> b.nfs) a)
let mountMapper = \(a: Mount) -> { name = a.name , mountPath = a.mountPoint , readOnly = Some False}

let imageSecret =
  map Secret Text secretMapper serviceConfig.imagePullSecrets

let portMapper =
  \(port : Port) -> port.containerPort

let initContainerMapper =
  \(imageName : Text) ->
  \(imageTag : Text) ->
  \(envVars : List { mapKey : Text, mapValue : Text }) ->
  \(command : { mapKey : Text, mapValue : (List Text)}) ->
    ./dhall-k8s/api/Deployment/defaultContainer //
    {
       name = command.mapKey,
       imageName = imageName,
       imageTag = imageTag,
       command = Some command.mapValue,
       envVars = envVars
    }

let healthcheckMapper =
  \(health : Optional HealthCheck) ->
    optionalMap HealthCheck Probe (\(a: HealthCheck) -> {initial = a.startTime, period = a.interval, failureThreshold = a.retry, path = a.endpoint,  port = a.port }) health

let spec : ./dhall-k8s/api/Deployment/Deployment =
   ./dhall-k8s/api/Deployment/default //
   {
     name = serviceConfig.name,
     replicas = serviceConfig.replicas,
     maxSurge = serviceConfig.maxSurge,
     maxUnavailable = serviceConfig.maxUnavailable,
     containers = [
        ./dhall-k8s/api/Deployment/defaultContainer //
        {
          name = serviceConfig.name,
          imageName = serviceConfig.image,
          imageTag = serviceConfig.version,
          envVars = serviceConfig.environmentVariables,
          command = serviceConfig.command,
          mounts = map Mount { name : Text, mountPath : Text, readOnly : Optional Bool } mountMapper serviceConfig.mount,
          port = Some (map Port Natural portMapper serviceConfig.port),
          livenessProbe = healthcheckMapper serviceConfig.healthcheck,
          readinessProbe = healthcheckMapper serviceConfig.healthcheck
        }
     ],
     imagePullSecrets = imageSecret,
     host = serviceConfig.host,
     initContainers = map { mapKey : Text, mapValue : (List Text) } ./dhall-k8s/api/Deployment/Container (initContainerMapper serviceConfig.image serviceConfig.version serviceConfig.environmentVariables) serviceConfig.initCommands,
     pathVolumes = pathVolumeMapper serviceConfig.mount,
     secretVolumes = secretVolumeMapper serviceConfig.mount,
     nfsVolumes = nfsVolumeMapper serviceConfig.mount,
     nodeSelectors = serviceConfig.nodeSelectors
   }


in ./dhall-k8s/api/Deployment/mkDeployment spec
