pipeline {
    agent any
    environment{
        DOCKER_TAG = getDockerTag()
        APP_NAME = "webapp"
        ECRURL = "https://864798405299.dkr.ecr.sa-east-1.amazonaws.com"
        ECRCRED = "ecr:sa-east-1:registry-jenkins-user"
        IMAGE = "${REGISTRY_URL}/go-sample-jenkins-build:${DOCKER_TAG}"
    }
    stages {
        stage('Build application'){
            // Install the desired Go version
            def root = tool name: 'Go 1.8', type: 'go'

            // Export environment variables pointing to the directory where Go was installed
            withEnv(["GOROOT=${root}", "PATH+GO=${root}/bin"]) {
                sh "go version"
                sh "go build -o ${APP_NAME}"
            }
        }
        stage('Build Docker Image'){
            steps{
                sh "docker build -t ${IMAGE} ."
            }
        }
        stage('Registry push'){
            docker.withRegistry(ECRURL, ECRCRED) {
                docker.image("${REGISTRY_URL}/go-sample-jenkins-build:${DOCKER_TAG}").push()
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