pipeline {
    agent any

    tools {
        maven 'Maven'
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
