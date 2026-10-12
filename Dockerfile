# 알파인 리눅스, JDK21 설치되어있는 이미지
FROM eclipse-temurin:21-jre-alpine
# ARG 는 변수를 만듬. 이건 Dockerfile 내부에서만 사용됨. 사실 이거 없이 해도 됨
ARG JAR_FILE_PATH=target/*.jar
# 변수를 사용해서, 이름을 바꾸면서 복사
COPY ${JAR_FILE_PATH} spring-petclinic.jar
# 실행
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
# ENTRYPOINT 만 사용하면 docker run 실행시 입력하는 값만 인자로 받음
# CMD 도 같이 사용하면 CMD 가 기본인자로 들어감.
# 컨테이너를 하나의 독립된 실행파일(CLI 도구)처럼 만들고 싶을때는 ENTRYPOINT 만 정의해서 사용하는것이 일반적이고, 권장되는 패턴임
