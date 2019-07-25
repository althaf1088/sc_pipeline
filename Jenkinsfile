pipeline {
 agent any

 stages {
 stage('checkout') {
 steps {
     checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/althaf1088/sc_pipeline']]])

 }
 }
 stage('Set Terraform path') {
 steps {
 script {
 def tfHome = tool name: 'Terraform'
 env.PATH = '${tfHome}:${env.PATH}'
 }
 sh 'terraform — version'


 }
 }

 stage('Provision infrastructure') {

 steps {
 dir('dev')
 {
 sh 'terraform init'
 sh 'terraform plan -out=plan'
 // sh ‘terraform destroy -auto-approve’
 sh 'terraform apply plan'
 }


 }
 }



 }
}
