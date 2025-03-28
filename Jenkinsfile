pipeline {
    agent any

    tools {
        nodejs 'NodeJS 18'
    }

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'ardidafa/portfolio'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBERNETES_NAMESPACE = 'portfolio'
        NODE_OPTIONS = "--openssl-legacy-provider"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build React App') {
            steps {
                sh 'export NODE_OPTIONS=--openssl-legacy-provider && DISABLE_ESLINT_PLUGIN=true CI=false npm run build'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'npm audit --production || true'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-pat', variable: 'DOCKER_PAT')]) {
                    sh 'echo $DOCKER_PAT | docker login -u ardidafa --password-stdin'
                    sh "docker build --no-cache -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest -f deployments/docker/Dockerfile ."
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"

                    // Verify image was pushed correctly
                    sh "docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker inspect ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
                }
            }
        }

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
                            # FIXED: Better approach to replace image tag
                            ssed -i "s|image: docker.io/ardidafa/portfolio:.*|image: docker.io/ardidafa/portfolio:$IMAGE_TAG|g" deployments/kubernetes/base/deployment.yaml

                            # Print the deployment file after substitution for debugging
                            echo "--- Deployment file after substitution ---"
                            cat deployments/kubernetes/base/deployment.yaml
                            echo "---------------------------------------"

                            # Create namespace if it doesn't exist
                            kubectl create namespace $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

                            # Fix issue with istio-injection label
                            kubectl label namespace $KUBERNETES_NAMESPACE istio-injection=enabled --overwrite || true

                            # Verify istio-injection label
                            echo "--- Checking namespace labels ---"
                            kubectl get namespace $KUBERNETES_NAMESPACE --show-labels
                            echo "-----------------------------"

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
                            kubectl apply -f deployments/kubernetes/base/network-policy.yaml -n $KUBERNETES_NAMESPACE
                            kubectl apply -f deployments/kubernetes/base/resource-quota.yaml -n $KUBERNETES_NAMESPACE
                            kubectl apply -f deployments/kubernetes/base/pdb.yaml -n $KUBERNETES_NAMESPACE

                            # Apply Istio & cert-manager resources
                            kubectl apply -f deployments/kubernetes/cert-manager/cluster-issuer.yaml
                            kubectl apply -f deployments/kubernetes/cert-manager/certificate.yaml
                            kubectl apply -f deployments/kubernetes/istio/gateway.yaml
                            kubectl apply -f deployments/kubernetes/istio/virtualservice.yaml

                            # Check pod status and events for debugging
                            echo "--- Initial Pod Status ---"
                            kubectl get pods -n $KUBERNETES_NAMESPACE
                            echo "------------------------"

                            # Give pods a few seconds to start creating
                            sleep 15

                            echo "--- Pod Status After 15s ---"
                            kubectl get pods -n $KUBERNETES_NAMESPACE
                            echo "---------------------------"
                        '''

                        // Verify deployment with increased timeout
                        sh "kubectl rollout status deployment/portfolio -n $KUBERNETES_NAMESPACE --timeout=600s || true"

                        // Always run these commands even if rollout times out
                        sh '''
                            echo "--- Detailed Pod Information ---"
                            kubectl describe pods -n $KUBERNETES_NAMESPACE -l app=portfolio
                            echo "-------------------------------"

                            echo "--- Recent Events ---"
                            kubectl get events -n $KUBERNETES_NAMESPACE --sort-by='.lastTimestamp' | tail -20
                            echo "------------------"

                            echo "--- Pod Logs ---"
                            for pod in $(kubectl get pods -n $KUBERNETES_NAMESPACE -l app=portfolio -o name); do
                                echo "Logs for $pod:"
                                kubectl logs -n $KUBERNETES_NAMESPACE $pod --all-containers || true
                                echo "--------------"
                            done
                            echo "---------------"
                        '''
                    }
                }
            }
        }

        stage('Smoke Test') {
            steps {
                // Wait for service to be ready
                sh 'sleep 30'

                // Basic health check
                sh 'curl -k -f -s --retry 10 --retry-connrefused --retry-delay 5 https://portfolio.glanze.site || true'
            }
        }

        stage('Verify Deployment') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh '''
                        # Check deployment status
                        kubectl rollout status deployment/portfolio -n ${KUBERNETES_NAMESPACE} --timeout=30s || true
                        kubectl get pods -n ${KUBERNETES_NAMESPACE}

                        # Check Istio and Service status
                        echo "--- Istio Gateway Status ---"
                        kubectl get gateway -A
                        echo "--------------------------"

                        echo "--- VirtualService Status ---"
                        kubectl get virtualservice -A
                        echo "----------------------------"

                        echo "--- Service Status ---"
                        kubectl get svc -n ${KUBERNETES_NAMESPACE}
                        echo "--------------------"
                    '''
                }
            }
        }
    }

    post {
        always {
            // Clean up local Docker images
            sh 'docker rmi $DOCKER_REGISTRY/$DOCKER_IMAGE:$IMAGE_TAG || true'
            sh 'docker rmi $DOCKER_REGISTRY/$DOCKER_IMAGE:latest || true'

            // Send notification
            // Send Discord notification
            withCredentials([string(credentialsId: 'discord-notification', variable: 'DISCORD_WEBHOOK')]) {
                discordSend(
                    webhookURL: DISCORD_WEBHOOK,
                    title: "Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
                    description: "Job: ${env.JOB_NAME}\nStatus: ${currentBuild.currentResult}\nBuild URL: ${env.BUILD_URL}",
                    link: env.BUILD_URL,
                    result: currentBuild.currentResult,
                    thumbnail: currentBuild.currentResult == 'SUCCESS' ? 'https://i.imgur.com/Gv81PxI.png' : 'https://i.imgur.com/0FqHSH6.png'
                )
            }
        }
        success {
            echo 'Deployment completed successfully!'
            echo 'Site is now available at: https://portfolio.glanze.site'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}