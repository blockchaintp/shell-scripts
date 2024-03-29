#!groovy

// Copyright © 2023 Kevin T. O'Donnell
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ------------------------------------------------------------------------------


pipeline {
  agent any

  options {
    ansiColor('xterm')
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(daysToKeepStr: '31'))
  }

  environment {
    PUBLISH_BASE_URL="https://dev.catenasys.com/repository/catenasys-raw-dev"
  }

  stages {
    stage('Fetch Tags') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: "${GIT_BRANCH}"]],
            doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [],
            userRemoteConfigs: [[credentialsId: 'github-credentials',noTags:false, url: "${GIT_URL}"]],
            extensions: [
                  [$class: 'CloneOption',
                  shallow: false,
                  noTags: false,
                  timeout: 60]
            ]])
      }
    }

    stage('Build') {
      steps {
        sh 'make clean build'
      }
    }

    stage('Package') {
      steps {
        sh "make package"
      }
    }

    stage("Analyze") {
      steps {
        withCredentials([string(credentialsId: 'fossa.full.token', variable: 'FOSSA_API_KEY')]) {
          sh '''
            make analyze
          '''
        }
      }
    }

    stage('Test') {
      steps {
        sh "make test"
      }
    }

    stage('Create Archive') {
      steps {
        sh "make archive"
        archiveArtifacts 'build/*.tgz, build/*.zip'
      }
    }

    stage("Publish") {
      when {
        expression { env.BRANCH_NAME == "main" }
      }
      steps {
        withCredentials([string(credentialsId: 'btp-build-github-pat',
                                variable: 'GITHUB_TOKEN')]) {
          sh '''
            make clean publish
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Successfully completed"
    }
    aborted {
      error "Aborted, exiting now"
    }
    failure {
      error "Failed, exiting now"
    }
  }
}
