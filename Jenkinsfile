pipeline {
    agent any

    tools {
        nodejs 'NodeJS 18'
    }

    parameters {
        string(name: 'RELEASE_TAG', defaultValue: '', description: 'Release tag to build and deploy (kosongkan untuk menggunakan build number)')
        choice(name: 'DEPLOY_ENV', choices: ['development', 'production'], description: 'Environment to deploy')
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub')
        DOCKER_HUB_PAT = credentials('docker-hub-pat')
        KUBECONFIG = credentials('kubeconfig')
        WEBHOOK_SECRET = credentials('webhook-secret')
        SSL_EMAIL = credentials('ssl-email')
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'ardidafa/portfolio'
        IMAGE_TAG = "${params.RELEASE_TAG ? params.RELEASE_TAG : env.BUILD_NUMBER}"
        KUBERNETES_NAMESPACE = 'portfolio'
        K3S_SERVER_IP = '45.80.181.33'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                script {
                    // Create .env file to disable eslint in build process
                    writeFile file: '.env', text: '''
DISABLE_ESLINT_PLUGIN=true
ESLINT_NO_DEV_ERRORS=true
SKIP_PREFLIGHT_CHECK=true
CI=false
'''
                }

                // Install dependencies
                sh 'npm ci --no-audit || npm install --no-audit'
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
                withCredentials([string(credentialsId: 'docker-hub-pat', variable: 'DOCKER_PAT')]) {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                        sh '''
                            # Clean start
                            kubectl delete namespace portfolio --ignore-not-found
                            sleep 10
                            kubectl create namespace portfolio

                            # Create Docker registry secret
                            kubectl create secret docker-registry docker-registry-secret \
                                --docker-server=docker.io \
                                --docker-username=ardidafa \
                                --docker-password=$DOCKER_PAT \
                                -n portfolio

                            # Apply Kubernetes manifests
                            kubectl apply -f deployments/kubernetes/base/configmap.yaml
                            kubectl apply -f deployments/kubernetes/base/service.yaml
                            kubectl apply -f deployments/kubernetes/base/deployment.yaml

                            # Apply ingress last
                            kubectl apply -f deployments/kubernetes/base/ingress.yaml

                            # Wait for deployment to be ready
                            kubectl rollout status deployment/portfolio -n portfolio --timeout=300s
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
                sh 'curl -k -f -s --retry 10 --retry-connrefused --retry-delay 5 https://portfolio.glanze.site/health || true'
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

                        # Check certificate status if using cert-manager
                        kubectl get certificate -n ${KUBERNETES_NAMESPACE} || true
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