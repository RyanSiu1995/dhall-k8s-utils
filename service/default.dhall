{ name          = "CHANGEME"
, annotations   = [] : List { mapKey : Text, mapValue : Text }
, port = [] : List ./service_port.dhall
, type          = (./type.dhall).NodePort {=}
}
