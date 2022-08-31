echo "$(terraform output kube_config)" > ./azurek8s
sed -i '/EOT/d' ./azurek8s
export KUBECONFIG=./azurek8s
kubectl get nodes
cat ./azurek8s | base64 > kubeconfig
cp ~/.kube/config ~/.kube/config.bak && KUBECONFIG=~/.kube/config:azurek8s kubectl config view --flatten > /tmp/config && mv /tmp/config ~/.kube/config
gh secret set KUBE_CONFIG < kubeconfig
rm ./azurek8s
rm ./kubeconfig

