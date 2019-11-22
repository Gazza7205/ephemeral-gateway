import groovy.json.JsonSlurperClassic

pipeline {
    agent any
    environment {
        ENVIRONMENT_NAME = "${env.ENVIRONMENT_NAME}"
        NEW_IMAGE_NAME = "gateway"
        NEW_IMAGE_TAG = "${BUILD_NUMBER}"
        CURRENT_IMAGE_NAME = "${NEW_IMAGE_NAME}-${NEW_IMAGE_ENVIRONMENT}"
        BLAZE_CT_TEST_HOOK = "${env.BLAZE_CT_TEST_HOOK}"
        BLAZE_CT_AUTH_TOKEN = "${env.BLAZE_CT_AUTH_TOKEN}"
        rsResultAPI = ""
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
                sh """./gradlew -DimageName=${env.CURRENT_IMAGE_NAME} -DimageTag=${env.NEW_IMAGE_TAG} buildDockerImage"""
            }
        }
	   stage('Login Docker, Tag and push docker image to Docker Registry') {
            steps {
		        sh """docker login ${env.NEW_IMAGE_REGISTRY_HOSTNAME} -u ${params.NEW_IMAGE_REGISTRY_USER} --password ${params.NEW_IMAGE_REGISTRY_PASSWORD}
                     docker tag ${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG} ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker push ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker inspect ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}"""
            }
        }

       stage('Wait for WeaveFlux to apply the update.'){
           sleep 180
       }
        stage('Blaze CT Functional Test') {
            steps {
                 script {
                     def jsonSlurper = new JsonSlurperClassic();
                     res = restCall("GET", "${env.BLAZE_CT_TEST_HOOK}", "")
                     rsRes = jsonSlurper.parseText(res)
                     rsResultAPI = rsRes.data.runs[0].api_test_run_url // [0]["api_test_run_url"];
                     println(rsResultAPI)
                 }
                 
            }
            }
        stage('Wait for release to be applied'){
            steps {
               sleep(30)
            }

        }
    stage('Validate results'){
            steps {
               script{
                     def jsonSlurper = new JsonSlurperClassic();
                     res = restCall("GET", "${rsResultAPI}", "${env.BLAZE_CT_AUTH_TOKEN}");
                     rsRes = jsonSlurper.parseText(res)
                     if(rsRes.data.assertions_defined == rsRes.data.assertions_passed){
                         println("functional tests have passed!")
                     }else{
                         println("functional tests have failed! Rolling back to last successful release..")
                     }
                     //println(rsRes);
               }
            }

        }

        }

    }

def blockThread() {
    println("Waiting for results...")
    sleep(30)
    println("Finished waiting...")
    return "Finished";
}

def restCall(String method, String Url, String authToken) {
    def URL url = new URL(Url)
    def HttpURLConnection connection = url.openConnection()
    if(authToken != ""){
       connection.setRequestProperty("Authorization", "Bearer " + authToken);
    }
    
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
    return text
}