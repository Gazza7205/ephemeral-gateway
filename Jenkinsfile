pipeline {
    agent any
    environment {
        ENVIRONMENT_NAME = "${env.ENVIRONMENT_NAME}"
        NEW_IMAGE_NAME = "gateway"
        NEW_IMAGE_TAG = "${BUILD_NUMBER}"
        CURRENT_IMAGE_NAME = "${NEW_IMAGE_NAME}-${NEW_IMAGE_ENVIRONMENT}"
        BLAZE_CT_TEST_HOOK = "${env.BLAZE_CT_TEST_HOOK}&token=237b6558-e262-4fab-b457-21189f607a5c"
        BLAZE_CT_AUTH_TOKEN = "e7ee3b4f-e07f-4d47-9189-b841cef7a483"
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
            steps {
                 script {
                     restCall("GET", "${env.BLAZE_CT_AUTH_TOKEN}")
                    // if(getRC == '201') {
                    //    println("success status: " + getRC);
                    //    println(getText);
                    // }else{
                    //    println("failed status: " + getRC)
                    //    println(getText);
                    // }
                    // get = null;
                 }
            }
            }
        }

    }
    
def restCall(String method, String authToken) {
    def URL url = new URL("${env.BLAZE_CT_TEST_HOOK}")
    def HttpURLConnection connection = url.openConnection()

    connection.setRequestProperty("Authorization", "Bearer " + authToken);
    connection.setRequestMethod(method)
    connection.doOutput = true

    connection.connect();

    def statusCode =  connection.responseCode
    if (statusCode != 200 && statusCode != 201) {
        String text = connection.getErrorStream().text
        connection = null
        throw new Exception(text)
    }

    String text = connection.content.text
    connection = null
}