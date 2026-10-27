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
        
        // SSH를 이용한 k8s에 도커 명령실행 및 deployment 재실행
        stage('SSH Publish') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'k8s-master',
                transfers: [sshTransfer(cleanRemote: false, excludes: '',
                execCommand: '''
                docker build -t spring-petclinic:${BUILD_NUMBER} .
                docker tag spring-petclinic:${BUILD_NUMBER} ehddl0220/spring-petclinic:latest
                echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin
                docker image push ehddl0220/spring-petclinic:latest
                docker rmi -f spring-petclinic:${BUILD_NUMBER}
                docker rmi -f ehddl0220/spring-petclinic:latest
                kubectl apply -n was -f /home/ubuntu/work/was/was-deploy.yml
                rm -rf Dockerfile target
                ''', 
                execTimeout: 120000, 
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: '', 
                remoteDirectorySDF: false, 
                removePrefix: '', 
                sourceFiles: 'target/*.jar, Dockerfile')], 
                usePromotionTimestamp: false, 
                useWorkspaceInPromotion: false, 
                verbose: false)])
            }
        }
    }
}
