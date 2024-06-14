pipeline{
    agent any
    options{
        timeout(time: 30, unit: "MINUTES")
    }
    environment {
        TF_STATE_BUCKET = credentials('aws-terraform-state-s3-bucket')
        TF_AWS_DEPLOY_ROLE_ARN = credentials('aws-deployment-role-arn')
    }
    stages{
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Terraform Init'){
            steps{
                // debug
                sh 'aws sts get-caller-identity --output json'
                withAWS(credentials: 'aws-terraform-deployent-role', region: 'us-east-1') {
                    dir('terraform'){
                        sh 'terraform init -no-color \
                            -backend-config="bucket=${TF_STATE_BUCKET}" \
                            -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}"'
                    }
                }
            }
        }
        stage('Terraform Plan'){
            steps{
                withAWS(credentials: 'aws-terraform-deployent-role', region: 'us-east-1') {
                    dir('terraform'){
                        sh 'terraform plan -no-color \
                            -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}"'
                    }
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
                withAWS(credentials: 'aws-terraform-deployent-role', region: 'us-east-1') {
                    dir('terraform'){
                        sh 'terraform apply -auto-approve -no-color \
                            -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}"'
                    }
                }
            }
        }
    }   
}