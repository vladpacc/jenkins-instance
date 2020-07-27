  
def k8slabel = "jenkins-pipeline-${UUID.randomUUID().toString()}"

def slavePodTemplate = """
      metadata:
        labels:
          k8s-label: ${k8slabel}
        annotations:
          jenkinsjoblabel: ${env.JOB_NAME}-${env.BUILD_NUMBER}
      spec:
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: component
                  operator: In
                  values:
                  - jenkins-jenkins-master
              topologyKey: "kubernetes.io/hostname"
        containers:
        - name: buildtools
          image: fuchicorp/buildtools
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        - name: docker
          image: docker:latest
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        serviceAccountName: default
        securityContext:
          runAsUser: 0
          fsGroup: 0
        volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
    """

    properties([
        parameters([
            booleanParam(defaultValue: false, description: 'Please select to apply the changes ', name: 'terraformApply'),
            booleanParam(defaultValue: false, description: 'Please select to destroy all ', name: 'terraformDestroy'), 
            choice(choices: ['us-west-2', 'us-west-1', 'us-east-2', 'us-east-1', 'eu-west-1'], description: 'Please select the region', name: 'aws_region'),
            choice(choices: ['dev', 'qa', 'stage', 'prod'], description: 'Please select the environment to deploy.', name: 'environment'),
            string(defaultValue: 'ami-012142d0d2c50938c', description: 'please choose the AMI ID', name: 'Instance_AMI_ID', trim: false)
            string(defaultValue: 'jenkinsfile', description: 'please choose the instance name', name: 'Instance_name', trim: false)
        ])
    ])


    podTemplate(name: k8slabel, label: k8slabel, yaml: slavePodTemplate, showRawYaml: false) {
      node(k8slabel) {
          
        stage("Pull SCM") {
            git 'https://github.com/vladpacc/jenkins-instance.git'
        }

        stage("Generate Variables") {
          dir('deployments/terraform') {

            println("Generate Variables")
            def deployment_configuration_tfvars = """
            environment = "${environment}"
            Instance_name = "${Instance_name}"
            Instance_AMI_ID = "${Instance_AMI_ID}"
            """.stripIndent()
            writeFile file: 'deployment_configuration.tfvars', text: "${deployment_configuration_tfvars}"
            sh 'cat deployment_configuration.tfvars >> dev.tfvars'

          }   
        }

        container("buildtools") {
            dir('deployments/terraform') {
                withCredentials([usernamePassword(credentialsId: "aws-access-${environment}", 
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    println("Selected cred is: aws-access-${environment}")
                    stage("Terraform Apply/plan") {
                        if (!params.terraformDestroy) {
                            if (params.terraformApply) {
                                println("Applying the changes")
                                sh """
                                #!/bin/bash
                                export AWS_DEFAULT_REGION=${aws_region}
                                source ./setenv.sh dev.tfvars
                                terraform apply -auto-approve -var-file \$DATAFILE
                                """
                            } else {
                                println("Planing the changes")
                                sh """
                                #!/bin/bash
                                set +ex
                                ls -l
                                export AWS_DEFAULT_REGION=${aws_region}
                                source ./setenv.sh dev.tfvars
                                terraform plan -var-file \$DATAFILE
                                """
                            }
                        }
                    }

                    stage("Terraform Destroy") {
                        if (params.terraformDestroy) {
                            println("Destroying the all")
                            sh """
                            #!/bin/bash
                            export AWS_DEFAULT_REGION=${aws_region}
                            source ./setenv.sh dev.tfvars
                            terraform destroy -auto-approve -var-file \$DATAFILE
                            """
                        } else {
                            println("Skiping the destroy")
                        }
                    }
                }

            }
        }
      }
    }