#!/usr/bin/env groovy

pipeline {
    environment{
        DOCKER_TAG = getDockerTag()
        APP_NAME = "webapp"
        ECRURL = "https://864798405299.dkr.ecr.sa-east-1.amazonaws.com"
        ECRCRED = "ecr:sa-east-1:registry-jenkins-user"
        REGISTRY_URL = "864798405299.dkr.ecr.sa-east-1.amazonaws.com/dale-repo"
        IMAGE = "${REGISTRY_URL}/go-sample-jenkins-build:${DOCKER_TAG}"
        LATEST = "${REGISTRY_URL}:latest"
        TAG = "${IMAGE} ${LATEST}"
    }
    agent any
    stages {
        // stage('Build') {
        //     agent {
        //         docker {
        //             image 'golang:alpine'
        //         }
        //     }
        //     steps {
        //         // def dockerTool = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
        //         // withEnv(["DOCKER=${dockerTool}/bin"]) {
        //             //stages
        //             //now we can simply call: dockerCmd 'run mycontainer'

        //             // Create our project directory.
        //             sh 'cd ${GOPATH}/src'
        //             sh 'mkdir -p ${GOPATH}/src/hello-world'
        //             // Copy all files in our Jenkins workspace to our project directory.
        //             sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
        //             // Build the app.
        //             sh 'go build -o webapp'
        //         // }
        //     }
        // }

        stage('Docker') {
            steps{
                script {
                    node {
                        stage('Clone repository') {
                            checkout scm
                        }

                        stage('Build and Push image') {
                            withAWS(credentials: 'registry-jenkins-user') {
                                echo "Building docker image..."

                                sh "docker build . -t ${IMAGE}"
                                echo "docker build . -t ${IMAGE}"
                                sh "eval \$(aws ecr get-login --no-include-email --region sa-east-1 | sed 's|https://||')"

                                echo "docker tag ${TAG}"
                                sh "docker tag ${TAG}"

                                docker.withRegistry(ECRURL, ECRCRED) {
                                    echo "docker push ${REGISTRY_URL}:${DOCKER_TAG}"
                                    sh "docker push ${REGISTRY_URL}:${DOCKER_TAG}"
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
    def tag = sh script: "git rev-parse HEAD | tr -d '\n'" , returnStdout: true
    return tag
}