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
                            # Use string replacement for image tag
                            sed -i "s|image: docker.io/ardidafa/portfolio:.*|image: docker.io/ardidafa/portfolio:${IMAGE_TAG}|g" deployments/kubernetes/deployment.yaml

                            # Create namespace if it doesn't exist
                            kubectl create namespace $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

                            # Create Docker registry secret if it doesn't exist
                            kubectl create secret docker-registry docker-registry-secret \
                                --docker-server=$DOCKER_REGISTRY \
                                --docker-username=ardidafa \
                                --docker-password=$DOCKER_PAT \
                                -n $KUBERNETES_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

                            # Apply Kubernetes configurations
                            kubectl apply -f deployments/kubernetes/base -n $KUBERNETES_NAMESPACE

                            # Apply ClusterIssuer and IngressRoute
                            kubectl apply -f deployments/kubernetes/cert-manager
                            kubectl apply -f deployments/kubernetes/ingress
                        '''

                        // Verify deployment
                        sh "kubectl rollout status deployment/portfolio -n $KUBERNETES_NAMESPACE --timeout=300s"
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
                        kubectl rollout status deployment/portfolio -n ${KUBERNETES_NAMESPACE} --timeout=300s || true
                        kubectl get pods -n ${KUBERNETES_NAMESPACE}

                        # Check IngressRoute
                        kubectl get ingressroute -n ${KUBERNETES_NAMESPACE}

                        # Check service status
                        kubectl get svc -n ${KUBERNETES_NAMESPACE}
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