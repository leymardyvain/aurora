pipeline {
    agent any

    environment {
        // Replace with your actual Docker Hub or private registry username/repository
        REGISTRY_IMAGE = 'yleymard/aurora'
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls code from the git repository automatically
                cleanWs()
                checkout scm
            }
        }

        stage('Install & Test') {
            agent {
                // Executes inside a Node container so you don't need Node installed on the Jenkins agent
                image 'node:20-alpine'
            }
            steps {
                // Install clean dependencies and run unit tests
                sh 'npm ci'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Builds the image and tags it with the build number and 'latest'
                    dockerImage = docker.build("${REGISTRY_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    // Authenticates using credentials safely configured inside Jenkins
                    docker.withRegistry('', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        
        stage('Clean Up') {
            steps {
                // Removes local images from the host machine to save disk space
                sh "docker rmi ${REGISTRY_IMAGE}:${IMAGE_TAG}"
                sh "docker rmi ${REGISTRY_IMAGE}:latest"
            }
        }
    }

    post {
        always {
            // Cleans workspace directory after the build concludes
            cleanWs()
        }
        failure {
            echo "Pipeline failed. Check build logs for troubleshooting."
        }
    }
}
