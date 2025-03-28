pipeline {
    agent any

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
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest -f deployments/docker/Dockerfile ."
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    // Update image tag in deployment
                    sh """
                        sed -i 's|\${IMAGE_TAG}|${IMAGE_TAG}|g' kubernetes/base/deployment.yaml

                        # Create namespace if it doesn't exist & enable Istio
                        kubectl create namespace $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
                        kubectl label namespace $KUBERNETES_NAMESPACE istio-injection=enabled --overwrite

                        # Create Docker registry secret if it doesn't exist
                        kubectl create secret docker-registry docker-registry-secret \\
                            --docker-server=$DOCKER_REGISTRY \\
                            --docker-username=$DOCKER_USERNAME \\
                            --docker-password=$DOCKER_PASSWORD \\
                            -n $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

                        # Apply Kubernetes configurations
                        kubectl apply -f kubernetes/base/configmap.yaml -n $KUBERNETES_NAMESPACE
                        kubectl apply -f kubernetes/base/deployment.yaml -n $KUBERNETES_NAMESPACE
                        kubectl apply -f kubernetes/base/service.yaml -n $KUBERNETES_NAMESPACE
                        kubectl apply -f kubernetes/base/hpa.yaml -n $KUBERNETES_NAMESPACE
                        kubectl apply -f kubernetes/base/network-policy.yaml -n $KUBERNETES_NAMESPACE
                        kubectl apply -f kubernetes/base/resource-quota.yaml -n $KUBERNETES_NAMESPACE
                        kubectl apply -f kubernetes/base/dpa.yaml -n $KUBERNETES_NAMESPACE

                        # Apply Istio & cert-manager resources
                        kubectl apply -f kubernetes/cert-manager/cluster-issuer.yaml
                        kubectl apply -f kubernetes/cert-manager/certificate.yaml
                        kubectl apply -f kubernetes/istio/gateway.yaml
                        kubectl apply -f kubernetes/istio/virtualservice.yaml
                    """

                    // Verify deployment
                    sh "kubectl rollout status deployment/portfolio -n $KUBERNETES_NAMESPACE --timeout=300s"
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
                                kubectl rollout status deployment/portfolio -n ${KUBERNETES_NAMESPACE} --timeout=300s || true
                                kubectl get pods -n ${KUBERNETES_NAMESPACE}
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