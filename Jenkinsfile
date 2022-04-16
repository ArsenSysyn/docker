pipeline{

  agent {label 'arsen'}
  
  environment {
     IP_REMOTE_HOST='10.26.0.246'
  
  }

  stages {


    stage('Test application and build WAR file') {

      steps {
                    sh 'docker-compose -f docker/docker-compose.yml up bazel_test'
          sh 'docker container cp docker_bazel_test_1:/app/gerrit2/bazel-bin/release.war docker/app/gerrit.war'
      }
    }

    stage('Build application image') {

      steps {
          sh 'docker-compose -f docker/docker-compose.yml build app'
      sh 'docker save -o application.tar application'
      }
    }

    stage('Deploy application to remote host') {

      steps {
        sh 'scp application.tar root@${IP_REMOTE_HOST}:/root/application.tar'
      sh 'ssh root@${IP_REMOTE_HOST} docker load -i /root/application.tar'
      sh 'ssh root@${IP_REMOTE_HOST} docker ps -f name=docker_app_1 -q | xargs --no-run-if-empty docker container stop'
      sh 'ssh root@${IP_REMOTE_HOST} docker container ls -a -fname=docker_app_1 -q | xargs -r docker container rm'
      
          sh 'DOCKER_HOST=ssh://root@${IP_REMOTE_HOST} docker-compose -f docker/docker-compose.yml up -d app'
      }
    }

    }

  post {
    always {
           sh 'docker rm docker_bazel_test_1'
            cleanWs(cleanWhenAborted: true, cleanWhenFailure: true, cleanWhenNotBuilt: true, cleanWhenSuccess: true, cleanWhenUnstable: true)
        }
    }

}
