let global = ./config.dhall
let serviceConfig = global.{{{service}}}
let map = ./utils/prelude/list_map.dhall

let Secret = ./utils/types/secret.dhall
let Mount = ./utils/types/mount.dhall
let Port = ./utils/types/port.dhall
let HealthCheck = ./utils/types/healthcheck.dhall
let Probe = ./dhall-k8s/api/Deployment/Probe

let secretMapper = \(a: Secret) -> a.username
let volumeMapper = \(a: Mount) -> { name = a.name , path = a.target }
let mountMapper = \(a: Mount) -> { name = a.name , mountPath = a.mountPoint , readOnly = Some False}

let imageSecret =
  map Secret Text secretMapper serviceConfig.imagePullSecrets

let portMapper =
  \(port : Port) -> port.containerPort

let healthcheckMapper =
  \(health : HealthCheck) ->
    {
      initial = health.startTime,
      period = health.interval,
      failureThreshold = health.retry,
      path = health.endpoint,
      port = health.port
    } : Probe

let spec : ./dhall-k8s/api/Deployment/Deployment =
   ./dhall-k8s/api/Deployment/default //
   {
     name = serviceConfig.name,
     replicas = serviceConfig.replicas,
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
          livenessProbe = Some (healthcheckMapper serviceConfig.healthcheck),
          readinessProbe = Some (healthcheckMapper serviceConfig.healthcheck)
        }
     ],
     imagePullSecrets = imageSecret,
     host = serviceConfig.host,
     pathVolumes = map Mount {name : Text, path : Text} volumeMapper serviceConfig.mount,
     nodeSelectors = serviceConfig.nodeSelectors
   }


in ./dhall-k8s/api/Deployment/mkDeployment spec
