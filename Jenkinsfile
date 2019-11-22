pipeline {
    agent any

    environment {
        ENVIRONMENT_NAME = "${env.ENVIRONMENT_NAME}"
        NEW_IMAGE_NAME = "gateway"
        NEW_IMAGE_TAG = "${BUILD_NUMBER}"
        CURRENT_IMAGE_NAME = "${NEW_IMAGE_NAME}-${NEW_IMAGE_ENVIRONMENT}"
        BLAZE_CT_TEST_HOOK = "${env.BLAZE_CT_TEST_HOOK}" 
    }

     stages {
    //     stage('Gradle Preparation & Build') {
    //         steps {
    //             sh '''./gradlew clean
    //                     ./gradlew build'''

    //         }
    //     }
    //     stage('Build Image with Docker') {
    //         steps {
    //             sh """./gradlew -DimageName=${env.CURRENT_IMAGE_NAME} -DimageTag=${env.NEW_IMAGE_TAG} buildDockerImage"""
    //         }
    //     }
	//    stage('Login Docker, Tag and push docker image to Docker Registry') {
    //         steps {
	// 	        sh """docker login ${env.NEW_IMAGE_REGISTRY_HOSTNAME} -u ${params.NEW_IMAGE_REGISTRY_USER} --password ${params.NEW_IMAGE_REGISTRY_PASSWORD}
    //                  docker tag ${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG} ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
	// 		         docker push ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
	// 		         docker inspect ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}"""
    //         }
    //     }
        stage('Blaze CT Functional Test') {
            environment {
                 def get = new URL("${env.BLAZE_CT_TEST_HOOK}").openConnection();
                 def getRC = get.getResponseCode();
             }
            steps {
                 script {
                    if(getRC == '200') {
                       println("success status: " + getRC);
                       println(get.getData());
                    }else{
                       println("failed status: " + getRC)
                       println(get.getInputStream().getText())
                    }
                 }
                
                
                
            }
        }

    }
}