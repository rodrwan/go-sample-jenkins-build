#!/usr/bin/env groovy

pipeline {
    environment{
        DOCKER_TAG = getDockerTag()
        APP_NAME = "webapp"
        ECRURL = "https://864798405299.dkr.ecr.sa-east-1.amazonaws.com"
        ECRCRED = "ecr:sa-east-1:registry-jenkins-user"
        REGISTRY_URL = "864798405299.dkr.ecr.sa-east-1.amazonaws.com/dale-repo"
        IMAGE = "webapp"
        LATEST = "${REGISTRY_URL}:${DOCKER_TAG}"
        TAG = "${IMAGE} ${LATEST}"
    }
    agent any
    stages {
        // stage('Docker') {
        //     steps{
        //         script {
        //             node {
        //                 stage('Clone repository') {
        //                     checkout scm
        //                 }

        //                 stage('Build and Push image') {
        //                     withAWS(credentials: 'registry-jenkins-user') {
        //                         echo "Building docker image..."

        //                         sh "docker build . -t ${IMAGE}"
        //                         sh "eval \$(aws ecr get-login --no-include-email --region sa-east-1 | sed 's|https://||')"

        //                         sh "docker tag ${TAG}"

        //                         docker.withRegistry(ECRURL, ECRCRED) {
        //                             sh "docker push ${REGISTRY_URL}:${DOCKER_TAG}"
        //                         }
        //                     }

        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Deploy to k8s'){
            steps{
                sh "chmod +x changeTag.sh"
                sh "./changeTag.sh ${DOCKER_TAG} ${REGISTRY_URL}"

                sshagent(credentials: ['kube-user']){
                    sh "scp -o StrictHostKeyChecking=no service.yaml app.yaml ${AWS_INSTANCE_URL_WITH_DIRECTORY}"
                    script {
                        try{
                            sh "ssh ${AWS_INSTANCE_URL} kubectl apply -f ."
                        }catch(error){
                            sh "ssh ${AWS_INSTANCE_DIRECTORY} kubectl create -f ."
                        }
                    }
                }
            }
        }
    }

    post
    {
        always
        {
            sh "docker image prune -fa"
            deleteDir()
        }
    }
}

def getDockerTag() {
    def tag = sh script: "git rev-parse HEAD | tr -d '\n'" , returnStdout: true
    return tag
}