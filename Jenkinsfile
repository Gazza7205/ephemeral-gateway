pipeline {
    agent any

    environment {
        NEW_IMAGE_ENVIRONMENT = "test"
        NEW_IMAGE_NAME = "gateway"
        NEW_IMAGE_TAG = "${BUILD_NUMBER}"
        CURRENT_IMAGE_NAME = "${NEW_IMAGE_NAME}-${NEW_IMAGE_ENVIRONMENT}"
    }

    stages {
        stage('Gradle Preparation & Build') {
            steps {
                sh '''./gradlew clean
                        ./gradlew build'''

            }
        }
        stage('Build Image with Docker') {
            steps {
                sh """./gradlew -DimageName=${env.NEW_IMAGE_NAME} -DimageTag=${env.NEW_IMAGE_TAG} buildDockerImage"""
            }
        }
	   stage('Login Docker, Tag and push docker image to Docker Registry') {
            steps {
		        sh """docker login ${env.NEW_IMAGE_REGISTRY_HOSTNAME} -u ${params.NEW_IMAGE_REGISTRY_USER} --password ${params.NEW_IMAGE_REGISTRY_PASSWORD}
                     docker tag ${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG} ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker push ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker inspect ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG}"""
            }
        }
        stage('Force sync flux sync') {
            steps {
                sh "fluxctl identity --k8s-fwd-ns flux"
            }
        }
    }
}