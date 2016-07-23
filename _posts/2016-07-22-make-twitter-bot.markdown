---
layout: post
title: "Make Twitter Bot Using Python - 1"
date: 2016-07-22 02:25:00 +0900
categories: twitter-bot
comments: true
---

2009년에 가입하고 거의 들어가지 않았던 트위터를, 2015년 가을부터 다시 사용하기 시작했습니다.
그러면서 가볍게 읽고 가볍게 넘길 수 있다는 장점에 눈떠서 좀 더 트위터를 깊이 사용해보고 싶게 되었습니다. 
처음에는 [트위터 크롤러][twitter-crawler]를 만들어서 교환학생 기간 동안 보고서 작성에 활용하기도 하고, 졸업연구 기반 정보로 활용하기도 했습니다. 

그러던 중 트위터와 [자연어 처리 툴][twitter-korean-text]을 활용해 간단한 단어장 역할을 하는 앱을 만들면서 동시에 파이썬을 이용한 twitter api, 자연어 처리 툴 활용 방식을 널리 알려야겠다는 생각이 들었습니다.
이 나라는 영어 못하면 개발자로 인정해주질 않아서 모든 개발 관련 문서가 영어로 되어 있기 때문이죠. 
몇몇 트위터 API에 대해 설명하고 있는 글은 대체적으로 프로그램을 만드는 방식보다는 트위터 API에 대한 정보를 담고 있는 것들이 대부분이었습니다.
물론 제가 제대로 한국어 문서를 검색하지 않아서 그럴 수도 있겠지만요.

트위터 API를 사용하기 위해선 먼저 Consumer Key, Consumer Secret, Access Token, Access Token Secret이 필요합니다. 
이 키를 발급하는 법에 대해서는 [아타호군 님의 블로그][ataho-blog-twitter-key]에 설명되어 있으니 이 글을 참고해주세요. 아마 블로그가 없어지더라도, 키를 발급하는 방법은 한국어 문서가 많습니다.

이 글에서 사용할 트위터 API 라이브러리는 [python-twitter][python-twitter-git] 입니다. 
이 부분은 [tweepy][tweepy-git] 등 python용의 유명한 라이브러리가 많기 때문에, 원하시는 걸 사용해도 좋습니다. 
딱히 이걸로 시작한 특별한 이유가 없습니다. 왜였을까요. 아무튼 시작은

```
pip install python-twitter
```

를 이용해 python-twitter를 설치합니다. pip을 사용하지 않으시는분은 [python-twitter][python-twitter-git]에 들어가 clone을 받은 뒤, 

``` 
python setup.py build
python setup.py install
```

을 이용해 설치하셔도 정상적으로 설치됩니다. 

이제 본격적으로 python-twitter를 이용해 봇을 만들어보겠습니다. 먼저 3개의 파일을 생성했습니다. config.py, tweet.py, daemon.py입니다. 
daemon은 트위터 스트리밍을 읽는 부분으로, 봇 계정의 팔로워들의 멘션으로부터 명령을 받는 역할을 하게 될 것입니다.
tweet.py는 트위터 API를 이용해 멘션을 하거나 트위터 스트림을 처리하는 역할을 하게 될 것입니다. 
config.py는 트위터 정보, 아직 넣지 않았지만 mysql등 외부 db에 관한 정보를 저장하는 역할을 하게 될 것입니다.

{% highlight python %}
#config.py

CONSUMER_KEY= 'consumer_key'
CONSUMER_SECRET = 'consumer_secret'
ACCESS_TOKEN_KEY =  'access_token'
ACCESS_TOKEN_SECRET= 'access_token_secret'

{% endhighlight %}

config를 나누는 이유는 git을 이용해 프로젝트를 관리할 때 .gitignore에 config.py를 추가하는 것으로 내 개인정보나 다름없는 키들이 배포되는 것을 막기 위함입니다. 
config외에 파일에서 불러오거나, db, 웹을 통해 불러오는 방법도 있겠지만, 가장 쉽게 할 수 있는 config역할의 python파일을 만드는 것으로 대체합니다. 
config를 python으로 만들면 다음과 같이 사용할 수 있습니다.

{% highlight python %}
# tweet.py

import twitter

try:
    from config import CONSUMER_KEY
    from config import CONSUMER_SECRET
    from config import ACCESS_TOKEN_KEY
    from config import ACCESS_TOKEN_SECRET
except:
    print 'Tweet API keys are not exist'
    exit()

class TweetSupport(object):
    api = None
    def __init__(self):
        self.api = twitter.Api(
                consumer_key=CONSUMER_KEY,
                consumer_secret = CONSUMER_SECRET,
                access_token_key = ACCESS_TOKEN_KEY,
                access_token_secret=ACCESS_TOKEN_SECRET)
    def get_api(self):
        return self.api

class StreamChecker(object):
    def __init__(self):
        pass

{% endhighlight %}

python-twitter의 library이름은 twitter입니다. ```import twitter```를 사용해 python-twitter를 import하고, config.py에 적어둔 키를 사용하기 위해 config로부터 key를 불러옵니다. 
config가 프로젝트 내에 포함되지 않기 때문에, config가 없는 상황을 상정하여 try-except로 묶어두는 것은 취향입니다.
TweetSupport라는 클래스를 만들어서 key를 저장해 놓고 사용할 수 있는 객체를 만듭니다.
마지막으로 StreamChecker라는 tweet.py에서 stream에서 불러온 json이 어떤 종류인지 확인할 용도의 객체를 임시로 만들어 놓았습니다.

{% highlight python %}
# daemon.py

from tweet import TweetSupport, StreamChecker

tw_api = TweetSupport().get_api()
listener = tw_api.GetUserStream(withuser='followings')
sc = StreamChecker()
try:
    for stream in listener:
        # 처리 루틴
        print stream

except KeyboardInterrupt:
    print 'DAEMON ENDED'

{% endhighlight %}

daemon.py에서는 만들어 둔 TweetSupport, StreamChecker를 import하여 사용하는 역할을 합니다. api객체를 불러온 뒤, listener를 GetUserStream을 이용해 만듭니다. withuser옵션을 주면 해당 봇 계정의 following 중인 유저들의 멘션 역시 stream에 출력하게 해줍니다.
그 다음, listener를 for문으로 읽게 하면 listener로부터 메시지가 올때마다 stream을 받게 됩니다. 이 구조는 GetUserStream이 python generator이기 때문입니다. 
listener는 stream이 올때마다 yield를 호출하여 처리 루틴으로 제어를 넘기게 됩니다. 
python generator와 yield의 역할, 코루틴에 대한 설명은 [이 블로그(soooprmx.com)][python-generator]를 참조해주시기 바랍니다.

Generator가 활성화되어 있는 동안은 제어권이 오지 않으면 아무것도 할 수 없기 때문에, 중간에 종료할 수 있도록 KeyboardInterrupt를 받아서 종료하게 합니다. 
지금은 오류를 출력하는 대신 'DAEMON ENDED'라는 문구를 출력하는 것 뿐이지만, 나중에는 이 부분에서 db 커넥션 해제 등 종료 루틴을 처리하는 역할을 하게 될 것입니다.

이제 ```python daemon.py```를 실행해서 결과가 나오는 것을 봅니다. 스트림이 정상적으로 연결되었다면, 

> {u'friends': [/* 팔로잉중인 유저 id들 */]}

라는 메시지를 볼 수 있습니다.

다음 장에서는 이 stream을 읽어서 객체로 변환하는 부분을 진행해 볼 예정입니다.

PS. 
처음엔 자신만만하게 썼지만, 내용이 너무 부끄럽네요^^;;;





[twitter-crawler]: https://github.com/widian/twitter-analysis
[twitter-korean-text]: https://github.com/twitter/twitter-korean-text
[ataho-blog-twitter-key]: http://blog.naver.com/acwboy/220541273950
[python-twitter-git]: https://github.com/bear/python-twitter
[tweepy-git]: https://github.com/tweepy/tweepy
[python-generator]: http://soooprmx.com/wp/archives/5622
