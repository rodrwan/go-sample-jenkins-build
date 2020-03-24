#!/usr/bin/env groovy

pipeline {
    agent any
    environment{
        DOCKER_TAG = getDockerTag()
        APP_NAME = "webapp"
        ECRURL = "https://864798405299.dkr.ecr.sa-east-1.amazonaws.com"
        ECRCRED = "ecr:sa-east-1:registry-jenkins-user"
        REGISTRY_URL = "864798405299.dkr.ecr.sa-east-1.amazonaws.com/dale-repo"
        IMAGE = "${REGISTRY_URL}/go-sample-jenkins-build:${DOCKER_TAG}"
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'golang'
                }
            }
            steps {
                // def dockerTool = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
                // withEnv(["DOCKER=${dockerTool}/bin"]) {
                    //stages
                    //now we can simply call: dockerCmd 'run mycontainer'

                    // Create our project directory.
                    sh 'cd ${GOPATH}/src'
                    sh 'mkdir -p ${GOPATH}/src/hello-world'
                    // Copy all files in our Jenkins workspace to our project directory.
                    sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
                    // Build the app.
                    sh 'go build -o webapp'
                // }
            }
        }

        stage('Docker') {
            // environment {
                // Extract the username and password of our credentials into "DOCKER_CREDENTIALS_USR" and "DOCKER_CREDENTIALS_PSW".
                // (NOTE 1: DOCKER_CREDENTIALS will be set to "your_username:your_password".)
                // The new variables will always be YOUR_VARIABLE_NAME + _USR and _PSW.
                // (NOTE 2: You can't print credentials in the pipeline for security reasons.)
                // DOCKER_CREDENTIALS = credentials('my-docker-credentials-id')
            // }

            steps{
                // Use a scripted pipeline.
                script {
                    node {
                        def app

                        stage('Clone repository') {
                            checkout scm
                        }

                        stage(' image') {
                            echo "Building docker image..."

                            // app = docker.build("")
                        }

                        stage('Build and Push image') {
                            script {
                                def imageID = sh script: "\$(docker build . -q -t ${IMAGE}  2>/dev/null | awk '/Successfully built/{print $NF}'", returnStdout: true
                                echo "${imageID}"
                                sh("eval \$(aws ecr get-login --no-include-email | sed 's|https://||')")
                                echo "docker tag ${IMAGE} ${IMAGE}"
                                sh "docker tag ${IMAGE} ${IMAGE}"
                                docker.withRegistry(ECRURL, ECRCRED) {
                                    echo "docker push ${IMAGE}"
                                    sh "docker push ${IMAGE}"
                                //     docker.image(IMAGE).push()
                                }
                            }
                        }
                    }
                }
            }
        }

        // stage('Deploy to k8s'){
        //     steps{
        //         sh "chmod +x changeTag.sh"
        //         sg "./changeTag.sh ${DOCKER_TAG} ${REGISTRY_URL}"
        //         sshagent(['']){
        //             sh "scp -o StrictHostKeyChecking=no service.yaml app.yaml ${AWS_INSTANCE_URL_WITH_DIRECTORY}"
        //             script {
        //                 try{
        //                     sh "ssh ${AWS_INSTANCE_URL} kubectl apply -f ."
        //                 }catch(error){
        //                     sh "ssh ${AWS_INSTANCE_DIRECTORY} kubectl create -f ."
        //                 }
        //             }
        //         }
        //     }
        // }
    }

    post
    {
        always
        {
            sh "docker image prune -fa"
            // deleteDir()
        }
    }
}

def getDockerTag() {
    def tag = sh script: 'git rev-parse HEAD', returnStdout: true
    return tag
}