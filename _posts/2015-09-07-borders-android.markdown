---
layout: post
title:  "Drawing borders in Android"
date:   2015-09-07 14:34:25
categories: jekyll update
tags: android, border
image: /assets/article_images/borders-android/background.png

--- 

To draw borders we have to understand the basics of layer-list drawable component. An exhaustive guide is provided by [Android Developers Guide][developers-android-layer-list].

Code snippet to draw top and bottom borders:
> res/drawable/border.xml
{% prism markup%}
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
<item><!--Item 1-->
	<shape android:shape="rectangle">
		<stroke android:color="@color/green"   android:width="2dp"/>
		<solid android:color="#FFFFFFFF" />
	</shape>
</item>
<item android:top="2dp" android:bottom="2dp"><!--Item 2-->
	<shape android:shape="rectangle">
		<solid android:color="#FFFFFFFF" />
	</shape>
</item>
</layer-list>
{% endprism %}

#####How layer list works?

+ Layer One

{% prism markup  %}
<item><!--Item 1-->
	<shape android:shape="rectangle">
		<stroke android:color="@color/green" android:width="2dp"/>
		<solid android:color="#FFFFFFFF" />
	</shape>
</item>
{% endprism %}

Above code snippet results in a layer with border on all sides. **Stroke** tag defines the border and **Solid** tag defines the background colour.
#####![Layer One](/assets/article_images/borders-android/layer-one.png)

+ Layer Two

{% prism markup  %}
<item android:top="2dp" android:bottom="2dp"><!--Item 2-->
	<shape android:shape="rectangle">
		<solid android:color="#FFFFFFFF" />
	</shape>
</item>
{% endprism %}

This snippet is drawn over the first layer which has top offset 2dp and bottom offset 2dp (border thickness)
#####![Layer One And Two](/assets/article_images/borders-android/both-layers.png)

[developers-android-layer-list]:http://developer.android.com/guide/topics/resources/drawable-resource.html#LayerList
[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
