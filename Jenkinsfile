pipeline {
    agent any // 분산 빌드할때 지정하는거. 현재는 any 랑 none 이랑 같음
    tools {
        jdk 'JDK21' // JAVA SDK 등록한거
        maven 'M3' // 아까 등록한 메이븐
    }
    environment {
        DOCKERHUB_CRED = credentials('dockerCredentials')
    }
    
    stages {
        // Github로 부터 소스코드 다운로드
        stage('Git Clone') {
            steps {
                echo 'Git Clone' // 화면 출력
                git url: 'https://github.com/ehddl0220/spring-petclinic.git',
                branch: 'main'
            }
        }
        
        // Maven을 이용한 Build
        stage('Maven Build') {
            steps {
                echo 'Maven Build'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }
        
        // Docker Image  생성
        stage('Docker Image Create') {
            steps {
                echo 'Docker Image Create'
                sh '''
                docker build -t spring-petclinic:${BUILD_NUMBER} .
                docker tag spring-petclinic:${BUILD_NUMBER} ehddl0220/spring-petclinic:latest
                '''
            } 
        }
        
        // Dockerhub Image Push
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                // Docker Login
                sh 'echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin'

                // Docker Hub Push
                sh 'docker image push ehddl0220/spring-petclinic:latest'
            }
            // Docker Image 삭제
            post {
                always {
                    // 이미지 제거
                    sh '''
                    docker rmi -f ehddl0220/spring-petclinic:${BUILD_NUMBER}
                    docker rmi -f ehddl0220/spring-petclinic:latest
                    '''
                } // 항상 실행
            }
        }
        
        // SSH를 이용한 Docker 컨테이너 실행 WAS01
        stage('SSH Publish1') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'WAS01', // 타겟에게 보내는거
                transfers: [sshTransfer(cleanRemote: false, 
                excludes: '', 
                execCommand: '''
                docker rm -f $(docker ps -aq) # 컨테이너 제거
                docker rmi -f $(docker images -q) # 이미지 제거 
                docker run -itd -p 8080:8080 --name=spring-petclinic ehddl0220/spring-petclinic:latest # 컨테이너 동작
                ''',
                execTimeout: 120000, // 명령어 제한시간 주는거
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: '', 
                remoteDirectorySDF: false, 
                removePrefix: '', 
                sourceFiles: '')], 
                usePromotionTimestamp: false, 
                useWorkspaceInPromotion: false, verbose: false)])
            }
        }
		
		// SSH를 이용한 Docker 컨테이너 실행 WAS02
        stage('SSH Publish2') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'WAS02', // 타겟에게 보내는거
                transfers: [sshTransfer(cleanRemote: false, 
                excludes: '', 
                execCommand: '''
                docker rm -f $(docker ps -aq) # 컨테이너 제거
                docker rmi -f $(docker images -q) # 이미지 제거
                docker run -itd -p 8080:8080 --name=spring-petclinic ehddl0220/spring-petclinic:latest # 컨테이너 동작
                ''',
                execTimeout: 120000, // 명령어 제한시간 주는거
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: '', 
                remoteDirectorySDF: false, 
                removePrefix: '', 
                sourceFiles: '')], 
                usePromotionTimestamp: false, 
                useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }
}
