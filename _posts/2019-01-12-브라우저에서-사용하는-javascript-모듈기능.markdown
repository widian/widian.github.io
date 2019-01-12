---
layout: post
title: "브라우저에서 사용하는 javascript 모듈 기능"
date: 2019-01-12 19:56:00 +0900
categories: javascript
comments: true
---


## Browser native js module

- 이 글은 2018 chrome dev summit 에서 소개된 Speed Essential 발표의 일부분(https://www.youtube.com/watch?v=reztLS3vomE)을 보고, 관련 문서(https://developers.google.com/web/fundamentals/primers/modules)를 번역하여 작성된 글입니다.
- 작성시점은 1월 12일입니다.
- Module / nomodule의 지원 버전에 대해 확인하려면 [jakearchibald의 블로그 글](https://jakearchibald.com/2017/es-modules-in-browsers/) 을 참고해 주시기 바랍니다.

## JS 모듈이란 무엇인가?

- JS 모듈(또는 ES Module, ECMAScript 모듈이라고 일컫는)은 자바스크립트의 중요한 새 기능, 또는 새 기능들의 통칭입니다. 이미 과거에 유저단계에서 구현된 많은 JS 모듈 시스템이 있었습니다, 예를들어 node js의 [CommonJS](https://nodejs.org/docs/latest-v10.x/api/modules.html), [AMD](https://github.com/amdjs/amdjs-api/blob/master/AMD.md), 그 외에 다른 걸 사용했을 지도 모릅니다. 어쨌든 모든 유저단계에서 구현된 모듈 시스템은 "코드뭉치를 import하고 export한다"는 공통점을 가지고 있습니다.
- Javascript는 이제 모듈시스템을 표준화합니다. 자바스크립트 모듈은 단지 export예약어를 앞에 prefix로 붙여주는 것 만으로 const, function, 또는 다른 정의나 변수들을 export할 수 있습니다.
- import 예약어를 사용하면 export예약어를 사용해 내보낸 것을 사용할 수 있습니다.
- default 예약어를 사용하면 export한 변수/상수/함수 등을 import하는 곳에서 어떠한 이름으로든 사용할 수 있게 해줍니다.
- 모듈은 클래식 스크립트(모듈이 아닌 스크립트)비교해 다음과 같은 차이점을 갖고 있습니다.
  - 모듈은 strict mode를 default로 사용합니다.
  - HTML style comment는 더 이상 사용할 수 없습니다.
    - `<!--` 로 둘러싸인 주석을 의미합니다.
  - 모듈은 이제 lexical한 top level scope를 가집니다. 더이상 모듈 내에서 전역변수를 `var foo=42;` 와 같이 선언하더라도, `window.foo`로 접근할 수 없습니다.
  - import, export syntax는 오직 모듈 내에서만 사용 가능하고 클래식 스크립트 내에서는 사용할 수 없습니다. 
- 이러한 차이점 때문에, 같은 자바스크립트 코드더라도 module인지 클래식 스크립트인지에 따라 다르게 다뤄져야합니다. 이처럼 자바스크립트 런타임에는 어떤 스크립트가 모듈인지 알고 있어야합니다.

## 브라우저에서 JS 모듈 사용하기

- 브라우저에서 모듈 스크립트를 사용하기 위해, `<script> `태그 안에 type attribute에 module을 추가하는 것으로 사용할 수 있습니다.

```html
<script type="module" src="main.mjs"></script>
<script nomodule src="legacy.js"></script>
```

- `type="module"` 을 이해하는 브라우저는 **`nomodule`attribute를 가진 스크립트를 무시합니다.**
  - (번역 주석 :) safari 10.1 에서는 nomodule을 ignore하지 않기 때문에 특수한 스크립트가 필요합니다 (~~거지같은 사파리~~). 일부 [edge 16의 마이너 버전](https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/10525830/), [파이어폭스 55의 마이너 버전](https://bugzilla.mozilla.org/show_bug.cgi?id=1330900) 에서도 지원하지 않습니다.
    - 대응을 위해서는 다음 [gist](https://gist.github.com/samthor/64b114e4a4f539915a95b91ffd340acc)를 참고해 주세요.
- 이 기능을 이용해, module기능을 지원하는 브라우저에서는 module 이전의 es6기능을 transpile하지 않고 사용할 수 있기 때문에 (arrow function이나 async-await 등), 성능상의 이점을 크게 가져갈 수 있습니다. 
  - [module 이전에 브라우저별로 지원되던 ES6 기능](https://codepen.io/samthor/pen/MmvdOM)
- 만약 모듈 코드가 es7, 또는 그 이후의 코드가 포함되어있다면 [Phlip Walton이 블로그에 설명한 글대로, module 이후의 자바스크립트만 transpile되도록 변경하는 것으로 큰 용량/성능 이득을 받는 방법이 있습니다](https://philipwalton.com/articles/deploying-es2015-code-in-production-today/). 
- 레거시 브라우저는 nomodule에 있는 payload만 가지게 될 것입니다.

#### 브라우저별 모듈-클래식 스크립트의 차이점

- 위에서 설명한대로, 모듈과 클래식 스크립트는 동작방식도 조금 다릅니다. 브라우저별로도 조금 달라집니다.
- 예를들어, 모듈은 단 한번만 실행되지만, 클래식 스크립트는 DOM에 추가해서 load된 만큼 실행됩니다. 

```html
<script src="classic.js"></script>
<script src="classic.js"></script>
<!-- classic.js 는 2회 실행됩니다. -->

<script type="module" src="module.mjs"></script>
<script type="module" src="module.mjs"></script>
<script type="module">import './module.mjs';</script>
<!-- module.mjs 단 한번만 실행됩니다. -->
```

- 또한, 클래식 스크립트는 로드할 때 CORS 헤더에 관계 없이 항상 로드되는 스펙이었지만, module을 통해 mjs파일을 불러올 때는 `Access-Control-Allow-Origin: *` 와 같이 CORS에 맞는 헤더가 필요합니다. 
- 클래식 스크립트에서는 `defer` attribute등을 통해 `async` attribute가 붙은 스크립트의 다운로드가 막히지 않도록 할 수 없었지만, module에서는 가능합니다. 

#### 파일 확장자에 관련해

- 위에서는 모듈 자바스크립트를 사용하기 위해 `.mjs` 확장자를 사용하고 있는데, 사실 웹에서는 이 extension을 따로 구분하지 않고 일반적인 [Javascript MIME type(`text/javascript`)로 제공하게 됩니다](https://html.spec.whatwg.org/multipage/scripting.html#scriptingLanguages:javascript-mime-type). 
- 브라우저는 오직 type attribute만을 이용해 모듈과 모듈이 아닌 스크립트를 구분합니다.
- 그럼에도, 구글에서는 `.mjs`확장자를 사용하길 권장하는데, 거기엔 두 가지 이유가 있습니다.
  - 개발할 때 항상 코드 내용을 보지 않더라도, 열려는 파일이 모듈파일인지를 알고 사용할 수 있습니다.
  - nodejs의 실험적 모듈 기능 지원은 오직 `.mjs`파일에서만 동작합니다.

#### 사용하려는 모듈 특정하기

- 모듈을 `import`할 때는 다음과 같이 사용합니다.

```js
import {shout} from './lib.mjs';
```

- 아래와 같은 형태는 아직 지원되지 않습니다.

```js
// Not supported (yet):
import {shout} from 'jquery';
import {shout} from 'lib.mjs';
import {shout} from 'modules/lib.mjs';
```

- 아래와 같은 형태는 현재 지원됩니다.

```js
// Supported:
import {shout} from './lib.mjs';
import {shout} from '../lib.mjs';
import {shout} from '/modules/lib.mjs';
import {shout} from 'https://simple.example/modules/lib.mjs';

```

### 모듈은 기본적으로 지연(Deferred)됩니다.

- 클래식 스크립트는 기본적으로 HTML 파서를 지연시킵니다. 
- 모듈에서는 defer 어트리뷰트를 추가하는 것으로 스크립트 다운로드와 parsing을 병행하도록 할 수 있습니다.
- 기본적으로 모듈은 defer되기 때문에 모듈간의 의존관계에 따라 문제가 생기지 않습니다.

### 다른 모듈 기능

#### dynamic import (동적 import)

- static import를 사용하려면, 모든 모듈이 다운로드 된 뒤에 코드가 execution됩니다. 유저 버튼 액션에서만 사용되는 모듈이 있다면, 유저 액션을 받아서 모듈을 로드하도록 하는 것이 전체 로드 시간을 줄이는 데 도움이 될 것입니다.

```js
<script type="module">
  (async () => {
    const moduleSpecifier = './lib.mjs';
    const {repeat, shout} = await import(moduleSpecifier);
    repeat('hello');
    // → 'hello hello'
    shout('Dynamic import in action');
    // → 'DYNAMIC IMPORT IN ACTION!'
  })();
</script>
```

- static import와는 다르게, dynamic import는 regular script내에서도 사용될 수 있습니다. 이것은 기존 코드베이스에 모듈 기능을 점진적으로 추가시킬 때 유용하게 사용될 것입니다.
  - 이에 대해서는 [구글의 dynamic import에 관한 글](https://developers.google.com/web/updates/2017/11/dynamic-import) 을 참조해주세요.

#### import.meta

- 모듈과 관련된 새 기능으로,`import.meta` 가 있습니다. 현재 모듈에 대한 메타데이터를 제공하는 기능으로, ECMAScript에서 정의되지 않은 호스트 환경에 종속적인 기능을 사용하는 데에 정보를 제공해주는 기능입니다.
- 자세한 내용은 원본을 참고해주세요.

### 성능 권고

#### Keep bundling

- 모듈로 나눠졌더라도 번들링을 해주세요
  - http/2 환경에서도 100개, 300개로 나눠진 모듈 환경을 테스트 했을때 병목현상이 발생했습니다.
  - https://docs.google.com/document/d/1ovo4PurT_1K4WFwN2MYmmgbLcr7v6DRQN67ESVA-wq0/pub
- 모듈을 프로덕션에 배포하기 전에 번들러를 돌려서 모듈과 코드의 수를 줄이는 것이 퍼포먼스 측면에서도, minifying 측면에서도 이득입니다.

#### 번들링하기 vs 번들링하지 않고 그대로 보내기의 trade-off

- 사실 웹 개발에서는 모든 것이 트레이드 오프 (뭔가를 포기하는 대신 뭔가를 받아야하는) 과정이기 때문에, 어떤 환경에서는 번들링하지 않는 것이 이득일 수도 있습니다.
- 대략 200kb정도의 코드일 경우는 번들링되지 않은 모듈을 사용하는 것으로 캐시 히트를 늘리는 것이 전체 번들링을 하는 것 보다는 이득이 될 수 있습니다.
  - 그러나, 이 역시 유저 패턴에 따라 천차만별이기 때문에 데이터에 기반한 결정을 내리도록 하십시오.

#### 세분화된 모듈 사용하기

- 세분화된 모듈을 사용할 수록, 다른 코드에서 모듈을 참조할 때의 오버헤드가 작아지고, 번들러가 bundling을 할 때 필요 없는 코드를 쳐낼 때의 오버헤드도 줄어들게 됩니다.
  - 사용하지 않는 번들은 브라우저에서도 모듈을 다운로드 하지 않기 때문입니다.
- 추후 웹브라우저에서는 [네이티브 번들러](https://developers.google.com/web/fundamentals/primers/modules#web-packaging)를 제공할 계획이기 때문에, 미래의 개발환경을 위해서도 도움이 될 것입니다.

#### 모듈 preload하기

- [모듈 preload](https://developers.google.com/web/updates/2017/12/modulepreload)를 이용해 모듈 전달을 더 최적화할 수 있습니다.
- 모듈 preload는 의존성을 미리 로드해서 미리 컴파일 할 수 있도록 도와줍니다.
- 만약 모듈의 종속성 트리가 비대하다면, 브라우저는 모듈간의 종속성을 확인하기 위해 많은 http요청을 보내야합니다. 그러나 모듈을 preload하는 것으로 이러한 요청을 한번에 처리할 수 있습니다. 

```html
<link rel="modulepreload" href="lib.mjs">
<link rel="modulepreload" href="main.mjs">
<script type="module" src="main.mjs"></script>
<script nomodule src="fallback.js"></script>
```

#### http/2 사용하기

- 반드시 http/2 를 사용해야만 multiplexing을 사용할 수 있어서 모듈 사용의 이점을 최대화할 수 있습니다.
- 그러나 크롬팀에서 http/2 기능인 서버푸시를 사용해보았지만, 특별히 엄청난 기능향상을 경험할 수는 없었습니다. 
- http/2를 사용하는것은 필수적이지만, 서버 푸시는 아직 완벽한 해결책은 되지 않습니다 (not a silver bullet).

### 현재 웹 환경에서의 module 사용

- [크롬 통계](https://www.chromestatus.com/metrics/feature/timeline/popularity/2062) 에 따르면 아직 전체 웹 페이지의 0.08%정도밖에 사용하지 않고 있습니다.
  - 1월 10일 기준 약 0.13%까지 올라오긴 했습니다.
  - 이 기준은 dynamic import를 포함하지 않은 기준입니다.

## JS Module의 다음은 무엇이 될까요?

- module resolution algorithm 개선
  - 모듈간의 dependency 그래프에 따라 어떤 모듈을 사용해야할지 결정하는 알고리즘
  - 현재는 O(n^2) 이지만, 새 알고리즘을 사용하는 것으로 O(n)까지 개선할 계획입니다.

- worklets and web workers
  - worklet을 이용해 모듈을 worklet에 포함해서 사용할 수 있도록 하는 내용입니다.
  - 크롬 65에서 paint worklet 모듈이, 66에서는 audio worklet, 67에서는 layout worklet이 지원되었습니다.
- 맵으로 module import하기.
- 브라우저 단에서 bundling 기능 지원
- layered api
  - chrome dev summit에서 소개된 [Virtual Scroller](https://www.chromestatus.com/feature/5673195159945216) ([Virtual scroller 영상](https://www.youtube.com/watch?v=UtD41bn6kJ0))를 html태그로 포함될 수 있도록 모듈 로딩 단계에서 기능을 지원해주는 내용입니다.
- 아래와 같이 모듈로 virtual-scroller를 추가하면

```html
<script
  type="module"
  src="std:virtual-scroller|https://example.com/virtual-scroller.mjs"
></script>
```

- 아래와 같이 custom virtual-scroller element를 사용할 수 있게 하는 것입니다.

```html
<virtual-scroller>
  <!-- Content goes here. -->
</virtual-scroller>
```

## 개인적인 의견

- 결국 browser module기능을 사용하더라도, 번들링이나 transplie은 반드시 사용해야 합니다.
- 아직 webpack, parcel등을 사용하지 않는 레거시 프로젝트에서 번들링/transpile대신 해당 기능을 이용해 서비스를 전환할 계획이라면 원점으로 돌아가주세요.
- module 사용전에 번들링과 babel을 이용한 transpile 적용이 선행되어야 한다는 점을 유념하셔야 합니다.
  - 오히려 module기능 활용을 위해 legacy/non-legacy 두가지 형태의 bundling, transpile이 필요합니다.
- 너무 낮은 버전 대상의 transpile때문에 성능이 낮아지는 경우를 제외한다면, 아직(2019년 1월 12일 기준)은 browser module 기능을 사용해야할 필요성은 적어 보입니다.
