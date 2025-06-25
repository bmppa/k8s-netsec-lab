#!/bin/bash

set -e  # Exit immediately on error

NAMESPACE="default"
NGINX_POD="nginx-server"
BUSYBOX_1_POD="busybox-client-1"
BUSYBOX_2_POD="busybox-client-2"
NGINX_SERVICE="nginx-service"

echo "🚀 Setting up Kubernetes Network Policy Test Environment"

# Step 1: Deploy Test Applications
kubectl apply -f pods.yaml

# Step 2: Wait for Pods to be Ready
echo "⌛ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=nginx -n $NAMESPACE --timeout=60s
sleep 5

# Step 3: Verify Initial Connectivity (Should Succeed)
echo "✅ Testing initial connectivity using Client 1 (should be allowed)..."
kubectl exec -n $NAMESPACE $BUSYBOX_1_POD -- wget --spider $NGINX_SERVICE
echo "✅ Testing initial connectivity using Client 2 (should be allowed)..."
kubectl exec -n $NAMESPACE $BUSYBOX_2_POD -- wget --spider $NGINX_SERVICE

# Step 4: Apply a "Deny All" Network Policy
echo "⛔ Applying 'Deny All' network policy..."
kubectl apply -f deny-all.yaml

# Step 5: Verify Connectivity (Should Fail)
echo "🚨 Testing connectivity after 'Deny All' using Client 1 (should fail)..."
kubectl exec -n $NAMESPACE $BUSYBOX_1_POD -- wget --spider -T 5 $NGINX_SERVICE || echo "✅ Connection blocked as expected."
echo "🚨 Testing connectivity after 'Deny All' using Client 2 (should fail)..."
kubectl exec -n $NAMESPACE $BUSYBOX_2_POD -- wget --spider -T 5 $NGINX_SERVICE || echo "✅ Connection blocked as expected."

# Step 6: Apply "Allow Only from Labeled Client"
echo "🔓 Applying 'Allow Only from Labeled Client' policy..."
kubectl apply -f allow-client.yaml

# Step 7: Verify Connectivity (Should Fail - No Labels)
echo "🚨 Testing connectivity from unlabeled client 2 (should fail)..."
kubectl exec $BUSYBOX_2_POD -- wget --spider -T 5 $NGINX_SERVICE || echo "✅ Connection blocked as expected."

# Step 8: Verify Connectivity for labeled client 1 (Should Succeed)
echo "✅ Testing connectivity for labeled client 1 (should be allowed)..."
kubectl exec $BUSYBOX_1_POD -- wget --spider $NGINX_SERVICE && echo "✅ Connection allowed as expected."

# Step 9: Apply "Deny All" Egress Policy
echo "⛔ Applying 'Deny All' egress policy..."
kubectl apply -f deny-all-egress.yaml 

# Step 10: Verify Egress Connectivity (Should Fail)
echo "🚨 Testing egress connectivity after 'Deny All' (should fail)..."
kubectl exec $BUSYBOX_1_POD  -- wget --spider -T 5 http://example.com || echo "✅ Connection blocked as expected."

# Step 11: Apply "Allow Egress to DNS" Policy
echo "🔓 Applying 'Allow Egress to DNS' policy..."
kubectl apply -f allow-egress.yaml 

# Step 12: Verify DNS Works But External Access Still Fails
echo "✅ Testing DNS resolution (should work)..."
kubectl exec $BUSYBOX_1_POD -- nslookup example.com

echo "🚨 Testing external HTTP access after 'Allow DNS' (should still fail)..."
kubectl exec $BUSYBOX_1_POD -- wget --spider -T 5 http://example.com || echo "✅ External HTTP connection still blocked as expected."

# CLEANUP
echo "🧹 Cleanup..."
read -p "Delete test namespaces? (y/N): " DEL
if [[ "$DEL" =~ ^[Yy]$ ]]; then
  kubectl delete -f .
  echo "✅ Cleanup completed."
else
  echo "⚠️ Remember to clean up manually with: kubectl delete -f ."
fi