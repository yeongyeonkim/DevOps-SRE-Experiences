resource "helm_release" "kube-prometheus-stack" {
  count            = var.create_oss["kube_prometheus_stack"] ? 1 : 0
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  create_namespace = true
  name             = "kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  version          = local.kube_prometheus_stack_version
  force_update     = true
  reuse_values     = true
  values = [
    yamlencode({
      alertmanager = {
        ingress = {
          enabled = false
        }
        alertmanagerSpec = {
          affinity    = local.affinity
          tolerations = local.tolerations
        }
        config = {
          global = {
            resolve_timeout = "10m"
          }
          route = {
            group_by        = ["namespace"]
            group_wait      = "30s" # 다음알림이 오기까지 group화할 알림을 기다리는 시간
            group_interval  = "3m"  # 알림 후 다음 알림까지 기다리는 시간
            repeat_interval = "1h"  # resolved 되지 않은 동일한 알람을 다시 발동하는 시간
            receiver        = "default"
            routes = [
              {
                receiver = "critical"
                matchers = [
                  "severity=\"critical\"",
                  "env=\"${var.env}\""
                ]
              },
              {
                receiver = "warning"
                matchers = [
                  "severity=\"warning\"",
                  "env=\"${var.env}\""
                ]
              }
            ]
          }
          inhibit_rules = [
            {
              source_matchers = [
                "severity=critical"
              ],
              target_matchers = [
                "severity=~warning|info"
              ],
              equal = [
                "namespace"
              ]
            },
            {
              source_matchers = [
                "severity=warning"
              ],
              target_matchers = [
                "severity=info"
              ],
              equal = [
                "namespace"
              ]
            }
          ]
          receivers = [
            {
              name = "critical"
              webhook_configs = [
                {
                  url           = var.alertmanager_webhook_url["critical"]
                  send_resolved = true
                }
              ]
            },
            {
              name = "warning"
              webhook_configs = [
                {
                  url           = var.alertmanager_webhook_url["warning"]
                  send_resolved = true
                }
              ]
            },
            {
              name = "default"
              webhook_configs = [
                {
                  url           = var.alertmanager_webhook_url["default"]
                  send_resolved = true
                }
              ]
            }
          ]
        }
      }

      grafana = {
        defaultDashboardsEnabled  = false
        defaultDashboardsTimezone = "Asia/Seoul"
        adminPassword             = "admin"
        "grafana.ini" = {
          server = {
            root_url            = "%(protocol)s://%(domain)s/grafana"
            serve_from_sub_path = true
          }
        }
        sidecar = {
          dashboards = {
            provider = {
              allowUiUpdates = true
            }
          }
        }
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations      = local.ingress_default_annotation
          path             = "/grafana"
        }
        ## PVC는 개선 대상
        persistence = {
          enabled          = true
          storageClassName = "grafana-sc"
          type             = "pvc"
          accessModes      = ["ReadWriteOnce"]
          size             = local.persistence.grafana
        }
        resources   = local.resource.grafana
        affinity    = local.affinity
        tolerations = local.tolerations
      }

      prometheusOperator = {
        affinity    = local.affinity
        tolerations = local.tolerations
      }

      prometheus = {
        service = {
          type = "NodePort"
        }
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations      = local.ingress_default_annotation
          paths            = ["/prometheus"]
          pathType         = "Prefix"
        }
        enableAdminAPI = true
        prometheusSpec = {
          # ruleSelectorNilUsesHelmValues = false
          enableRemoteWriteReceiver = true
          resources                 = local.resource.prometheus
          retention                 = local.retention.prometheus
          retentionSize             = local.retention_size.prometheus
          routePrefix               = "/prometheus"
          externalUrl               = local.externalUrl[var.env]
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                enabled          = true
                storageClassName = "prometheus-sc"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = local.persistence.prometheus
                  }
                }
              }
            }
          }
          affinity    = local.affinity
          tolerations = local.tolerations
        }
      },
      # kube_node_labels 쿼리 하기 위해 
      # kube-state-metrics의 --metric-allowlist 옵션을 넣어야 한다.
      kube-state-metrics = {
        prometheusScrape = true
        metricLabelsAllowlist = [
          "nodes=[*]",
          "pods=[*]",
          "horizontalpodautoscalers=[*]"
        ]
        affinity    = local.affinity
        tolerations = local.tolerations
      }
    })
  ]
  depends_on = [kubernetes_storage_class.monitoring_storage_class]
}