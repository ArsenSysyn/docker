pipeline{

  agent {label 'arsen'}


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
      sh 'scp application.tar root@10.26.0.246:/root/application.tar'
      sh 'ssh root@10.26.0.246 docker load -i /root/application.tar'
      sh 'ssh root@10.26.0.246 docker ps -f name=docker_app_1 -q | xargs --no-run-if-empty docker container stop'
      sh 'ssh root@10.26.0.246 docker container ls -a -fname=docker_app_1 -q | xargs -r docker container rm'
      
          sh 'DOCKER_HOST=ssh://root@10.26.0.246 docker-compose -f docker/docker-compose.yml up -d app'
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
