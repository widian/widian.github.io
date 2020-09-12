---
layout: post
title: "core-js@2에서 core-js@3으로 마이그레이션"
date: 2019-06-18 20:49:00 +0900
categories: Javascript
tags: [core-js, babel, 폴리필, regenerator-runtime, core-js 버전업, core-js3]
comments: true
---

## 배경

- core-js@2는 2017년 말에 지원이 종료되었습니다.
  - 새로 추가되는 것들은 레거시 지원이고, 새로운 feature추가는 이루어지지 않고 있습니다.
- 새로운 es 요소는 core-js@3에 추가되고 있습니다.
- babel 7.4부터 core-js@3을 이용해 proposal 단계의 es 요소들도 활용 가능하도록 변경되는 중입니다.
- 자세한 변경사항은 https://github.com/zloirock/core-js/blob/master/docs/2019-03-19-core-js-3-babel-and-a-look-into-the-future.md 에서 확인할 수 있습니다.

## 전환 노트

- https://babeljs.io/blog/2019/03/19/7.4.0 페이지를 보고 따라하는 식으로 진행합니다.

### .babelrc 파일 수정

- `yarn add --dev core-js@3` 을 실행해서 core-js@3을 설치해 줍니다.
- `@babel/preset-env`를 사용하고 있다면, core-js@3 사용 옵션을 켜줘야 합니다.

```babelrc
presets: [
  ["@babel/preset-env", {
    useBuiltIns: "entry", 
    corejs: 3,
  }]
]
```

- `@babel/plugin-transform-runtime` 을 사용하고 있다면, core-js@3 사용 옵션을 켜줘야 합니다.

```babelrc
plugins: [
  ["@babel/transform-runtime", {
    corejs: 3,
  }]
]
```

- 그리고 `yarn remove @babel/runtime-corejs2 ` 를 실행하고, `yarn add --dev @babel/runtime-corejs3` 를 실행해서 core-js@3 용 runtime-core를 설치해 줍니다. 

### 파일 수정

- `@babel/polyfill`은 더이상 사용되지 않기 때문에, `yarn remove @babel/polyfill`을 사용해 줍니다. `@babel/polyfill` 에 `core-js@2`와 `core-js@3` 을 선택하는 옵션을 넣게 된다면, 양쪽 모두의 의존성을 가져야 하기 때문에 어쩔 수 없는 선택이었습니다.
- 파일 상단의 `import "@babel/polyfill";` 를 아래와 같이 바꿔줍니다.

```javascript
import "core-js/stable";
import "regenerator-runtime/runtime";
```

- `regenerator-runtime/runtime`는 `@babel/runtime-corejs3` 에 포함되어 있기 때문에 따로 설치해줄 필요는 없습니다.

### js에서 window를 this로 쓰는 것을 수정하거나 제거.

- 예를 들어

```javascript
(function(a){console.log(a)}(this);
```

- 위와 같이 entry에서 this를 window처럼 쓰는 파일이 비정상동작합니다.
  - 관련되는 코드가 거의 없어서 해당 코드를 리팩토링 하거나 제거했습니다.
