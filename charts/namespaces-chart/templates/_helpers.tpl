{{- define "namespace-chart.fullname" -}}
{{- printf "ns-%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "namespace-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.global.managedBy }}
managed-by: {{ .Values.global.managedBy }}
{{- end }}
{{- end -}}