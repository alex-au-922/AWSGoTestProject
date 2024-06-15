def tf_plan_status = 0

pipeline{
    agent {
        docker {
            image 'hashicorp/terraform:1.8.5'
            args '--entrypoint="" -u root'
        }
    }
    options{
        timestamps()
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
        stage('Backend Build') {
            steps {
                script {
                    def subfolders = sh(returnStdout: true, script: 'ls -d backend/*').trim().split('\n')
                    echo "Subfolders: ${subfolders}"
                    parallel subfolders.collectEntries { directory ->
                        [ (directory) : {
                            stage("Build ${directory}") {
                                agent {docker {image 'golang:1.22-alpine3.18'}}
                                steps {
                                    dir(directory) {
                                        sh 'apk add upx'
                                        sh 'go test ./... -v'
                                        sh 'go build -o bin/main'
                                        sh 'upx bin/main'
                                    }
                                }
                            }
                        }]
                    }
                }
                dir('backend') {
                    stash includes: '**/bin/main', name: 'builds'
                }
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
                unstash 'builds'
                dir('terraform') {
                    script {
                        tf_plan_status = sh(
                            returnStatus: true,
                            script: 'terraform plan \
                            -var "deploy_role_arn=${TF_AWS_DEPLOY_ROLE_ARN}" \
                            -lock=false -out=tfplan -detailed-exitcode'
                        )
                        switch(tf_plan_status) {
                            case 0:
                                echo 'No changes detected, skipping apply'
                                break
                            case 1:
                                error 'Terraform plan failed'
                                break
                            case 2:
                                stash includes: 'tfplan', name: 'tfplan'
                                break
                            default:
                                error 'Unknown error'
                        }
                    }
                }
            }
        }
        stage('Manual Approval'){
            when {
                expression { tf_plan_status == 2 }
            }
            steps{
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to approve the deployment?', ok: 'Yes'
                }
            }
        }
        stage('Terraform Apply'){
            when {
                expression { tf_plan_status == 2 }
            }
            steps{
                unstash 'builds'
                dir('terraform') {
                    unstash 'tfplan'
                    sh 'terraform apply tfplan'
                }
            }
        }
    }
}
