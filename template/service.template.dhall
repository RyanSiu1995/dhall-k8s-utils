let global = ./config.dhall
let serviceConfig = global.{{{service}}}

let service =
  ./utils/service/default.dhall //
  {
    name = serviceConfig.name,
    port = serviceConfig.port
  }

in ./utils/service/make.dhall service
