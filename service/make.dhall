let map  = ../prelude/list_map.dhall
let kv   = ../prelude/json_keytext.dhall

in let Types = ./raw_type.dhall
in let default = ./raw_default.dhall

in let mkService : ./service.dhall → Types.Service =
  λ(service : ./service.dhall) →
    let selector = Some [kv "app" service.name]

    in let meta = default.meta
    { name = service.name } //
    { labels = selector
    , annotations = Some service.annotations
    }

    in let handlers =
    { ClusterIP    = λ(_ : {}) → "ClusterIP"
    , NodePort     = λ(_ : {}) → "NodePort"
    , LoadBalancer = λ(_ : {}) → "LoadBalancer"
    , ExternalName = λ(_ : {}) → "ExternalName"
    }

    in let portMapper = λ(arg : ./service_port.dhall) →
     default.port { port = arg.containerPort } //
     { targetPort = Some (default.Int arg.containerPort)
     , nodePort = Some arg.nodePort
     , name = Some arg.name }

    in let servicePort : List ../../dhall-k8s/types/io.k8s.api.core.v1.ServicePort.dhall =
      map ./service_port.dhall ../../dhall-k8s/types/io.k8s.api.core.v1.ServicePort.dhall portMapper service.port

    in let spec = default.spec //
    { type = Some (merge handlers service.type : Text)
    , ports = Some servicePort
    , selector = selector
    }

    in default.service
    { metadata = meta
    } //
    { spec = Some spec
    } : Types.Service

in mkService
