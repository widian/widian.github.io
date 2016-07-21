---
layout: post
title: "Make Twitter Bot Using Python - 1"
date: 2016-07-22 02:25:00 +0900
categories: twitter-bot
comments: true
---

2009년에 가입하고 거의 들어가지 않았던 트위터를, 2015년 가을부터 다시 사용하기 시작했습니다. 그러면서 가볍게 읽고 가볍게 넘길 수 있다는 장점에 눈떠서 좀 더 트위터를 깊이 사용해보고 싶게 되었습니다. 처음에는 [트위터 크롤러][twitter-crawler]를 만들어서 교환학생 기간 동안 보고서 작성에 활용하기도 하고, 졸업연구 기반 정보로 활용하기도 했습니다. 

그러던 중 트위터와 [자연어 처리 툴][twitter-korean-text]을 활용해 간단한 단어장 역할을 하는 앱을 만들면서 동시에 파이썬을 이용한 twitter api, 자연어 처리 툴 활용 방식을 널리 알려야겠다는 생각이 들었습니다. 이 나라는 영어 못하면 개발자로 인정해주질 않아서 모든 개발 관련 문서가 영어로 되어 있기 때문이죠. 몇몇 트위터 API에 대해 설명하고 있는 글은 대체적으로 프로그램을 만드는 방식보다는 트위터 API에 대한 정보를 담고 있는 것들이 대부분이었습니다. 물론 제가 제대로 한국어 문서를 검색하지 않아서 그럴 수도 있겠지만요.

트위터 API를 사용하기 위해선 먼저 Consumer Key, Consumer Secret, Access Token, Access Token Secret이 필요합니다. 이 키를 발급하는 법에 대해서는 [아타호군 님의 블로그][ataho-blog-twitter-key]에 설명되어 있으니 이 글을 참고해주세요. 아마 블로그가 없어지더라도, 키를 발급하는 방법은 한국어 문서가 많습니다.

이 글에서 사용할 트위터 API 라이브러리는 [python-twitter][python-twitter-git] 입니다. 이 부분은 [tweepy][tweepy-git] 등 python용의 유명한 라이브러리가 많기 때문에, 원하시는 걸 사용해도 좋습니다. 딱히 이걸로 시작한 특별한 이유가 없습니다. 왜였을까요. 아무튼 시작은

```
pip install python-twitter
```

를 이용해 python-twitter를 설치합니다. pip을 사용하지 않으시는분은 [python-twitter][python-twitter-git]에 들어가 clone을 받은 뒤, 

``` 
python setup.py build
python setup.py install
```

을 이용해 설치하셔도 정상적으로 설치될 거라고 생각합니다.


[twitter-crawler]: https://github.com/widian/twitter-analysis
[twitter-korean-text]: https://github.com/twitter/twitter-korean-text
[ataho-blog-twitter-key]: http://blog.naver.com/acwboy/220541273950
[python-twitter-git]: https://github.com/bear/python-twitter
[tweepy-git]: https://github.com/tweepy/tweepy
