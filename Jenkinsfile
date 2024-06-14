pipeline{
    agent any
    options{
        ansiColor('xterm')
        disableConcurrentBuilds()
        timeout(time: 30, unit: "MINUTES")
        withAWS(credentials: 'aws-terraform-deployent-role', region: 'us-east-1')
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
                dir('terraform') {
                    sh 'terraform init \
                        -backend-config="bucket=${TF_STATE_BUCKET}" \
                        -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}"'
                }
            }
        }
        stage('Terraform Plan'){
            steps{
                dir('terraform') {
                    sh 'terraform plan \
                        -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}" \
                        -lock=false -out=tfplan'
                    stash includes: 'tfplan', name: 'tfplan'
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
                dir('terraform') {
                    unstash 'tfplan'
                    sh 'terraform apply tfplan \
                        -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}"'
                }
            }
        }
    }
}
