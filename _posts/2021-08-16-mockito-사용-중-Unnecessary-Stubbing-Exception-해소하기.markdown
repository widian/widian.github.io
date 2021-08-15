---
layout: post
title: "Mockito 사용중 Unnecessary Stubbing Exception 해소하기"
date: 2021-08-16 03:10:00 +0900
categories: Java
tags: [Mockito, stubbing, Java, TDD, Unnecessary Stubbing Exception]
comments: true
---

# Mockito 사용중 Unnecessary Stubbing Exception 해소하기

Spring Boot에서 JUnit5와 이에 포함된 Mockito Core 3.x 버전을 사용할 때 아래와 같이 `UnnecessaryStubbingException` 에러가 나면서 테스트코드가 실패하는 경우가 있습니다.

```
org.mockito.exceptions.misusing.UnnecessaryStubbingException: 
Unnecessary stubbings detected.
Clean & maintainable test code requires zero unnecessary code.
```

이는 mockito-core버전이 1.x일 때 없었던 Strictness(테스트코드의 엄격성)을 규정하기 위해 생긴 에러이며, mockito-core 2.x 버전에서 도입되었습니다.

테스트코드의 엄격성은 다음 요소들을 보장해 줍니다.

- 테스트코드에서 사용되지 않는 stub (when/thenReturn)을 줄여줍니다.
- 테스트코드에서 불필요한 코드 중복을 없애주고 이를 통해 필요없는 테스트 코드 역시 줄여줍니다.
- 죽은 코드를 제거하면서 생기는 불필요한 테스트를 없애도록 도와줍니다.
- 이를 통해 디버깅 편의성과 생산 효율을 올려줍니다.

테스트코드의 엄격성도입은 mockito의 다음 철학과 관련이 있습니다

> Use the right tools and get cleaner tests, faster.

도입을 결정하게 된 [깃헙 이슈](https://github.com/mockito/mockito/issues/769)와 해당 이슈에 레퍼런스된 [Mockito 개발자의 철학에 대한 설명](https://www.linkedin.com/pulse/curious-how-get-even-cleaner-tests-new-mockito-features-faber/) , 그리고 stubbing 감지의 장점을 좀 더 디테일하게 설명한 [Mockito 블로그 글(Clean tests produce clean code - strict stubbing in Mockito)](http://blog.mockito.org/2017/01/clean-tests-produce-clean-code-strict.html) 을 참고하기 바랍니다.

Mockito-core 3.x버전에서는 위에서 설명한 엄격성이 강제되었기 때문에, 불필요한 stubbing 코드를 제거해야 합니다. 해결방법은 3가지가 있습니다.



### 1. Mockito-core 버전을 1.x나 2.x로 내리기

- 최악의 해법이지만, 수정되어야 하는 코드가 많을 경우 어쩔 수 없이 선택해야하는 경우의 수입니다.
- 2.x 에서는 엄격성 개념이 도입되었지만, 테스트에 아래와 같이 MockitoSettings를 지정해주면 엄격성을 우회해서 테스트할 수 있습니다.

```java
@MockitoSettings(strictness = Strictness.WARN)
@Test
void foo() throws Exception {
  // Test blah blah...
}
```

## 2. lenient() 메서드를 앞에 추가하기

- `doReturn`, `when` 등의 앞에 `lenient()`를 추가해서 해당 stubbing이 미사용될 수 있음을 표시합니다.
- 일반적으로, `@BeforeEach` 처럼 전체 테스트에 적용되어야 하는 stubbing이 일부 엣지 케이스에서 미사용될때 사용하는 것이 좋습니다.
  - 남발하게 된다면, 과한 코드의 중복을 보게 되어 Mockito에서 추구하고자 한 테스트의 개선에 도움이 되지 않습니다.

```java
// lenient()를 붙여서 mocking 결과를 항상 사용하진 않음을 표시합니다.
lenient().doReturn(fixedClock.instant()).when(clock).instant();
lenient().doReturn(fixedClock.getZone()).when(clock).getZone();
```

## 3. 필요없는 stubbing을 제거하기

- 말 그대로 필요없는 `when`, `doReturn`, `doThrow` 등을 제거합니다.
- 불필요한 테스트가 줄어들고, 중복 mocking이 줄어들기 때문에 나중에 코드를 수정하는 사람이 테스트코드를 이해하는데 편해집니다.
