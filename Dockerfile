# 알파인 리눅스, JDK21 설치되어있는 이미지
FROM eclipse-temurin:21-jre-alpine
# ARG 는 변수를 만듬. 이건 Dockerfile 내부에서만 사용됨. 사실 이거 없이 해도 됨
ARG JAR_FILE_PATH=target/*.jar
# 변수를 사용해서, 이름을 바꾸면서 복사
COPY ${JAR_FILE_PATH} spring-petclinic.jar
# 실행
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
