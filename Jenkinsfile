pipeline {

    agent any

    environment {

        // arg
        UNIQ_NUM="1"
        
    	// git
        GIT_EMAIL='gind7878@naver.com'
        GIT_NAME='donghyun'
        GIT_CREDENTIALS_ID='donghyun-id'
    	GIT_CICD_URL='https://github.com/abs-git/cicd.git'
        GIT_MANIFEST_URL='https://github.com/abs-git/manifest.git'
        
    	// image info
    	DOCKERFILE_PATH="./test_${UNIQ_NUM}"
        DOCKERFILE="test.Dockerfile"
        IMAGE_NAME="pxd-cicd"
        NEW_TAG="${currentBuild.number}"
  	  	
        // ecr
        AWS_ACCESS_KEY_ID='*'
        AWS_SECRET_ACCESS_KEY='*'
        
        ECR_PROFILE="ecr"
        ECR_REGION="ap-northeast-2"
        ECR_ACCOUNT_ID="*"
        ECR_PATH="*.dkr.ecr.ap-northeast-2.amazonaws.com"
        ECR_REPO="pxd-cicd"

        // manifest info
        SERVER_NAME="pxd_infer_server_${UNIQ_NUM}"
        YAML_NAME="pxd_deploy_${UNIQ_NUM}"
    }
  
    stages {

        stage('Clone the Git Branch') {
            steps {
                git branch: 'main',
                    credentialsId: env.GIT_CREDENTIALS_ID,
                    url: env.GIT_CICD_URL
            }
            post {
                failure {
                  echo 'Repository clone failure !'
                }
                success {
                  echo 'Repository clone success !'
                }
            }
        }

        stage('Build Docker') {
            steps {
                script {
            	    def dockerfilePath = ${env.DOCKERFILE_PATH}
            	
                    sh "docker build --platform linux/amd64 -t ${env.IMAGE_NAME}:${env.NEW_TAG} -f ${dockerfilePath}/${env.DOCKERFILE} ."
                    sh "docker tag ${env.IMAGE_NAME}:${env.NEW_TAG} ${env.ECR_PATH}/${env.ECR_REPO}:${env.NEW_TAG}"
            	    sh "docker tag ${env.IMAGE_NAME}:${env.NEW_TAG} ${env.ECR_PATH}/${env.ECR_REPO}:latest"
                }
            }
            post {
                failure {
                  echo 'Docker Image Build failure !'
                }
                success {
                  echo 'Docker Image Build success !'
                }
            }
      }

        stage('Upload aws ECR'){
            steps{
            	script{
                    sh "aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}"
                    sh "aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}"
                    sh "aws ecr get-login-password --region ${env.ECR_REGION} | docker login --username AWS --password-stdin ${env.ECR_ACCOUNT_ID}.dkr.ecr.${env.ECR_REGION}.amazonaws.com"
                    sh "docker push ${env.ECR_PATH}/${env.ECR_REPO}:${env.NEW_TAG}"
                    sh "docker push ${env.ECR_PATH}/${env.ECR_REPO}:latest"
                }
            }
            post{
            	failure {
                    echo 'ECR: Docker Image Push failure !'
                    sh "docker rmi ${env.IMAGE_NAME}:${env.NEW_TAG}"
                    sh "docker rmi ${env.ECR_PATH}/${env.ECR_REPO}:${env.NEW_TAG}"
                    sh "docker rmi ${env.ECR_PATH}/${env.ECR_REPO}:latest"
                }
                success {
                    echo 'ECR: Docker image push success !'
                    sh "docker rmi ${env.IMAGE_NAME}:${env.NEW_TAG}"
                    sh "docker rmi ${env.ECR_PATH}/${env.ECR_REPO}:${env.NEW_TAG}"
                    sh "docker rmi ${env.ECR_PATH}/${env.ECR_REPO}:latest"
                }
            }
        }

        stage('K8S Manifest Update'){
            // 추가적인 manifest 수정은 아래에 작성
            // Jenkins는 repo의 commit을 감지하면 수행되기 때문에 manifest 저장을 위한 repo를 따로 분리해 사용
            steps{
            	script{
                    git branch: 'main',
                        credentialsId: env.GIT_CREDENTIALS_ID,
                        url: env.GIT_MANIFEST_URL

            	    sh "cat ${env.SERVER_NAME}/${env.YAML_NAME}.yaml"
            	    
            	    sh "sed -i 's/${env.ECR_REPO}:.*/${env.ECR_REPO}:${env.NEW_TAG}/' ${env.SERVER_NAME}/${env.YAML_NAME}.yaml"

            	    sh "cat ${env.SERVER_NAME}/${env.YAML_NAME}.yaml"
            	    sh "git add ${env.SERVER_NAME}/${env.YAML_NAME}.yaml"
            	    sh "git commit -m 'Update the ${env.YAML_NAME} yaml | Jenkins Pipeline' "
            	    sh "git remote -v"
            	    sh "git push ${env.GIT_MANIFEST_URL} main"
            	            	                    
                }
            }
            post {
                failure {
                  echo 'K8S Manifest Update failure !@'
                }
                success {
                  echo 'K8S Manifest Update success !!'
                }
            }
        }

        stage('Deploy the new container'){
            steps{
            	script{
                    git branch: 'main',
                        credentialsId: env.GIT_CREDENTIALS_ID,
                        url: env.GIT_MANIFEST_URL

            	    def manifestPath = './'
                    
            	    sh "kubectl apply -f ${manifestPath}/${env.SERVER_NAME}/${env.YAML_NAME}.yaml"
                }
            }
            post {
                failure {
                  echo 'Container deployment failure !@'
                }
                success {
                  echo 'Container deployment success !!'
                }
            }
        }

        
    }
}
