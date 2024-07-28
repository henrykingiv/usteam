pipeline {
    agent any
    environment {
        NEXUS_USER = credentials('nexus-username')
        NEXUS_PASSWORD = credentials('nexus-password')
        NEXUS_REPO = credentials('nexus-repo')
        AWS_REGION = 'eu-west-2'
        ECR_REPO = 'ecr-repo-name'
        AWS_ACCOUNT_ID = '378652575940'
        URL_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }
    stages {
        stage('Code Analysis') { 
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }   
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        // stage('Dependency Check') {
        //     steps {
        //         dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }
        // stage('Test Code') {
        //     steps {
        //         sh 'mvn test -Dcheckstyle.skip'
        //     }
        // }
        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests -Dcheckstyle.skip'
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'ecr-demo-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // Login to ECR
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${URL_REGISTRY}"

                        // Build Docker image
                        sh "docker build -t $ECR_REPO ."

                        // Tag Docker image
                        sh "docker tag $ECR_REPO:latest ${URL_REGISTRY}/$ECR_REPO:latest"

                        // Push Docker image to ECR
                        sh "docker push ${URL_REGISTRY}/$ECR_REPO:latest"
                    }
                }
            }
        }
        stage('Push Artifact to Nexus Repo') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic',
                classifier: '',
                file: 'target/spring-petclinic-2.4.2.war',
                type: 'war']],
                credentialsId: 'nexus-creds',
                groupId: 'Petclinic',
                nexusUrl: 'nexus.henrykingroyal.co',
                nexusVersion: 'nexus3',
                protocol: 'https',
                repository: 'nexus-repo',
                version: '1.0'
            }
        }
        stage('Trivy fs Scan') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage('Trivy image Scan') {
            steps {
                sh "trivy image $NEXUS_REPO/petclinicapps > trivyfs.txt"
            }
        }
    }
}
    

