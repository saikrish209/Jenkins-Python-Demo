pipeline {
    agent any
    
    environment {
        // --- CONFIGURATION ---
        AWS_REGION = 'eu-north-1'
        // Replace with YOUR actual ECR URI
        ECR_URI = '438260428676.dkr.ecr.eu-north-1.amazonaws.com'
        REPO_NAME = 'jenkins-python-demo'
        
        // We use the Jenkins Build Number to create a unique version tag (e.g., v24, v25)
        IMAGE_TAG = "${BUILD_NUMBER}" 
    }

    stages {
        stage('Get Code') {
            steps {
                // Jenkins pulls the latest code from GitHub
                git branch: 'main', url: 'https://github.com/saikrish209/Jenkins-Python-Demo.git'
            }
        }
        
        stage('Build & Push to AWS') {
            steps {
                // We use the AWS Credentials stored in Jenkins
                withCredentials([usernamePassword(credentialsId: 'aws-ecr-creds', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_KEY')]) {
                    sh '''
                        echo "--- Authenticating with AWS ---"
                        aws configure set aws_access_key_id $AWS_KEY
                        aws configure set aws_secret_access_key $AWS_SECRET
                        aws configure set region $AWS_REGION
                        
                        echo "--- Logging into ECR ---"
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
                        
                        echo "--- Building Docker Image v${IMAGE_TAG} ---"
                        docker build -t $ECR_URI/$REPO_NAME:$IMAGE_TAG .
                        # We also tag it 'latest' so K8s always knows which one is the newest
                        docker build -t $ECR_URI/$REPO_NAME:latest .
                        
                        echo "--- Pushing to AWS ECR ---"
                        docker push $ECR_URI/$REPO_NAME:$IMAGE_TAG
                        docker push $ECR_URI/$REPO_NAME:latest
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "--- Updating Kubernetes Cluster ---"
                    
                    # Point kubectl to the K3s config file
                    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
                    
                    # 1. Update the image in the deployment (Forces K8s to see the new tag)
                    kubectl set image deployment/python-app python-app=$ECR_URI/$REPO_NAME:$IMAGE_TAG
                    
                    # 2. Force a restart to ensure zero-downtime update
                    kubectl rollout restart deployment/python-app
                    
                    # 3. Wait until the update is finished
                    kubectl rollout status deployment/python-app
                '''
            }
        }
    }
}
