pipeline {
    agent any // 분산 빌드할때 지정하는거. 현재는 any 랑 none 이랑 같음
    tools {
        jdk 'JDK21' // JAVA SDK 등록한거
        maven 'M3' // 아까 등록한 메이븐
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
                echo 'Maven Build'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package' // 위에서 maven 이라고 설정했는데, 젠킨스가 알아서 mvn 알아듣고 찾아서 씀
            }
        }
        // SSH를 이용한 실행파일 전송
        stage('SSH Publish') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'target', // 타겟에게 보내는거
                transfers: [sshTransfer(cleanRemote: false, 
                excludes: '', 
                execCommand: '''
                fuser -k 8080/tcp
                export BUILD_ID=Spring-PetClinic
                nohup java -jar /home/ubuntu/spring-petclinic-4.0.0-SNAPSHOT.jar >> nohup.out 2>&1 &
                ''', // 쩜 3개 사이에 있는게 명령어
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
