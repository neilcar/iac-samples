# Installation guide: https://istio.io/docs/setup/kubernetes/quick-start/
rm -rf $(ls | grep istio-)
# Download Istio latest release - see https://istio.io/docs/setup/kubernetes/download-release/#download-and-prepare-for-the-installation
curl -L https://git.io/getLatestIstio | sh -
istio_dir=$(ls | grep istio-)
export PATH=${PWD}/${istio_dir}/bin:${PATH}
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Istio in Kubernetes cluster - see https://istio.io/docs/setup/kubernetes/quick-start/
# create Istio CRDs
kubectl apply -f ${istio_dir}/install/kubernetes/helm/istio/templates/crds.yaml
# install Istio
kubectl apply -f ${istio_dir}/install/kubernetes/istio-demo.yaml
# Ensure istio-system pods are up and running
kubectl get pods -n istio-system

set -e
istio_dir=$(ls | grep istio-)
export PATH=${istio_dir}/bin:$PATH
# Deploy Bookinfo sample app - see https://istio.io/docs/examples/bookinfo/#if-you-are-running-on-kubernetes
# Enable automatic sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite
# Create Kubernetes Bookinfo services and deployments
kubectl apply -f ${istio_dir}/samples/bookinfo/platform/kube/bookinfo.yaml 
# Set up ingress IP and port - see https://istio.io/docs/examples/bookinfo/#determining-the-ingress-ip-and-port
kubectl apply -f ${istio_dir}/samples/bookinfo/networking/bookinfo-gateway.yaml 
# Create destination rules - see https://istio.io/docs/examples/bookinfo/#apply-default-destination-rules
kubectl apply -f ${istio_dir}/samples/bookinfo/networking/destination-rule-all.yaml 
# Create virtual services that forward traffic to v1 in services - see https://istio.io/docs/tasks/traffic-management/request-routing/#apply-a-virtual-service
kubectl apply -f ${istio_dir}/samples/bookinfo/networking/virtual-service-all-v1.yaml 
# Enable authorization
# See - https://istio.io/docs/tasks/security/role-based-access-control/#before-you-begin
# kubectl apply -f ${istio_dir}/samples/bookinfo/platform/kube/bookinfo-add-serviceaccount.yaml 
# See - https://istio.io/docs/tasks/security/role-based-access-control/#enabling-istio-authorization
kubectl apply -f ${istio_dir}/samples/bookinfo/platform/kube/rbac/rbac-config-ON.yaml 
echo enabled authorization
# Create service roles and service role bindings - see https://istio.io/docs/tasks/security/role-based-access-control/#service-level-access-control
kubectl apply -f ${istio_dir}/samples/bookinfo/platform/kube/rbac/productpage-policy.yaml 
kubectl apply -f ${istio_dir}/samples/bookinfo/platform/kube/rbac/details-reviews-policy.yaml 
kubectl apply -f ${istio_dir}/samples/bookinfo/platform/kube/rbac/ratings-policy.yaml 
echo created service roles and service role bindings 
