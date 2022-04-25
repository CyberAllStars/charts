
def notifyBuild(String buildStatus = 'STARTED', String message = '') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL}) ${message}"

  // Override default values based on build status
  if (buildStatus == 'STARTED' || buildStatus == 'MESSAGE') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}     
pipeline {
  environment {
    COMMIT = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
    PROJECT = "bzrlvl"
    APP_NAME = "charts"
    FE_SVC_NAME = "${APP_NAME}"
    CLUSTER = ""
    CLUSTER_ZONE = "us-east1-b"
    IMAGE_TAG = "}"
    JENKINS_CRED = "${PROJECT}"
    ENVSPACE = "${env.APP_NAME}-${env.BRANCH_NAME}"
   
  }
  agent {
    kubernetes {
      //label "st2dio"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
labels:

  jenkins: slave
spec:
  # Use service account that can deploy to all namespaces
  #serviceAccountName: jenkins
  imagePullSecrets:
    - name: gcr-json-key 
  containers:

  - name: builder
    image: us.gcr.io/bzrlvl/builder:latest
    imagePullPolicy: Always    
    command:
    - cat
    tty: true
    volumeMounts:
    - name: deploy-gpgkey
      mountPath: /secret/deploy.keys.pvt
      subPath: deploy.keys.pvt
      readOnly: true
  - name: helm
    image: alpine/helm
    imagePullPolicy: Always    
    command:
    - cat
    tty: true
  volumes:
    - name: deploy-gpgkey
      secret:
        secretName: deploy-gpgkey

"""
    }
  }

  stages {

    // stage('Checkout external proj') {
    //     steps {
    //         git branch: 'master',
    //             credentialsId: '38ae9ff7-0a7e-4b82-9b92-66cd07f5c976',
    //             url: 'git@github.com:CyberAllStars/thirdparty-sec-tools.git'

    //         sh "ls -lat; pwd"
    //     }
    // }    // stage('build') {
    //   steps {
    //       script {        
    //           container('builder') {
                 
    //                   try {
    //                        sh("""mkdir ~/.ssh/; ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
    //                 git clone --recurse-submodules git@github.com:CyberAllStars/thirdparty-sec-tools.git /tmp/sectools ; cd /tmp/sectools; git submodule update --remote;
    //                 git clone --recurse-submodules git@github.com:CyberAllStars/thirdparty-tools.git /tmp/tools; cd /tmp/tools; git submodule update --remote;
    //               git submodule update --init --recursive --depth=1 ext/sectools # timeout=10 """)
    //                 } catch (Exception e) {
    //                     echo 'Exception occurred: ' + e.toString()
    //                     sh 'Handle the exception!'
    //                 }

   
    //           }
    //       }
    //   }
    // }
    stage('index') {
      steps {
          script {        
            
              container('helm') {
                sh("sh -x scripts/findcharts ${env.WORKSPACE}")
              }
          }
      }
    }
    stage('git build push') {
      steps {
        sshagent(credentials: ['38ae9ff7-0a7e-4b82-9b92-66cd07f5c976']) {
          script {        
              container('builder') {
                  //withCredentials([sshUserPrivateKey(credentialsId: '38ae9ff7-0a7e-4b82-9b92-66cd07f5c976', gitToolName: 'git')]) {
                    sh("""   
                      git config --global user.email "builder@tryb.co.za"
                      git config --global user.name "builderwwjenkins6yhngh33juytghjj"                   
                    """)
                     sh("""git diff; git add index.yaml *.tgz; git branch ${COMMIT}; git checkout ${COMMIT};
                      git commit -m'index update for ${COMMIT}';
                      git checkout ${env.BRANCH_NAME}; git merge $COMMIT;
                     git push origin ${env.BRANCH_NAME}""")
                 // }
   
              }
          }  
        }
      }
    }
    stage('Finally') {
      steps {
        notifyBuild('SUCCESSFUL')
      }
    }
  } 
}

      
