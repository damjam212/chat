pipeline {
    agent any
    environment {
        ECR_REGISTRY = '035209886637.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO = 'dev/repo'
        IMAGE_TAG = 'latest'
        AWS_REGION = 'us-east-1'
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/damjam212/chat.git'
            }
        }
        stage('Change Directory') {
            steps {
                script {
                    dir('public') {
                        // Zmiana katalogu na 'public'
                        echo 'Changed directory to public'
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dir('public') {
                        // Budowanie obrazu Docker w katalogu 'public'
                        def image = docker.build("${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}")
                    }
                }
            }
        }
        stage('Login to ECR') {
            steps {
                script {
                    // Logowanie do ECR
                    withCredentials([usernamePassword(credentialsId: 'ecr-credentials-id', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                        def loginCommand = sh(script: "aws ecr get-login-password --region ${AWS_REGION}", returnStdout: true).trim()
                        sh "docker login -u AWS -p ${loginCommand} ${ECR_REGISTRY}"
                    }
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${ECR_REGISTRY}", 'ecr-credentials-id') {
                        docker.image("${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}").push("${IMAGE_TAG}")
                    }
                }
            }
        }
        stage('Deploy to ECS') {
            steps {
                script {
                    // Aktualizacja definicji zadania i wymuszenie nowego wdrożenia
                    sh """
                    aws ecs update-service --cluster devCluster --service task-service --force-new-deployment --region ${AWS_REGION}
                    """
                }
            }
        }
    }
}

