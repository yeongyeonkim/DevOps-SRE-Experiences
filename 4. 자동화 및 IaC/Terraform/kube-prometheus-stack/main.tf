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
      ######################## alertmanager 설정 ########################
      alertmanager = {
        ingress = {
          enabled = false
          # ingressClassName = "alb"
          # annotations      = local.ingress_default_annotation
          # paths            = ["/alertmanager"]
        }
        alertmanagerSpec = {
          # logLevel = "debug"
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
              },
              {
                receiver = "info"
                matchers = [
                  "severity=\"info\"",
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
              name = "info"
              webhook_configs = [
                {
                  url           = var.alertmanager_webhook_url["info"]
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

      ######################## grafana 설정 ########################
      grafana = {
        sidecar = {
          alerts = {
            enabled         = true
            resource        = "configmap"     # CM 사용
            label           = "grafana_alert" # CM 라벨 키
            labelValue      = "1"             # (옵션) 라벨 값
            searchNamespace = "monitoring"    # 같은 네임스페이스만 감시(권장)
            reloadURL       = "http://localhost:3000/api/admin/provisioning/alerting/reload"
            env = [
              { name = "REQ_USERNAME", value = "admin" },
              { name = "REQ_PASSWORD", value = "admin" },
            ]
          },
          datasources = {
            enabled         = true
            resource        = "configmap"          # CM 사용
            label           = "grafana_datasource" # CM 라벨 키
            labelValue      = "1"                  # (옵션) 라벨 값
            searchNamespace = "monitoring"         # 같은 네임스페이스만 감시(권장)
            reloadURL       = "http://localhost:3000/api/admin/provisioning/datasources/reload"
            env = [
              { name = "REQ_USERNAME", value = "admin" },
              { name = "REQ_PASSWORD", value = "admin" },
            ]
          },
          dashboards = {
            provider = {
              allowUiUpdates = true
            }
          }
        }
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

      #################### prometheus operator 설정 ########################
      prometheusOperator = {
        affinity    = local.affinity
        tolerations = local.tolerations
      }

      ################### prometheus 설정 ########################
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
          # 네임스페이스에 관계 없이 PrometheusRule을 프로메테우스 오퍼레이터가 인식할 수 있도록 한다.
          # ruleSelectorNilUsesHelmValues = false
          enableRemoteWriteReceiver = true
          resources                 = local.resource.prometheus
          retention                 = local.retention.prometheus
          retentionSize             = local.retention_size.prometheus
          routePrefix               = "/prometheus"
          externalUrl               = local.externalUrl[var.env]
          storageSpec = {
            ## Using PersistentVolumeClaim
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
        # chart로만 생성된 monitor를 감지 (default: true)
        # serviceMonitorSelectorNilUsesHelmValues = false
        # 근데 true하면 아래 설정이 안됨.
        # additionalServiceMonitors = [
        #   {
        #     "name" : "test-servicemonitor",
        #     "selector" : {
        #       "matchLabels" : {
        #         "env" : "test"
        #       }
        #     },
        #     "namespaceSelector" : {
        #       "any" : true
        #       # "any": false,
        #       # "matchNames": [
        #       #     "test", "testt"
        #       # ]
        #     },
        #     "endpoints" : [
        #       {
        #         "port" : "http",
        #         "path" : "/test/monitor/metrics"
        #       }
        #     ]
        #   }
        # ]
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