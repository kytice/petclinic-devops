pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
            SONAR_ORG = 'kytice'
            SONAR_PROJECT_KEY = 'kytice_petclinic-devops'
        }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/kytice/petclinic-devops.git'
            }
        }

        stage('Build') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }

        stage('Code Quality') {
            steps {
                withCredentials([string(credentialsId: 'sonarcloud-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                        ./mvnw sonar:sonar \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.organization=${SONAR_ORG} \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.token=${SONAR_TOKEN}
                        """
                }
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Deploy') {
            steps {
                sh 'nohup java -jar target/*.jar --server.port=9090 &'
                sh 'sleep 30'
                sh 'curl -f http://localhost:9090 || exit 1'
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
        success {
            slackSend color: 'good',
                message: "Build #${env.BUILD_NUMBER} passed - ${env.JOB_NAME}"
        }
        failure {
            slackSend color: 'danger',
                message: "Build #${env.BUILD_NUMBER} failed - ${env.JOB_NAME}"
        }
    }
}
