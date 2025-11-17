pipeline {
    agent any

    environment {
        IMAGE_NAME = 'shafhan/app-py'
        IMAGE_TAG = 'latest'

        // DOCKER_Conf
        DOCKER_USER = 'shafhan'
        
        // EC2 Conf
        EC2_USER = 'ec2-user'
        IP_EC2 = '44.221.83.223'
    }

    stages {
        // stage('Build Image') {
        //     steps {
        //         echo 'Memasuki proses Build Image...'
                
        //         sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                
        //         echo 'Image berhasil dibuat'
        //     }
        // }

        // stage('Push Image to Docker Hub') {
        //     steps {
        //         echo 'Memasuki proses Push Image ke Docker Hub...'

        //         withCredentials([usernamePassword(
        //             credentialsId: 'docker-id',
        //             usernameVariable: 'USER',
        //             passwordVariable: 'PASS'
        //         )]) {
        //             echo 'Login Docker...'
        //             sh "echo ${PASS} | docker login -u ${DOCKER_USER} --password-stdin"

        //             echo 'Push image ke Docker Hub...'
        //             sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"

        //             echo 'Image berhasil dipush ke Docker Hub' 
        //         }
        //     }
        // }
        
        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-id']) {
                    sh """
                        ssh -o StrictHostkeyChecking=no ${EC2_USER}@${IP_EC2} <<-EOF
                            docker stop \$(docker ps -q --filter ancestor=${IMAGE_NAME}:${IMAGE_TAG})
                            docker rm \$(docker ps -aq --filter ancestor=${IMAGE_NAME}:${IMAGE_TAG})

                            docker image prune -f

                            docker pull ${IMAGE_NAME}:${IMAGE_TAG}

                            docker run -d --name flask-app -p 80:5152 ${IMAGE_NAME}:${IMAGE_TAG} EOF
                    """
                }
            }
        }
    }
}
