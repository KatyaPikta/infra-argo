## Инициализация и Unseal Vault:
- Подключаемя к pod vault
```bash
kubectl exec -it <name_pod_vault> -n vault -- sh
```
- Запускаем инициализацию и сохраняем результат вывода
```bash
vault operator init
```
- Unseal Vault (нужно ввести 3 ключа)
```bash
vault operator unseal

vault status
```

## Настройка Vault
- Заходим в vault с использование root token (сохранили после инициализации)
```bash
kubectl exec -n vault -it hashicorp-vault-0 -- vault login
```
- Настраиваем аутентификацию kubernetes, создаем роль для external-secret
```bash
kubectl exec -n vault -it hashicorp-vault-0 -- vault secrets enable -path=secret kv-v2
kubectl exec -n vault -it hashicorp-vault-0 -- vault auth enable kubernetes
kubectl exec -n vault -it hashicorp-vault-0 -- vault policy write external-secrets - <<EOF
path "secret/*" {
  capabilities = ["read", "list"]
}
EOF
kubectl exec -n vault -it vault-0 -- vault write auth/kubernetes/role/external-secrets \   bound_service_account_names=external-secrets   bound_service_account_namespaces=external-secret  \
policies=external-secrets   ttl=24h
```
## Создание нового секрета
- Создаем секрет в Vault
```bash
vault kv put secret/velero/credentials \
  cloud=do-token
```
-  Создание ExternalSecret манифеста
```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: velero-credentials
  namespace: backup
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: velero-credentials
    creationPolicy: Owner
  data:
    - secretKey: cloud
      remoteRef:
        key: secret/velero/credentials
        property: cloud
```
## Применение и проверка
- Применяем либо через kubectl или помещаем в чарты репозитория infra-argo для автоматического применения 
```bash
kubectl apply -f new-service-externalsecret.yaml
kubectl get externalsecret new-service-credentials -n myapp-task2 -o yaml
kubectl get secret new-service-secret -n myapp-task2 -o yaml
```