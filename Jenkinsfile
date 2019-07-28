pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "Terraform"
    }
    parameters {
        string(name: 'WORKSPACE', defaultValue: 'terraform', description:'setting up workspace for terraform')
    }
    environment {
        TF_HOME = tool('Terraform')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
    }
    stages {

            stage('SCM Checkout'){
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/althaf1088/sc_pipeline']]])
                }
             }
            stage('Unit test'){
            steps {
                sh 'echo "Skipping Unit test"'
                }
             }
           /* stage('TerraformDelete'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'Can you please confirm the apply', ok: 'Ready to delete'
                        apply = true
                    } catch (err) {
                        apply = false
                         currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('terraform/'){

                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
            }*/
            stage('TerraformInit'){
            steps {
                dir('terraform/'){
                    sh "terraform init -input=false"
                    sh "echo \$PWD"
                    sh "whoami"
                }
            }
             }
            stage('TerraformPlan'){
                steps {
                    dir('terraform/'){
                        script {
                            try {
                                sh "terraform workspace new ${params.WORKSPACE}"
                            } catch (err) {
                                sh "terraform workspace select ${params.WORKSPACE}"
                            }
                            sh "terraform plan -var 'access_key=$AWS_ACCESS_KEY_ID' -var 'secret_key=$AWS_SECRET_ACCESS_KEY' \
                            -out terraform.tfplan;echo \$? > status"
                            stash name: "terraform-plan", includes: "terraform.tfplan"
                        }
                    }
                }
            }
            stage('TerraformApply'){
                steps {
                    script{
                        def apply = false
                        try {
                            input message: 'Can you please confirm the apply', ok: 'Ready to Apply the Config'
                            apply = true
                        } catch (err) {
                            apply = false
                             currentBuild.result = 'UNSTABLE'
                        }
                        if(apply){
                            dir('terraform/'){
                                unstash "terraform-plan"
                                sh 'terraform apply terraform.tfplan'


                            }
                        }
                    }
                }
            }
          /* stage('TerraformDelete'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'Can you please confirm the apply', ok: 'Ready to delete'
                        apply = true
                    } catch (err) {
                        apply = false
                         currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('terraform/'){

                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }*/


         /*    stage('Ansible'){
            steps{
                ansiblePlaybook credentialsId: 'jenkins', installation: 'ansible', playbook: 'ansible/python3.yml'
            }
            }*/


    }

}

