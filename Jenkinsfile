pipeline {
    agent any
    environment{
        SCANNER_HOME = tool 'mysonar'
        CLOUDINARY_CLOUD_NAME = credentials('CLOUDINARY_CLOUD_NAME')
        CLOUDINARY_KEY = credentials('CLOUDINARY_KEY')
        CLOUDINARY_SECRET = credentials('CLOUDINARY_SECRET')
        MAPBOX_TOKEN = credentials('MAPBOX_TOKEN')
        DB_URL = credentials('DB_URL')
        Image_Name = "wild-weekend"
        Docker_Username = "manju9676"
    }
    stages {
        stage('code') {
            steps {
              git 'https://github.com/manju9676/WildWeekender.git'
            }
        }
        stage('CQA'){
            steps{
                withSonarQubeEnv('mysonar'){
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=wild-weekender \
                        -Dsonar.projectKey=wild-weekender'''
                }
            }
        }
        stage('Quality Gates'){
            steps{
                script{
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar'
                }
            }
        }
        stage('OWASP'){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', nvdCredentialsId: 'nvd_api_key', odcInstallation: 'DP-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Build Image'){
            steps{
                sh 'docker build -t $Image_Name .'
            }
        }
        stage('Image Scan'){
            steps{
                sh 'trivy image $Image_Name'
            }
        }
        stage('tag and push'){
            steps{
                withDockerRegistry(credentialsId: 'docker-hub') {
                    sh 'docker tag $Image_Name $Docker_Username/$Image_Name:$BUILD_NUMBER'
                    sh 'docker push $Docker_Username/$Image_Name:$BUILD_NUMBER'
                }
            }
        }
        stage('Run Container'){
            steps{
                sh 'docker run -itd -p 3000:3000 -e CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME -e CLOUDINARY_KEY=$CLOUDINARY_KEY -e CLOUDINARY_SECRET=$CLOUDINARY_SECRET -e MAPBOX_TOKEN=$MAPBOX_TOKEN -e DB_URL=$DB_URL --name cont1 $Docker_Username/$Image_Name:$BUILD_NUMBER'
            }
        }
    }
}
