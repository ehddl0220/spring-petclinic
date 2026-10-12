pipeline {
    agent any // 분산 빌드할때 지정하는거. 현재는 any 랑 none 이랑 같음
    tools {
        jdk 'JDK21' // JAVA SDK 등록한거
        maven 'M3' // 아까 등록한 메이븐
    }
    environment {
        DOCKERHUB_CRED = credentials('dockerCredentials') // 젠킨스 Credential 에 등록한 이름 그대로 등록
    }
    
    stages {
        // Github로 부터 소스코드 다운로드
        stage('Git Clone') {
            steps {
                echo 'Git Clone' // 화면 출력
                git url: 'https://github.com/ehddl0220/spring-petclinic.git', // 받아올 주소. 쉼표가 있는데, 그냥 한줄로 적어도 됨
                branch: 'main' // 메인 브랜치에서 가져와라 // 알아서 최적의 방식으로 clone 하던지 checkout하던지 fetch 해서 가져옴
            }
        }
        
        // Maven을 이용한 Build
        stage('Maven Build') {
            steps {
                // 아래의 sh 를 사용하지 않은 그냥 echo 는 젠킨스 내부 런타임을 사용하는거고
                // sh 로 감싸면, /bin/sh 를 불러와서 해당 쉘 환경에서 명령어를 실행하게 된다
                echo 'Maven Build'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package' // 위에서 maven 이라고 설정했는데, 젠킨스가 알아서 mvn 알아듣고 찾아서 씀
            }
        }
        
        // Docker Image  생성
        stage('Docker Image Create') {
            steps {
                echo 'Docker Image Create'
                sh '''
                docker build -t spring-petclinic:${BUILD_NUMBER} . # 버전 이름의 BUILD_NUMBER 는 젠킨스에서 빌드하면 아래에 생기는 #1,2,3 나와있는 그 번호
                docker tag spring-petclinic:${BUILD_NUMBER} ehddl0220/spring-petclinic:latest # 자신의 계정을 적어라
                # 이후 빌드된 파일의 이름은 spring-petclinic:버전 으로 할꺼
                # latest 에 계속 새로운 버전을 추가하는거
                '''
            } 
        }
        
        // Dockerhub Image Push
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                // Docker Login
                sh 'echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin' // 이 방법 말고 여러가지 다양한 방법이 있음. 다양한 언어로 가능

                // Docker Hub Push
                sh 'docker image push ehddl0220/spring-petclinic:latest'
            }
            // Docker Image 삭제
            post {
                // 윗 작업이 끝난 다음에 어떻게 할꺼냐
                // 이미지 푸쉬 하고하면 항상 이미지를 제거할 것
                // success {} // 성공했을때 실행
                // fail {} // 실패했을때 실행
                always {
                    // 이미지 제거 // 이미지 푸쉬를, 빌드넘버, latest 두개가 남아있는 상태에서 다시 빌드하다보면 하드 용량이 점점 부족해짐
                    sh '''
                    docker rmi -f ehddl0220/spring-petclinic:${BUILD_NUMBER}
                    docker rmi -f ehddl0220/spring-petclinic:latest
                    '''
                } // 항상 실행
            }
        }
        
        // SSH를 이용한 Docker 컨테이너 실행
        stage('SSH Publish') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'target', // 타겟에게 보내는거
                transfers: [sshTransfer(cleanRemote: false, 
                excludes: '', 
                execCommand: '''
                docker rm -f $(docker ps -aq) # 컨테이너 제거
                docker rmi -f $(docker images -q) # 이미지 제거 
                docker run -itd -p 80:8080 --name=spring-petclinic ehddl0220/spring-petclinic:latest # 컨테이너 동작
                # 자신의 도커 계정을 적어라
                # 80:8080 한건, 매번 8080적고 들어가기 귀찮아서
                # 쩜 3개 사이에 있는게 명령어, 그리고 따옴표나 쌍따옴표 3개로 감싸면, 명령어가 한줄로 적히지 않고, 지금 형태 그대로 유지하면서 가져가서 쓰라는 의미(현재 상태로는 한줄씩 읽으라는 의미)
                ''',
                execTimeout: 120000, // 명령어 제한시간 주는거
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: '', 
                remoteDirectorySDF: false, 
                removePrefix: 'target', 
                sourceFiles: 'target/*.jar')], 
                usePromotionTimestamp: false, 
                useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }
}
