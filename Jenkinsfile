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

    tools { docker "mydocker"}
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'golang'
                }
            }
            steps {
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
                // Build the app.
                sh 'go build -o webapp'
            }
        }

        stage('Build Docker Image'){
            steps{
                sh "docker build -t ${IMAGE} ."
            }
        }

        stage('Registry push'){
            steps{
                script{
                    docker.withRegistry(ECRURL, ECRCRED) {
                        docker.image("${REGISTRY_URL}/webapp:${DOCKER_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to k8s'){
            steps{
                sh "chmod +x changeTag.sh"
                sg "./changeTag.sh ${DOCKER_TAG} ${REGISTRY_URL}"
                sshagent(['']){
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
            // make sure that the Docker image is removed
            sh "docker rmi ${REGISTRY_URL}/go-sample-jenkins-build:${DOCKER_TAG} | true"
        }
    }
}

def getDockerTag() {
    def tag = sh script: 'git rev-parse HEAD', returnStdout: true
    return tag
}