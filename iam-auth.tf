//resource "kubernetes_cluster_role" "aws_iam_authenticator" {
//  metadata {
//    name = "aws-iam-authenticator"
//  }
//
//  rule {
//    verbs      = ["get", "list", "watch"]
//    api_groups = ["iamauthenticator.k8s.aws"]
//    resources  = ["iamidentitymappings"]
//  }
//
//  rule {
//    verbs      = ["patch", "update"]
//    api_groups = ["iamauthenticator.k8s.aws"]
//    resources  = ["iamidentitymappings/status"]
//  }
//
//  rule {
//    verbs      = ["create", "update", "patch"]
//    api_groups = [""]
//    resources  = ["events"]
//  }
//}
//
//resource "kubernetes_service_account" "aws_iam_authenticator" {
//  metadata {
//    name      = "aws-iam-authenticator"
//    namespace = "kube-system"
//  }
//}
//
//resource "kubernetes_cluster_role_binding" "aws_iam_authenticator" {
//  metadata {
//    name = "aws-iam-authenticator"
//  }
//
//  subject {
//    kind      = "ServiceAccount"
//    name      = "aws-iam-authenticator"
//    namespace = "kube-system"
//  }
//
//  role_ref {
//    api_group = "rbac.authorization.k8s.io"
//    kind      = "ClusterRole"
//    name      = "aws-iam-authenticator"
//  }
//}
//
//resource "kubernetes_config_map" "aws_iam_authenticator" {
//  metadata {
//    name      = "aws-iam-authenticator"
//    namespace = "kube-system"
//
//    labels = {
//      k8s-app = "aws-iam-authenticator"
//    }
//  }
//
//  data = {
//    "config.yaml" = "# a unique-per-cluster identifier to prevent replay attacks\n# (good choices are a random token or a domain name that will be unique to your cluster)\nclusterID: my-dev-cluster.example.com\nserver:\n  # each mapRoles entry maps an IAM role to a username and set of groups\n  # Each username and group can optionally contain template parameters:\n  #  1) \"{{AccountID}}\" is the 12 digit AWS ID.\n  #  2) \"{{SessionName}}\" is the role session name.\n  mapRoles:\n  # statically map arn:aws:iam::000000000000:role/KubernetesAdmin to a cluster admin\n  - roleARN: arn:aws:iam::000000000000:role/KubernetesAdmin\n    username: kubernetes-admin\n    groups:\n    - system:masters\n  # map EC2 instances in my \"KubernetesNode\" role to users like\n  # \"aws:000000000000:instance:i-0123456789abcdef0\". Only use this if you\n  # trust that the role can only be assumed by EC2 instances. If an IAM user\n  # can assume this role directly (with sts:AssumeRole) they can control\n  # SessionName.\n  - roleARN: arn:aws:iam::000000000000:role/KubernetesNode\n    username: aws:{{AccountID}}:instance:{{SessionName}}\n    groups:\n    - system:bootstrappers\n    - aws:instances\n  # map federated users in my \"KubernetesAdmin\" role to users like\n  # \"admin:alice-example.com\". The SessionName is an arbitrary role name\n  # like an e-mail address passed by the identity provider. Note that if this\n  # role is assumed directly by an IAM User (not via federation), the user\n  # can control the SessionName.\n  - roleARN: arn:aws:iam::000000000000:role/KubernetesAdmin\n    username: admin:{{SessionName}}\n    groups:\n    - system:masters\n  # map federated users in my \"KubernetesUsers\" role to users like\n  # \"alice@example.com\". SessionNameRaw is sourced from the same place as\n  # SessionName with the distinction that no transformation is performed\n  # on the value. For example an email addresses passed by an identity\n  # provider will not have the `@` replaced with a `-`.\n  - roleARN: arn:aws:iam::000000000000:role/KubernetesUsers\n    username: \"{{SessionNameRaw}}\"\n    groups:\n    - developers\n  # each mapUsers entry maps an IAM role to a static username and set of groups\n  mapUsers:\n  # map user IAM user Alice in 000000000000 to user \"alice\" in \"system:masters\"\n  - userARN: arn:aws:iam::000000000000:user/Alice\n    username: alice\n    groups:\n    - system:masters\n  # List of Account IDs to whitelist for authentication\n  mapAccounts:\n  # - <AWS_ACCOUNT_ID>\n"
//  }
//}
//
//resource "kubernetes_daemonset" "aws_iam_authenticator" {
//  metadata {
//    name      = "aws-iam-authenticator"
//    namespace = "kube-system"
//
//    labels = {
//      k8s-app = "aws-iam-authenticator"
//    }
//  }
//
//  spec {
//    selector {
//      match_labels = {
//        k8s-app = "aws-iam-authenticator"
//      }
//    }
//
//    template {
//      metadata {
//        labels = {
//          k8s-app = "aws-iam-authenticator"
//        }
//      }
//
//      spec {
//        volume {
//          name = "config"
//
//          config_map {
//            name = "aws-iam-authenticator"
//          }
//        }
//
//        volume {
//          name = "output"
//
//          host_path {
//            path = "/etc/kubernetes/aws-iam-authenticator/"
//          }
//        }
//
//        volume {
//          name = "state"
//
//          host_path {
//            path = "/var/aws-iam-authenticator/"
//          }
//        }
//
//        container {
//          name  = "aws-iam-authenticator"
//          image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-iam-authenticator:v0.4.0"
//          args  = ["server", "--config=/etc/aws-iam-authenticator/config.yaml", "--state-dir=/var/aws-iam-authenticator", "--generate-kubeconfig=/etc/kubernetes/aws-iam-authenticator/kubeconfig.yaml"]
//
//          resources {
//            limits {
//              memory = "20Mi"
//              cpu    = "100m"
//            }
//
//            requests {
//              cpu    = "10m"
//              memory = "20Mi"
//            }
//          }
//
//          volume_mount {
//            name       = "config"
//            mount_path = "/etc/aws-iam-authenticator/"
//          }
//
//          volume_mount {
//            name       = "state"
//            mount_path = "/var/aws-iam-authenticator/"
//          }
//
//          volume_mount {
//            name       = "output"
//            mount_path = "/etc/kubernetes/aws-iam-authenticator/"
//          }
//        }
//
//        service_account_name = "aws-iam-authenticator"
//        host_network         = true
//
//        toleration {
//          key    = "node-role.kubernetes.io/master"
//          effect = "NoSchedule"
//        }
//
//        toleration {
//          key      = "CriticalAddonsOnly"
//          operator = "Exists"
//        }
//      }
//    }
//
//    strategy {
//      type = "RollingUpdate"
//    }
//  }
//}
//
