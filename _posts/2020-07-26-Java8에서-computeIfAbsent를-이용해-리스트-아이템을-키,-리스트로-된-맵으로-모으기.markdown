---
layout: post
title: "Java8에서 computeIfAbsent를 이용해 리스트 아이템을 키, 리스트로 된 맵으로 모으기"
date: 2020-07-26 01:23:00 +0900
categories: Java 
tags: [java8, computeIfAbsent, Java]
comments: true
---

## Java8에서 computeIfAbsent를 이용해 리스트 아이템을 키, 리스트로 된 맵으로 모으기

뷰 관련 작업을 하다보면, Map이 아닌 key-value item의 List를 Map으로 모아줘야 할 일이 생길 때가 있습니다. 예를 들어, 게시판을 만들고 있을 때, 게시판의 글을 분류별이 아닌 시간 단위의 리스트로 불러온 다음, 게시판별로 분류를 해줘야하는 일이 있을 수 있습니다. 

이럴 때는, post를 DB에서 리스트로 가져온 뒤, 서버에서 `Map<String, List<Post>>` 와 같이 정리해주면 뷰에서 쉽게 작업할 수 있습니다. 원하는 결과는 Key가 boardName이고, Value가 Post의 리스트인 Map이 나와야 합니다.

아래와 같이 곁가지들을 쳐내고 필요한 부분만 떼서 lombok과 junit5를 활용해 간단한 테스트를 작성해 보았습니다.

```java
private static final String 자게 = "자게";
private static final String 유게 = "유게";
private static final String 핫게 = "핫게";

@Test
void test() {
	List<Post> postList = Arrays.asList(
		Post.builder().boardName(자게).postId(1).build(),
		Post.builder().boardName(자게).postId(2).build(),
		Post.builder().boardName(유게).postId(3).build(),
		Post.builder().boardName(유게).postId(4).build(),
		Post.builder().boardName(유게).postId(5).build(),
		Post.builder().boardName(핫게).postId(6).build()
	);
	Map<String, List<Post>> result = arrange(postList);
	assertThat(result.keySet().size(), is(3));
	assertNotNull(result.get(자게));
	assertThat(result.get(자게).size(), is(2));
	assertNotNull(result.get(유게));
	assertNotNull(result.get(핫게));
}

private Map<String, List<Post>> arrange(List<Post> postList) {
	Map<String, List<Post>> result = new HashMap<>();
	return result;
}

@Getter
@Builder
private static class Post {
	private String boardName;
	private int postId;
}
```



#### computeIfAbsent 없이 구현하기

- 아직은 `arrange` 가 구현되지 않아서 테스트가 실패합니다. 먼저 `computeIfAbsent` 를 사용하지 않으면 아래와 같이 작성할 수 있습니다.
- 작성 후 테스트를 돌리면 성공하는 것을 확인할 수 있습니다.

```java
private Map<String, List<Post>> arrange(List<Post> postList) {
	Map<String, List<Post>> result = new HashMap<>();
	postList.forEach(post -> {
		if (result.get(post.getBoardName()) == null) {
			result.put(post.getBoardName(), new ArrayList<>());
		}
		result.get(post.getBoardName()).add(post);
	});
	return result;
}
```



#### computeIfAbsent를 사용해 간단하게 바꾸기

- `computeIfAbsent`를 활용하면 if문을 간단하게 없앨 수 있습니다.

```java
private Map<String, List<Post>> arrange(List<Post> postList) {
	Map<String, List<Post>> result = new HashMap<>();
	postList.forEach(post -> result.computeIfAbsent(post.getBoardName(), k -> new ArrayList<>())
		.add(post)
	);
	return result;
}
```

- 만약 `post.getBoardName()` 에 해당하는 키가 없다면
  - 해당 키를 기반으로 `new ArrayList<>()` 를 만들어주고 put한다. 
- 있다면 바로 value를 리턴한다. 
- 마지막으로 리턴 받은`ArrayList` 에 add(post)를 시행한다. 

if문이 없어져서 더 이해하기 쉬운 코드가 되었습니다^_^.
