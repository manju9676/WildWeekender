pipeline {
    agent any
    environment{
        SCANNER_HOME = tool('sonar')
        IMAGE_NAME = 'wild_weekender'
        DOCKER_USERNAME = 'manju9676'
        GIT_USERNAME = 'manju9676'
        GIT_EMAIL = 'kmanjunatheee@gmail.com'
        GIT_PAT = credentials('github-pat')
        REPO = 'WildWeekender'
    }
    stages{
        stage('Code'){
            steps{
                git 'https://github.com/manju9676/WildWeekender.git'
            }
        }
        stage('CQA'){
            steps{
                withSonarQubeEnv('sonar'){
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
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', nvdCredentialsId: 'nvd_key', odcInstallation: 'owasp-dependency'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Image Build'){
            steps{
                sh 'docker build -t $IMAGE_NAME .'
            }
        }
        stage('Image Scan'){
            steps{
                sh 'trivy image $IMAGE_NAME'
            }
        }
        stage('Tag and Push'){
            steps{
                withDockerRegistry([credentialsId: 'docker-hub', url: 'https://index.docker.io/v1/']) {
                     sh 'docker tag $IMAGE_NAME $DOCKER_USERNAME/$IMAGE_NAME:$BUILD_NUMBER'
                     sh 'docker push $DOCKER_USERNAME/$IMAGE_NAME:$BUILD_NUMBER'
                        }
               
                }
          }
        stage('Update Image tag'){
            steps{
                sh 'sed -i "s/IMAGE_TAG/$BUILD_NUMBER/g" Manifests/4.deploy.yml'
                sh 'git add Manifests/4.deploy.yml && git commit -m "Update image tag to $BUILD_NUMBER" '
                sh 'git push https://$GIT_USERNAME:$GIT_PAT@github.com/$GIT_USERNAME/$REPO.git HEAD:master'                                                                                                                                 
            }
        }
        stage('Deploy to K8s'){
            steps{
                withKubeConfig(caCertificate: '', clusterName: 'EKS_CLOUD', contextName: '', credentialsId: 'k8-token', namespace: 'wild-weekender', restrictKubeConfigAccess: false, serverUrl: 'https://CF6A4933A3FF7AF6AD047EC6DCF3238F.gr7.us-east-1.eks.amazonaws.com') {
                sh 'kubectl apply -f Manifests/1.secret.yml'
                sh 'kubectl apply -f Manifests/2.resource.yml'
                sh 'kubectl apply -f Manifests/3.limitrange.yml'
                sh 'kubectl apply -f Manifests/4.deploy.yml'
                sh 'kubectl apply -f Manifests/5.svc.yml'
                sh 'kubectl apply -f Manifests/6.hpa.yml'
                sh 'kubectl apply -f Manifests/7.pdb.yml'
                }
            }
        }
    }
}
