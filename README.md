# 🧪 Kubernetes Network Policy Lab

This repository contains a set of automated scripts to test **Kubernetes NetworkPolicies**, including **ingress**, and **egress** restrictions.

The goal is to provide DevOps engineers and security practitioners a **repeatable and hands-on way to validate network isolation** using real workloads.

---

## 📦 Features

- ✅ Ingress and egress policy validation
- 🧪 Automated test cases with real service-to-pod communication
- 🏷️ Namespace and pod selector-based access control
- 📜 Fully self-contained Bash scripts with no external dependencies

---

## 🚀 Getting Started

### ✅ Prerequisites

- Kubernetes cluster (local or remote)
- Container Network Interface (CNI) like Calico or Cilium
- `kubectl` installed and configured
- Internet access from the cluster for external DNS tests

---

## 🧪 Usage

### 1. Clone the repository

```bash
git clone https://github.com/bmppa/k8s-netsec-lab.git
cd k8s-netsec-lab
````

### 2. Run the test script

```
chmod +x single-namespace-network-policy-test.sh
./single-namespace-network-policy-test.sh
```

---

## 📋 What It Tests

| Test Scenario                    | What It Verifies                  |
| -------------------------------- | --------------------------------- |
| Default pod-to-pod communication | No isolation by default           |
| Ingress: deny-all                | No pod can reach others           |
| Ingress: allow only labeled pods | Granular control using labels     |
| Egress: deny-all                 | Block all outbound traffic        |
| Egress: allow DNS only           | Allow only UDP/53 (DNS)           |

---

## 🧹 Cleanup

Each script ends with an option to delete test namespaces:

```
Do you want to delete the test namespace(s)? (y/N):
```

Or you can clean up manually:

```
kubectl delete -f .
```
