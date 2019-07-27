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
        ACCESS_KEY = credentials('AWS_ACCESS_KEY_ID')
        SECRET_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages {
            stage('SCM Checkout'){
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/althaf1088/sc_pipeline']]])
                }
             }
           /* stage('TerraformPlan'){
                steps {
                    dir('terraform/'){
                        script {
                            try {
                                sh "terraform workspace new ${params.WORKSPACE}"
                            } catch (err) {
                                sh "terraform workspace select ${params.WORKSPACE}"
                            }
                            sh "terraform plan -var 'access_key=$ACCESS_KEY' -var 'secret_key=$SECRET_KEY' \
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
                                sh 'terraform output  >> hosts'
                            }
                        }
                    }
                }
            }*/
           stage('TerraformDelete'){
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
        }


         /*    stage('Ansible'){
            steps{
                ansiblePlaybook credentialsId: 'jenkins', installation: 'ansible', playbook: 'ansible/python3.yml'
            }
            }*/


    }

}

