pipeline{
    agent any
    options{
        timeout(time: 30, unit: "MINUTES")
        withAWS(credentials: 'aws-terraform-deployent-role', region: 'us-east-1')
    }
    stages{
        stage('Terraform Init'){
            environment {
                TF_STATE_BUCKET = credentials('aws-terraform-state-s3-bucket')
            }
            steps{
                dir('terraform'){
                    sh 'terraform init -no-color -backend-config="bucket=${TF_STATE_BUCKET}"'
                }
            }
        }
        stage('Terraform Plan'){
            steps{
                dir('terraform'){
                    sh 'terraform plan -no-color'
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
                dir('terraform'){
                    sh 'terraform apply -auto-approve -no-color'
                }
            }
        }
    }   
}