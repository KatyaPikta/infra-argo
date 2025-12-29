## Требования
- Kubernetes кластер
- ArgoCD установленный и доступный
- Helm
- Git repository access
## Структура репозитория argo
```text
argo-helm-deployments/
├── README.md                          # Этот файл
├── apps/                              # ArgoCD Application манифесты 
├── charts/                            # Helm charts
│   └── myapp/                          
├── values/                            # values
│   └── myapp/                         # Для каждого application своя директория    
│       └── values.yaml
└── root-app.yaml                      # ArgoCD root configuration
```
##  Добавление нового приложения в ArgoCD
- Клонируем репозиторий argo
- Подготовка Helm Chart: либо пишем свой чарт, либо клонируем уже готовый чарт
- Cоздаем values файлы values/newapp/values.yaml
```yaml
replicaCount: 3
image:
  pullPolicy: Always
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
autoscaling:
  enabled: true
```
- Создаем ArgoCD Application манифест
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: newapp
spec:
  project: default
  source:
    repoURL: <repoURL>
    targetRevision: HEAD
    path: charts/newapp
    helm:
      skipCrds: true
      valueFiles:
        - "../../values/newapp/values.yaml"
  destination:
    server: https://kubernetes.default.svc
    namespace: newapp
    
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true

```
- Пуш в main ветку argo-репозитория. Создание и deploy нового приложения произойдет автоматически