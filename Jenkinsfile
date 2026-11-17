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
                echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin
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
        
        stage('SSH Publish') {
            steps {
                script {
                    def targets = ['WAS01', 'WAS02']
                    
                    targets.each { target ->
                        echo "SSH Publish to ${target}"
                        sshPublisher(publishers: [
                            sshPublisherDesc(
                                configName: target, // 리스트의 서버 이름이 순서대로 들어감
                                transfers: [
                                    sshTransfer(
                                        cleanRemote: false,
                                        excludes: '',
                                        execCommand: '''
                                            docker rm -f $(docker ps -aq) || true
                                            docker rmi -f $(docker images -q) || true
                                            docker run -itd -p 8080:8080 --restart=always --name=spring-petclinic ehddl0220/spring-petclinic:latest
                                        ''',
                                        execTimeout: 120000,
                                        flatten: false,
                                        makeEmptyDirs: false,
                                        noDefaultExcludes: false,
                                        patternSeparator: '[, ]+',
                                        remoteDirectory: '',
                                        remoteDirectorySDF: false,
                                        removePrefix: '',
                                        sourceFiles: ''
                                    )
                                ],
                                usePromotionTimestamp: false,
                                useWorkspaceInPromotion: false,
                                verbose: false
                            )
                        ])
                    }
                }
            }
        }
    }
}
