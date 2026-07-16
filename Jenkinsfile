pipeline {
    agent any

    tools {
        nodejs 'NodeJS-26' // This name must match the tool name in Jenkins
    }

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
            //steps{
			//	git branch: 'master',
			//		credentialsId: 'GitHub_Aurora',
			//		url: 'https://github.com/leymardyvain/aurora.git'
        	//}
    	}

		stage('Prérequis système') {
    		steps {
        		sh '''
            		if ! ldconfig -p | grep -q libatomic; then
                	sudo apt-get update && sudo apt-get install -y libatomic1
           			fi
        		'''
    		}
		}
		
        stage('Installation des dépendances') {
            steps {
                // Installe les paquets définis dans package.json
				// withEnv(["/usr/share/nodejs/"])
                sh 'npm install'
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
