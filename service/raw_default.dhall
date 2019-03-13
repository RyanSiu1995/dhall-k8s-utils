let intOrString = ../../dhall-k8s/types/io.k8s.apimachinery.pkg.util.intstr.IntOrString.dhall
in
{ service = ../../dhall-k8s/default/io.k8s.api.core.v1.Service.dhall
, spec    = ../../dhall-k8s/default/io.k8s.api.core.v1.ServiceSpec.dhall
, port    = ../../dhall-k8s/default/io.k8s.api.core.v1.ServicePort.dhall
, meta    = ../../dhall-k8s/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
, Int     = intOrString.Int
, String  = intOrString.String
}
