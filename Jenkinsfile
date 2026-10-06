pipeline {
    agent any
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
    }
}
