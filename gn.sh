#!/bin/bash

read -p "Application Name : " APP
read -p "Image Name : " IMAGE
read -p "Image Tag : " TAG
read -p "Container Port : " PORT
read -p "Application URL : " URL

mkdir -p apps

#########################################
# Deployment
#########################################

cat > quikit/${APP}-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP}-deployment
  namespace: quikit
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${APP}
  template:
    metadata:
      labels:
        app: ${APP}
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "global-role"
        vault.hashicorp.com/agent-init-first: "true"
        vault.hashicorp.com/agent-inject-secret-config: "secret/data/quikit/auth-service"
        vault.hashicorp.com/agent-inject-template-config: |
          {{- with secret "secret/data/quikit/auth-service" -}}
          export ADMIN_CLIENT_SECRET="{{ .Data.data.ADMIN_CLIENT_SECRET }}"
          export AUTH_ALLOWED_RETURN_ORIGINS="{{ .Data.data.AUTH_ALLOWED_RETURN_ORIGINS }}"
          export AUTH_CORS_ORIGINS="{{ .Data.data.AUTH_CORS_ORIGINS }}"
          export DATABASE_URL="{{ .Data.data.DATABASE_URL }}"
          export DATABASE_URL_DIRECT="{{ .Data.data.DATABASE_URL_DIRECT }}"
          export EMAIL_PASSWORD="{{ .Data.data.EMAIL_PASSWORD }}"
          export EMAIL_PASSWORD_B64="{{ .Data.data.EMAIL_PASSWORD_B64 }}"
          export EMAIL_USER="{{ .Data.data.EMAIL_USER }}"
          export GOOGLE_CLIENT_ID="{{ .Data.data.GOOGLE_CLIENT_ID }}"
          export GOOGLE_CLIENT_SECRET="{{ .Data.data.GOOGLE_CLIENT_SECRET }}"
          export INTERNAL_SECRET="{{ .Data.data.INTERNAL_SECRET }}"
          export META_APP_ID="{{ .Data.data.META_APP_ID }}"
          export META_APP_SECRET="{{ .Data.data.META_APP_SECRET }}"
          export MICROSOFT_CLIENT_ID="{{ .Data.data.MICROSOFT_CLIENT_ID }}"
          export MICROSOFT_CLIENT_SECRET="{{ .Data.data.MICROSOFT_CLIENT_SECRET }}"
          export MICROSOFT_TENANT_ID="{{ .Data.data.MICROSOFT_TENANT_ID }}"
          export NEXTAUTH_SECRET="{{ .Data.data.NEXTAUTH_SECRET }}"
          export REDIS_URL="{{ .Data.data.REDIS_URL }}"
          export SMTP_FROM="{{ .Data.data.SMTP_FROM }}"
          export SMTP_HOST="{{ .Data.data.SMTP_HOST }}"
          export SMTP_PASS="{{ .Data.data.SMTP_PASS }}"
          export SMTP_PORT="{{ .Data.data.SMTP_PORT }}"
          export SMTP_USER="{{ .Data.data.SMTP_USER }}"
          export JWT_SIGNING_KEY='{{ .Data.data.JWT_SIGNING_KEY }}'
          export JWT_SIGNING_KEY_PUBLIC='{{ .Data.data.JWT_SIGNING_KEY_PUBLIC }}'
          {{- end }} 
    spec:
      imagePullSecrets:
        - name: ghcr-secret
      containers:
      - name: ${APP}
        image: ghcr.io/akhileshgandhi/${IMAGE}-runtime:sha-${TAG}

        command:
        - /bin/sh
        - -c
        - |
          set -a
          . /vault/secrets/config
          set +a
          cd /app/apps/${IMAGE}
          exec node server.js

        ports:
        - containerPort: ${PORT}

        envFrom:
        - configMapRef:
            name: quikit-config

        env:
        - name: NEXTAUTH_URL
          value: "${URL}"

        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "200m"
            memory: "256Mi"

        livenessProbe:
          httpGet:
            path: /api/health
            port: ${PORT}
          initialDelaySeconds: 45
          periodSeconds: 20

        readinessProbe:
          httpGet:
            path: /api/health
            port: ${PORT}
          initialDelaySeconds: 15
          periodSeconds: 10
EOF

#########################################
# Service
#########################################

cat > quikit/${APP}-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${APP}-service
  namespace: quikit
spec:
  selector:
    app: ${APP}
  ports:
  - protocol: TCP
    port: ${PORT}
    targetPort: ${PORT}
  type: NodePort
EOF

#########################################
# HPA
#########################################

cat > quikit/${APP}-hpa.yaml <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${APP}-hpa
  namespace: quikit
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${APP}-deployment
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

echo
echo "Generated Successfully"
echo "----------------------"
echo "quikit/${APP}-deployment.yaml"
echo "quikit/${APP}-service.yaml"
echo "quikit/${APP}-hpa.yaml"