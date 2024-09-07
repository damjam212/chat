pipeline {
    agent any
    environment {
        ECR_REGISTRY = '035209886637.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO = 'dev/repo'
        IMAGE_TAG = 'latest'
        AWS_REGION = 'us-east-1'
        AWS_SESSION_TOKEN = 'IQoJb3JpZ2luX2VjEAUaCXVzLXdlc3QtMiJIMEYCIQCPa2tlfaysbVstxa6feLrbqcxLnfZbrl8TgPLEFTAU4wIhAKvUMR5BZaAMIhIN/YALWY3lXhQm0YFHLlg7ZyWXT65sKrUCCC4QABoMMDM1MjA5ODg2NjM3Igw5hISRFu1gfoq8PT4qkgK2K1r6O1okuABDqK82UjhAtlW3ObG3UWAbbRHq7Orv6/8L4gJYZBSbNHvaIPVS9LFMICeoj13bho+oKw5I5n2QUGMPtbyR7AAAa7jlFE6VWVT9huKc7Li7CRhQ38Q4wH3GRbLVaZofiOQBcmQVquLMa/Yx9q6M+df4E5MJeI8aPAshSyh8gZ34dVvoTZoGBRpZjd/BssHJnmxIrlEodqYwrTpNVWWAyb42CYVEv403Oodl2Vqy4YNAgkdxSm1Zad5/jgcPi/7BoNCcwZIiKLZZiDkC8TAgS0vtrCplFhL4XnxM726KdfrBNVbdWm6qu4AuniBN/21E6AEXTDUuMXJ6WljlYG1zcfhy+jDXozP702hOMNuk8bYGOpwB9bcK6bvps+KIP4R2lVPHWM9aSyExd3iQFeQ8YxN5R/pXxLiNjRrD6q3HJF6O2a3yHZC2xUiMrCucy0F6hASieGyJnbH2G19Jf78kACG58/BVPTLHqVhn+naDLf8K4988ut+Q44TI3IURzurlK7qMQb8xvsbcpzNTUQ9PHUEg/S9fCNsjIJqgVqPrM8UTBuNy/lSfZY+gy8Kitp5c' 
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/damjam212/chat.git'
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
        stage('Debug AWS Credentials') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-key']]) {
                        sh 'cat ~/.aws/credentials'
                        sh 'echo AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID'
                        sh 'echo AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY'
                    }
                }
            }
        }
        stage('Login to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-key']]) {
                        // Wyświetlenie zmiennych środowiskowych
                        sh 'env'
                        // Sprawdzenie tożsamości
                        sh 'aws sts get-caller-identity --aws-session-token IQoJb3JpZ2luX2VjEAUaCXVzLXdlc3QtMiJIMEYCIQCPa2tlfaysbVstxa6feLrbqcxLnfZbrl8TgPLEFTAU4wIhAKvUMR5BZaAMIhIN'
                    }
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    // Użycie poświadczeń AWS do wypchnięcia obrazu do ECR
                    docker.withRegistry("https://${ECR_REGISTRY}", 'aws-key') {
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
