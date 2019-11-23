import groovy.json.JsonSlurperClassic

pipeline {
    agent any
    environment {
        ENVIRONMENT_NAME = "${env.ENVIRONMENT_NAME}"
        NEW_IMAGE_NAME = "gateway"
        NEW_IMAGE_TAG = "${BUILD_NUMBER}"
        CURRENT_IMAGE_NAME = "${NEW_IMAGE_NAME}-${ENVIRONMENT_NAME}"
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
                //sh """./gradlew -DimageName=${env.CURRENT_IMAGE_NAME} -DimageTag=${env.NEW_IMAGE_TAG} -DbuildArgs=mapOf(build_number to ${BUILD_NUMBER}) > buildDockerImage"""
                sh """docker build -t ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}  --build-arg BUILD_NUMBER="${NEW_IMAGE_TAG}" ."""
            }
        }
	   stage('Login Docker, Tag and push docker image to Docker Registry') {
            steps {
		        sh """docker login ${env.NEW_IMAGE_REGISTRY_HOSTNAME} -u ${params.NEW_IMAGE_REGISTRY_USER} --password ${params.NEW_IMAGE_REGISTRY_PASSWORD}
                     docker tag ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG} ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker push ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker inspect ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}"""
            }
        }

       stage('Wait for WeaveFlux to apply the update.'){
           steps{
               sleep 180
           }
           
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
        stage('Wait for functional test to complete'){
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
                         println("functional tests have passed!");
                         println("Confirming tests run against correct version");
                         //validate test run against this build...
                         if(rsRes.data.requests[2].assertions[1].actual_value == "${BUILD_NUMBER}"){
                            println("Test executed against old version... probably retrigger... doing nothing for now");
                            println("Actual Build: " + rsRes.data.requests[2].assertions[1].actual_value + "Expected: " + "${BUILD_NUMBER}")
                         }
                         
                         //ready to continue...
                     }else{
                         //There was error - drop the image and fail the pipeline.. this should cause Weave to revert to
                         //last successful build
                         sh """docker rmi ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/${env.CURRENT_IMAGE_NAME}:${env.NEW_IMAGE_TAG}"""
                         error("functional tests have failed! Rolling back to last successful release..")
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