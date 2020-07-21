 
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
        - name: fuchicorp
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
        booleanParam(defaultValue: false, description: 'please select to apply the changes', name: 'terraformAPPLY'),
        booleanParam(defaultValue: false, description: 'please select to destrot all', name: 'terraformDestroy'),
        choice(choices: ['us-west-2', 'us-west-1', 'us-east-1', 'us-east-2', 'eu-west-1'], description: 'Please select the region', name: 'aws_region')
        ])
        ])


    podTemplate(name: k8slabel, label: k8slabel, yaml: slavePodTemplate, showRawYaml: false) {
      node(k8slabel) {

        stage("Pull SCM") {
            git 'https://github.com/vladpacc/jenkins-instance.git'
        }
        
        stage("Generate Variables") {
            println("Generate Variables")
        }
        
                    container("buildtools") {
                        dir('deployments/terraform') {
                            withCredentials([usernamePassword(credentialsId: 'packer-build-creds', 
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                            stage("Terraform Apply/plan") {
                                if (!terraformDestroy){
                                if(params.TerraformApply) {
                                    println("Planning the changes")
                                    sh """
                                    #!/bin/bash
                                    export AWS_DEFAULT_REGION=${aws_region}
                                    terraform init
                                    terraform apply -auto-approve
                                    """
                                } else {
                                    println("Applying the changes")
                                    sh """
                                    #!/bin/bash
                                    export AWS_DEFAULT_REGION=${aws_region}
                                    terraform init
                                    terraform plan
                                    """
                            }
                        }
                    }
         }
    }
       
                stage("Terraform Destroy") {
                    if (params.terraformDestroy) {
                        println("Destroying the all")
                        sh """
                        #!/bin/bash
                        export AWS_DEFAULT_REGION=${aws_region}
                        terraform init
                        terraform destroy
                        """
                    } else { 
                        println("Skipping the destroy")
                        }
                    } 
         }         
        }
      }
