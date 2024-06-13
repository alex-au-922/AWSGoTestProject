pipeline{
    agent any
    options{
        timeout(time: 15, unit: "MINUTES")
        withAWS(credentials: 'aws-terraform-deployent-role', region: 'us-east-1')
    }
    stages{
        stage('Terraform Init'){
            steps{
                environment{
                    TF_BACKEND_CONFIG = credentials('terraform-backend-conf-file')
                }
                dir('${env.WORKSPACE}/terraform'){
                    sh 'terraform init -backend-config=${TF_BACKEND_CONFIG}'
                }
            }
        }
        stage('Terraform Plan'){
            steps{
                dir('${env.WORKSPACE}/terraform'){
                    sh 'terraform plan'
                }
            }
        }
        stage('Manual Approval'){
            steps{
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to approve the deployment?', ok: 'Yes'
                }
            }
        }
        stage('Terraform Apply'){
            steps{
                dir('${env.WORKSPACE}/terraform'){
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }   
}