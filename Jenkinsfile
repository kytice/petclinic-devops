pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
            SONAR_ORG = 'kytice'
            SONAR_PROJECT_KEY = 'kytice_petclinic-devops'
            DOCKER_IMAGE = 'kytice/petclinic'
            DOCKER_TAG = "${env.BUILD_NUMBER}"
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
                          -Dsonar.token=${SONAR_TOKEN} \
                          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    """
                }
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker buildx build --platform linux/amd64 \
                          -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                          -t ${DOCKER_IMAGE}:latest \
                          --push .
                    """
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                sshagent(['aws-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@108.130.73.98 \
                        'docker pull kytice/petclinic:latest && \
                         docker stop petclinic-app; \
                         docker rm petclinic-app; \
                         docker run -d --name petclinic-app -p 8080:8080 --network monitoring kytice/petclinic:latest'
                    """
                }
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
