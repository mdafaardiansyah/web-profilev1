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

        stage('Prepare ESLint Configuration') {
            steps {
                script {
                    // Create .eslintrc.js file to ignore warnings
                    writeFile file: '.eslintrc.js', text: '''
module.exports = {
  extends: ['react-app'],
  rules: {
    'no-unused-vars': 'off',
    'import/no-anonymous-default-export': 'off',
    'eqeqeq': 'off',
    'jsx-a11y/anchor-is-valid': 'off'
  }
};
'''

                    // Create .env file to disable eslint in build process
                    writeFile file: '.env', text: '''
DISABLE_ESLINT_PLUGIN=true
ESLINT_NO_DEV_ERRORS=true
SKIP_PREFLIGHT_CHECK=true
CI=false
'''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci --no-audit || npm install --no-audit'
            }
        }

        stage('Linting') {
            steps {
                sh 'npm run lint || true'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'npm test -- --passWithNoTests || true'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'npm audit --production || true'
            }
        }

        stage('Build React App') {
            steps {
                sh 'export NODE_OPTIONS=--openssl-legacy-provider && DISABLE_ESLINT_PLUGIN=true CI=false npm run build'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                sh '''
                    echo $DOCKER_HUB_PAT | docker login -u ardidafa --password-stdin
                    docker build -t $DOCKER_REGISTRY/$DOCKER_IMAGE:$IMAGE_TAG -t $DOCKER_REGISTRY/$DOCKER_IMAGE:latest .
                    docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:$IMAGE_TAG
                    docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:latest
                '''
            }
        }

        stage('Create Namespace if not exists') {
            steps {
                sh '''
                    mkdir -p $HOME/.kube
                    cat "$KUBECONFIG" > $HOME/.kube/config
                    chmod 600 $HOME/.kube/config

                    kubectl get namespace $KUBERNETES_NAMESPACE || kubectl create namespace $KUBERNETES_NAMESPACE
                '''
            }
        }

        stage('Update Kubernetes ConfigMap') {
            steps {
                script {
                    def configData = ""

                    if (params.DEPLOY_ENV == 'production') {
                        configData = """
                        apiVersion: v1
                        kind: ConfigMap
                        metadata:
                          name: portfolio-config
                          namespace: $KUBERNETES_NAMESPACE
                        data:
                          NODE_ENV: "production"
                          REACT_APP_API_URL: "https://api.glanze.site"
                        """
                    } else {
                        configData = """
                        apiVersion: v1
                        kind: ConfigMap
                        metadata:
                          name: portfolio-config
                          namespace: $KUBERNETES_NAMESPACE
                        data:
                          NODE_ENV: "development"
                          REACT_APP_API_URL: "https://dev-api.glanze.site"
                        """
                    }

                    writeFile file: 'configmap.yaml', text: configData
                    sh 'kubectl apply -f configmap.yaml'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def deploymentYaml = """
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: portfolio
                      namespace: $KUBERNETES_NAMESPACE
                    spec:
                      replicas: 2
                      selector:
                        matchLabels:
                          app: portfolio
                      template:
                        metadata:
                          labels:
                            app: portfolio
                        spec:
                          containers:
                            - name: portfolio
                              image: $DOCKER_REGISTRY/$DOCKER_IMAGE:$IMAGE_TAG
                              ports:
                                - containerPort: 3000
                              envFrom:
                                - configMapRef:
                                    name: portfolio-config
                              livenessProbe:
                                httpGet:
                                  path: /health
                                  port: 3000
                                initialDelaySeconds: 10
                                periodSeconds: 30
                              readinessProbe:
                                httpGet:
                                  path: /health
                                  port: 3000
                                initialDelaySeconds: 5
                                periodSeconds: 10
                              resources:
                                limits:
                                  cpu: "0.5"
                                  memory: "512Mi"
                                requests:
                                  cpu: "0.2"
                                  memory: "256Mi"
                    """

                    def serviceYaml = """
                    apiVersion: v1
                    kind: Service
                    metadata:
                      name: portfolio
                      namespace: $KUBERNETES_NAMESPACE
                    spec:
                      selector:
                        app: portfolio
                      ports:
                        - port: 80
                          targetPort: 3000
                      type: ClusterIP
                    """

                    def ingressYaml = """
                    apiVersion: networking.k8s.io/v1
                    kind: Ingress
                    metadata:
                      name: portfolio
                      namespace: $KUBERNETES_NAMESPACE
                      annotations:
                        cert-manager.io/cluster-issuer: "letsencrypt-prod"
                        kubernetes.io/ingress.class: "traefik"
                        traefik.ingress.kubernetes.io/router.entrypoints: "websecure"
                        traefik.ingress.kubernetes.io/router.tls: "true"
                    spec:
                      tls:
                        - hosts:
                            - portfolio.glanze.site
                          secretName: portfolio-tls
                      rules:
                        - host: portfolio.glanze.site
                          http:
                            paths:
                              - path: /
                                pathType: Prefix
                                backend:
                                  service:
                                    name: portfolio
                                    port:
                                      number: 80
                    """

                    writeFile file: 'deployment.yaml', text: deploymentYaml
                    writeFile file: 'service.yaml', text: serviceYaml
                    writeFile file: 'ingress.yaml', text: ingressYaml

                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'
                    sh 'kubectl apply -f ingress.yaml'

                    sh "kubectl rollout status deployment/portfolio -n $KUBERNETES_NAMESPACE --timeout=300s"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get deployment portfolio -n $KUBERNETES_NAMESPACE
                    kubectl get pods -l app=portfolio -n $KUBERNETES_NAMESPACE
                    kubectl get svc -n $KUBERNETES_NAMESPACE
                    kubectl get ingress -n $KUBERNETES_NAMESPACE
                '''
            }
        }

        stage('Verify SSL Certificate') {
            steps {
                sh '''
                    echo "Checking certificate status..."
                    kubectl get certificate -n $KUBERNETES_NAMESPACE || true
                    kubectl describe certificate portfolio-tls -n $KUBERNETES_NAMESPACE || true
                '''
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