---
layout: post
title:  "Android Shrink Resources, Resource Not Found"
date: 2020-07-05
categories: android issues
tags: apksize shrinkResources minifyEnabled proguard issues cast sdk
image: /assets/article_images/2020-07-05-shrink-resources-not-found/remove_unused.jpg
---

Recently I came across an issue when using [Google Cast SDK](https://developers.google.com/cast){:target="_blank"} with `R8(Proguard)` and `Shrinkresources`. My debug build seems to work well, but release build compiles and installs... But crashes as soon as it opens. :thinking:  

Let's look into the crash logs. 

{% highlight java  %}
 Caused by: android.content.res.Resources$NotFoundException: Drawable com.sample.application:drawable/mr_button_light with resource ID #0x7f08018a
     Caused by: android.content.res.Resources$NotFoundException: File res/drawable/mr_button_light.xml from drawable resource ID #0x7f08018a
        at android.content.res.ResourcesImpl.loadDrawableForCookie(ResourcesImpl.java:876)
        at android.content.res.ResourcesImpl.loadDrawable(ResourcesImpl.java:659)
        at android.content.res.Resources.getDrawableForDensity(Resources.java:906)
        at android.content.res.Resources.getDrawable(Resources.java:845)
        at android.content.res.Resources.getDrawable(Resources.java:820)
        at androidx.mediarouter.app.MediaRouteButton$b.doInBackground(:1)
        ...
     Caused by: android.view.InflateException: Class not found x
        at android.graphics.drawable.DrawableInflater.inflateFromClass(DrawableInflater.java:224)
        at android.graphics.drawable.DrawableInflater.inflateFromXmlForDensity(DrawableInflater.java:141)
        at android.graphics.drawable.Drawable.createFromXmlInnerForDensity(Drawable.java:1402)
        at android.graphics.drawable.Drawable.createFromXmlForDensity(Drawable.java:1361)
        at android.content.res.ResourcesImpl.loadXmlDrawable(ResourcesImpl.java:939)
        at android.content.res.ResourcesImpl.loadDrawableForCookie(ResourcesImpl.java:862)
        at android.content.res.ResourcesImpl.loadDrawable(ResourcesImpl.java:659) 
        at android.content.res.Resources.getDrawableForDensity(Resources.java:906) 
        at android.content.res.Resources.getDrawable(Resources.java:845) 
        at android.content.res.Resources.getDrawable(Resources.java:820) 
        at androidx.mediarouter.app.MediaRouteButton$b.doInBackground(:1) 
        ...
     Caused by: java.lang.ClassNotFoundException: Didn't find class "x" on path: DexPathList[[zip file "/data/app/com.sample.
{% endhighlight %}

The problem - R8 assumes these **mr_*resources** (media router) are unused and are skipped to be included with the build. Hence, while accessing them via reflection in the code by the `Cast SDK` it fails.

#### How can we fix it?

As stated in the [Android developers documentation]( https://developer.android.com/studio/build/shrink-code#keep-resources){:target="_blank"} 


> res/raw/keep.xml

{% highlight xml  %}
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/mr_*" />
{% endhighlight %}

The above xml tell the gradle plugin not to shrink resources of this kind. 

#### How can we verify this? 


> run ./gradlew clean bundleStageRelease --info >> output.txt

- Search around the file, if skip unsed is been shown for **mr_** files.

- Now go back add the **keep.xml** file and repeat the same. 

I hope it helps!

<hr>

#### References

- [Android Developers](https://developer.android.com/studio/build/shrink-code#keep-code){:target="_blank"}
- [Stack Overflow](https://stackoverflow.com/questions/43838269/android-how-to-tell-shrinkresources-to-keep-certain-resources){:target="_blank"}