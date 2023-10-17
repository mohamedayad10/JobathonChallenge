pipeline {
	agent any
	environment {
		BRANCH_NAME = 'main'
	}
stages {
    stage('Setup') {
      steps {
        // Set up a Python virtual environment
        sh 'python -m venv venv'
        sh 'source venv/bin/activate'
        sh 'pip install --upgrade pip'
      }
    }

    stage('Install Dependencies') {
      steps {
        // Install Python dependencies using pip
        sh 'pip install -r requirements.txt'
        // for nodejs app
        sh 'npm install '
      }
    }
    stage ("Build") {
      echo 'Starting the build Stage'
      // for java app
      sh 'mvn clean compile'
      // for nodejs app
      sh 'npm run build'
      
    }
    stage ("Test") {
      // for Java app
      sh 'mvn test'
      sh 'mvn test -Dtest=LoginTest'
      // for python app
      sh 'python -m unittest discover'
      sh 'python -m unittest discover -s tests -p "*_selenium.py"'
      // for nodejs app
      sh 'npm test'
      sh 'node selenium_test.js
    }
    stage ("Push_to_registry") {
      steps {
        script {
          echo "Building the docker image "
          withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'pass', usernameVariable: 'user')]){
            sh 'docker build -t mohamed/app .'
            sh "echo $pass | docker login -u $user --pasword-stdin"
            sh 'docker push mohamed/app'
          }}}
    }
    stage ("deploy to dev server") {
				
     steps {
	script {
	 sshagent(['ec2-dev']) {
    	  sh 'ssh ubuntu@ip docker "echo "pass" | docker login --username=user --password-stdin && docker run -d -p 3000:3000 --name myapp mohamed/app"'
						}}}
    }
    stage('Deploy to Production Server') {
      steps {
	      sshagent(['ec2-prod']) {
          sh 'ssh ubuntu@ip docker "echo "pass" | docker login --username=user --password-stdin && docker run -d -p 3000:3000 --name myapp mohamed/app"'
   
	      }
	      }
    }
    stage("Deploy to kubernetes") {
	steps {
	  kubernetesDeploy(
          kubeconfigId: 'your-kubeconfig', // The ID configured in Jenkins for Kubernetes credentials
          configs: 'path/to/kubernetes/deployment.yaml' // Path to your Kubernetes deployment YAML file
        )
	    }
    }

	}
}
