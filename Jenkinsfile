stage('Deploy to Kubernetes') {
    steps {
        script {
            sh '''
                KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
                curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                chmod +x kubectl
                mv kubectl /usr/local/bin/ || cp kubectl /usr/local/bin/
            '''
        }

        withCredentials([string(credentialsId: 'docker-hub-pat', variable: 'DOCKER_PAT')]) {
            withKubeConfig([credentialsId: 'kubeconfig']) {
                sh '''
                    # Pastikan NGINX Ingress Controller terpasang
                    if ! kubectl get deployment -n ingress-nginx ingress-nginx-controller &> /dev/null; then
                        echo "Installing NGINX Ingress Controller..."
                        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

                        # Tunggu controller siap
                        echo "Waiting for NGINX Ingress Controller to be ready..."
                        kubectl wait --namespace ingress-nginx \
                          --for=condition=ready pod \
                          --selector=app.kubernetes.io/component=controller \
                          --timeout=120s
                    fi

                    # Update image tag in deployment
                    sed -i "s|image: docker.io/ardidafa/portfolio:.*|image: docker.io/ardidafa/portfolio:${IMAGE_TAG}|g" deployments/kubernetes/base/deployment.yaml

                    # Create namespace if it doesn't exist
                    kubectl create namespace $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

                    # Create Docker registry secret if it doesn't exist
                    kubectl create secret docker-registry docker-registry-secret \
                        --docker-server=$DOCKER_REGISTRY \
                        --docker-username=ardidafa \
                        --docker-password=$DOCKER_PAT \
                        -n $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

                    # Apply Kubernetes configurations
                    kubectl apply -f deployments/kubernetes/base/configmap.yaml -n $KUBERNETES_NAMESPACE
                    kubectl apply -f deployments/kubernetes/base/deployment.yaml -n $KUBERNETES_NAMESPACE
                    kubectl apply -f deployments/kubernetes/base/service.yaml -n $KUBERNETES_NAMESPACE
                    kubectl apply -f deployments/kubernetes/base/hpa.yaml -n $KUBERNETES_NAMESPACE

                    # Apply cert-manager resources
                    kubectl apply -f deployments/kubernetes/cert-manager/cluster-issuer.yaml

                    # Apply Certificate dan tunggu hingga siap
                    kubectl apply -f deployments/kubernetes/ingress/certificate.yaml -n $KUBERNETES_NAMESPACE

                    # Apply Ingress resource
                    kubectl apply -f deployments/kubernetes/ingress/ingress.yaml -n $KUBERNETES_NAMESPACE
                '''

                // Verify deployment
                sh "kubectl rollout status deployment/portfolio -n $KUBERNETES_NAMESPACE --timeout=300s"
            }
        }
    }
}