#!/bin/bash

# Constant / Args
APP=$1
SVC1=$2
SVC2=$3
NAMESPACE=demo-ingress-${APP}
DOMAIN=k8s01.hpedemo.local

echo
echo "Creating two different fake API endpoints /${SVC1} and /${SVC2} in namespace $NAMESPACE"
echo
cat <<EOF | kubectl apply -f -

---
kind: Namespace
apiVersion: v1
metadata:
  name: $NAMESPACE
  labels:
    name: $NAMESPACE

---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: orders
  namespace: $NAMESPACE
  labels:
    app: orders
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: ${SVC1}-frontend
  template:
    metadata:
      labels:
        tier: ${SVC1}-frontend
    spec:
      containers:
      - name: ${SVC1}
        image: hashicorp/http-echo:0.2.3
        # TODO: This does not work for some reason
        env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        args:
        - "-text=You reached the ${SVC1} API endpoint @ ${MY_NODE_NAME} node"

---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ${SVC2}
  namespace: $NAMESPACE
  labels:
    app: ${SVC2}
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: ${SVC2}-frontend
  template:
    metadata:
      labels:
        tier: ${SVC2}-frontend
    spec:
      containers:
      - name: ${SVC2}
        image: hashicorp/http-echo:0.2.3
        args:
        - "-text=You reached the ${SVC2} API endpoint @ $PODNAME"

---
kind: Service
apiVersion: v1
metadata:
  name: ${SVC1}-service
  namespace: $NAMESPACE
spec:
  selector:
    tier: ${SVC1}-frontend
  ports:
  # Default port used by the echo image
  - port: 80
    targetPort: 5678

---
kind: Service
apiVersion: v1
metadata:
  name: ${SVC2}-service
  namespace: $NAMESPACE
spec:
  #type: NodePort
  selector:
    tier: ${SVC2}-frontend
  ports:
  # Default port used by the echo image
  - port: 80
    targetPort: 5678

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APP}-${SVC1}-ingress
  namespace: $NAMESPACE
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${APP}.${DOMAIN}
    secretName: hpedemo-local-wildcardcert
  rules:
  - host: ${APP}.${DOMAIN}
    http:
      paths:
        - pathType: Prefix
          path: "/${SVC1}"
          backend:
            service:
              name: ${SVC1}-service
              port:
                number: 80

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APP}-${SVC2}-ingress
  namespace: $NAMESPACE
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${APP}.${DOMAIN}
    #secretName: hpedemo-local-wildcardcert
    #secretName: ${APP}-hpedemo-local
  rules:
  - host: ${APP}.${DOMAIN}
    http:
      paths:
        - pathType: Prefix
          path: "/${SVC2}"
          backend:
            service:
              name: ${SVC2}-service
              port:
                number: 80


EOF

echo
echo Run the below to check status of ingress
echo kubectl describe ingress --namespace=$NAMESPACE
echo

echo Endpoint1: https://${APP}.${DOMAIN}/${SVC1}
echo Endpoint2: https://${APP}.${DOMAIN}/${SVC2}

echo
echo Cleanup: kubectl delete all --all --namespace=$NAMESPACE
echo
