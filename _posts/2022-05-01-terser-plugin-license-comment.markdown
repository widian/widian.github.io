---
layout: post
title: "Terser plugin으로 license 주석 추출해서 라이센스 파일 생성하기"
date: 2022-05-01 14:42:00 +0900
categories: Javascript
tags: [TerserPlugin, Webpack, License, BannerPlugin, extractComments]
comments: true
---

## Terser Plugin 간단 설명
- Terser Plugin은 Webpack에서 기존 Uglify Plugin이 수행하던 Minify(작게 하기) 모듈입니다.
- Terser는 번들링하는 파일들을 작게 해줘서 번들링된 파일의 크기를 줄여주는 역할을 합니다.
- Terser는 파일 크기를 작게 해주는 과정에서 불필요한 주석과 `console.log` 등 개발자 확인용의 코드를 제거해주는 역할을 합니다.
- 그렇지만, 주석중에는 올바른 오픈소스 사용을 위해 제거되지 말아야할 라이센스 주석들이 존재합니다.
- Terser Plugin 에서는 extractComments 옵션을 사용해서 제거되지 말아야할 주석을 지정할 수 있습니다.

## extractComments 옵션 사용법
```javascript
module.exports = {
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        extractComments: {
          condition: /^\**!|@preserve|@license|@cc_on/i,
          filename: (file) => {
// file은 bundling 결과의 파일 이름입니다.
			return file.replace(/\.(\w+)($|\?)/, '.$1.LICENSE.txt');
          },
          banner: (licenseFile) => {
// banner는 번들링한 파일 상단에 만들어 질 주석입니다.
            return `License information can be found in ${licenseFile}`;
          },
        },
      }),
    ],
  },
};
```
- Terser Plugin 설정에 extractComments옵션을 넣습니다.
- Object 대신 "all" 을 넣을 경우 모든 주석이 남습니다.
- 옵션 Object를 넣을 경우, condition, filename, banner 등의 옵션을 활용할 수 있습니다.
- condition 은 주석에 특정 문구가 포함됐을 경우 추출합니다.
- 주로 @license, /*!, @preserve, @cc_on 을 사용하기 때문에 위와 같은 condition을 넣었습니다.
- filename 은 String 을 넣거나 function을 넣을 수 있습니다.
  - String을 넣게 되면 모든 주석이 하나의 파일에 추출됩니다.
  - Function을 넣게 되면, 번들링된 파일마다 추출된 comment를 넣을 수 있습니다.
  - Function에 전달된 file은 번들링결과의 파일 이름입니다 (name, chunkhash등이 포함된).
  - 여기서는 파일명을 그대로 남기고, 뒤에 .LICENSE.txt 를 추가해주도록 했습니다.
- banner는 번들링한 파일 상단에 만들어질 주석입니다. 라이센스 파일로 이동할 링크를 만들어 주면 좋습니다.

### 결과
- vendor-{chunkhash}.js.LICENSE.txt 파일이 만들어지고, vendor-{chunkhash}.js 상단에 `/* License information can be found in vendor-{chunkhash}.js.LICENSE.txt */` 주석이 남습니다.

## Banner Plugin과 조합하기.
- webpack.BannerPlugin과 조합해서, 모든 라이센스 파일 상단에 남을 주석을 추가해줄 수 있습니다.
- BannerPlugin으로 만들어지는 주석은 Minify 전에 남기 때문에, webpack.BannerPlugin 으로 상단에 condition으로 남는 주석을 추가해 준다면, 모든 LICENSE.txt 파일에 해당 주석이 들어가게 됩니다.

```javascript
new webpack.BannerPlugin({
  banner: (yourVariable) => {
    return `/*!
	여기에 라이센스를 넣으세요.
*/`;
  },
});
```

# 참고
- 웹팩 배너 플러그인 https://webpack.js.org/plugins/banner-plugin/
- 웹팩 Terser Plugin https://webpack.js.org/plugins/terser-webpack-plugin/#root
