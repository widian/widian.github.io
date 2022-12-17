---
layout: post
title: "surefire report 사용 중에 junit5 결과가 CI에서 안 보이는 경우"
date: 2022-12-07 16:44:44 +0900
categories: blog
tags: [surefire, surefire report, JUnit5, Devops, CI, Jenkins]
comments: true
---

- Jenkins 등 CI에서 테스트 결과를 확인하기 위해 surefire report를 사용하는 경우가 있습니다. Jenkins Blueocean에서는 surefire report 플러그인으로 생성된 테스트 결과 xml 파일을 junit testResults에 post해주면 테스트 탭에서 수행된 테스트의 이름과 테스트 수행 결과를 확인할 수 있도록 도와줍니다.
- 그러나 구버전의 surefire report plugin을 사용하면, `mvn test` 를 실행하더라도 JUnit5 테스트가 실행되지 않는 경우가 발생합니다.
- surefire 플러그인을 사용하고 있는 경우, 최소 2.19 버전을 사용하게 되면 Junit5 테스트에 대해서도 테스트가 정상적으로 동작합니다.

## Maven pom.xml 기준 플러그인 설정 추가
- 아래와 같이 플러그인 버전을 올리고, dependency에 junit jupiter api 의존성을 추가해 줍니다.
- junit-vintage-engine을 사용하고 있다면, vintage engine도 의존성에 추가해줍니다.
- 버전은 사용중인 junit jupiter 버전과 동일한 버전을 사용해야 합니다. (여기선 5.9.1 사용)

```xml
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-surefire-plugin</artifactId>
	<version>2.22.2</version>
	<configuration>
		<argLine>-Xms512m -Xmx1536m -Xss256k</argLine>
	</configuration>
	<dependencies>
		<dependency>
			<groupId>org.junit.jupiter</groupId>
			<artifactId>junit-jupiter-api</artifactId>
			<version>5.9.1</version>
		</dependency>
		<dependency>
			<groupId>org.junit.vintage</groupId>
			<artifactId>junit-vintage-engine</artifactId>
			<version>5.9.1</version>
		</dependency>
	</dependencies>
</plugin>
```

- surefire report plugin도 동일하게 변경해 줍니다.

```xml
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-surefire-report-plugin</artifactId>
	<version>2.22.2</version>
	<configuration>
		<outputDirectory>target/reports</outputDirectory>
	</configuration>
	<dependencies>
		<dependency>
			<groupId>org.junit.jupiter</groupId>
			<artifactId>junit-jupiter-api</artifactId>
			<version>5.9.1</version>
		</dependency>
		<dependency>
			<groupId>org.junit.vintage</groupId>
			<artifactId>junit-vintage-engine</artifactId>
			<version>5.9.1</version>
		</dependency>
	</dependencies>
</plugin>
```

## Report 플러그인 설정 변경
- 만약 테스트 시에 xref 가 없다는 에러가 나온다면 아래 의존성을 reporting에 추가해줍니다.

```xml
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-jxr-plugin</artifactId>
	<version>3.3.0</version>
</plugin>
```

## 실행
- `mvn test surefire-report:report` 실행하여 surefire-report가 정상적으로 나오는지 확인합니다.
