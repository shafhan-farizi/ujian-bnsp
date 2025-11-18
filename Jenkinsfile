pipeline {
    agent any

    environment {
        IMAGE_NAME = 'shafhan/app-py'
        IMAGE_TAG = 'latest'

        // EC2 Conf
        EC2_USER = 'ec2-user'
        IP_EC2 = '44.221.83.223'
    }

    stages {
        stage('Build Image') {
            steps {
                echo 'Memasuki proses Build Image...'
                
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                
                echo 'Image berhasil dibuat'
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Memasuki proses Push Image ke Docker Hub...'

                withCredentials([usernamePassword(
                    credentialsId: 'docker-id',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    echo 'Login Docker...'
                    sh 'echo $PASS | docker login -u $USER --password-stdin'

                    echo 'Push image ke Docker Hub...'
                    sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'

                    echo 'Image berhasil dipush ke Docker Hub' 
                }
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-id']) {
                    sh """
                        ssh -o StrictHostkeyChecking=no ${EC2_USER}@${IP_EC2} <<-EOF
                            echo 'Menghapus Image lama...'
                            docker ps -q --filter ancestor=${IMAGE_NAME}:${IMAGE_TAG} | xargs -r docker stop
                            docker ps -aq --filter ancestor=${IMAGE_NAME}:${IMAGE_TAG} | xargs -r docker rm

                            docker image prune -f
                            echo 'Image lama berhasil dihapus'

                            echo 'Pull Image dari Docker Hub...'
                            docker pull ${IMAGE_NAME}:${IMAGE_TAG}
                            echo 'Image versi terbaru berhasil ditarik'

                            echo 'Memulai ulang docker...'
                            docker run -d --name flask-app -p 80:5152 ${IMAGE_NAME}:${IMAGE_TAG}
                            echo 'Berhasil memulai ulang docker'
                    """
                }
            }
        }
    }
}
