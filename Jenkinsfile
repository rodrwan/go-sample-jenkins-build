#!/usr/bin/env groovy

pipeline {
    environment{
        DOCKER_TAG = getDockerTag()
        APP_NAME = "webapp"
        ECRURL = "https://864798405299.dkr.ecr.sa-east-1.amazonaws.com"
        ECRCRED = "ecr:sa-east-1:registry-jenkins-user:/home/kube-user"
        REGISTRY_URL = "864798405299.dkr.ecr.sa-east-1.amazonaws.com/dale-repo"
        IMAGE = "webapp"
        LATEST = "${REGISTRY_URL}:${DOCKER_TAG}"
        TAG = "${IMAGE} ${LATEST}"
        AWS_INSTANCE_URL_WITH_DIRECTORY = "ec2-18-229-255-200.sa-east-1.compute.amazonaws.com"
    }
    agent any
    stages {
        stage('Docker') {
            steps{
                script {
                    node {
                        stage('Clone repository') {
                            checkout scm
                        }

                        stage('Build Docker image') {
                            echo "Building docker image..."

                            sh "docker build . -t ${IMAGE}"
                            sh "docker tag ${TAG}"
                        }

                        stage('Push image') {
                            withAWS(credentials: 'registry-jenkins-user') {
                                sh "eval \$(aws ecr get-login --no-include-email --region sa-east-1 | sed 's|https://||')"
                                docker.withRegistry(ECRURL, ECRCRED) {
                                    sh "docker push ${REGISTRY_URL}:${DOCKER_TAG}"
                                }
                            }

                        }
                    }
                }
            }
        }

        stage('update k8s build files'){
            steps{
                sh "chmod +x changeTag.sh"
                sh "./changeTag.sh ${DOCKER_TAG} ${REGISTRY_URL}"
            }
        }

        stage('Deploy to k8s'){
            steps{
                // withAWS(credentials: 'kube-user') {
                    sh "aws eks update-kubeconfig --name basic-cluster"
                    script {
                        try{
                            sh "kubectl apply -f ."
                        }catch(error){
                            sh "kubectl create -f ."
                        }
                    }
                // }
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