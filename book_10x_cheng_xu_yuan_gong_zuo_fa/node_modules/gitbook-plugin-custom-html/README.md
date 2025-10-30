#### 插件说明

向页面中插入自定义 `HTML` 例如： 自定义头部导航

##### 安装：

1、`"plugins": ["custom-html"]` 配置插件

2、项目根目录执行 `gitbook install`


##### 使用示例：

`book.json` 中增加一下配置：

```json
{
	"title": "Custom-HTML",
	"plugins": ["custom-html"],
	"pluginsConfig": {
	    "customHTML": {
	    	"js": "js/my.js",
	    	"toURL": "../../mydir"
	    }
	}
}

```

自定义 js 示例：

```js
// $ 使用说明: https://www.npmjs.com/package/cheerio
module.exports = function($) {
	return $.html();
}
```

