---
layout: post
title:  "Basics of Easing Animations in android"
date:   2015-11-12 14:34:25
categories: android
tags: android, easing, animation
image: /assets/article_images/easing-animations-android/bg.gif

--- 

An easing function describes the value of a property given a percentage of completeness. Thanks to [Robert Penner][robertpenner] for defining equations which drove animations with ease. 

---

How do we do this android ? First lets see how we do animations with ValueAnimator.

#### Setting up Activity


> app/package.name/MainActivity.java

{% highlight javascript %}
Button click;
View view;
@Override
protected void onCreate(Bundle savedInstanceState) {
	super.onCreate(savedInstanceState);
	setContentView(R.layout.activity_main);
	Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
	view = (View)findViewById(R.id.view);
	click = (Button)findViewById(R.id.button);
	click.setOnClickListener(clickListener);
}
View.OnClickListener clickListener = new View.OnClickListener() {
	@Override
	public void onClick(View v) {
    	ease();      
    }
};
{% endhighlight %}

Our XML layout

{% highlight markup %}
<View
    android:id="@+id/view"
    android:layout_width="80dp"
    android:layout_height="80dp"
    android:background="@android:color/holo_blue_bright"/>
<Button
    android:id="@+id/button"
    android:text="Click"
    android:layout_width="match_parent"
    android:layout_alignParentBottom="true"
    android:layout_height="60dp"/>
{% endhighlight %}

---

#### Setup simple Animation

[ValueAnimator][valueanimator] class provides a simple timing engine for running animations which calculate animated values and set them on target objects .
[AnimatorSet][animatorset] class plays a set of Animator objects in the specified order. Animations can be set up to play together, in sequence, or after a specified delay.

We will be using these two classes to make our first animation.
> app/package.name/MainActivity.java

{% highlight javascript %}
private void ease() {
	AnimatorSet animatorSet = new AnimatorSet();
	ValueAnimator valueAnimatorX = ValueAnimator.ofFloat(fromX,toX, fromX);
	valueAnimatorX.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
		@Override
		public void onAnimationUpdate(ValueAnimator animation) {
			view.setTranslationX((float) animation.getAnimatedValue());
		}
	});
	animatorSet.playTogether(valueAnimatorX);
	animatorSet.setDuration(1500);
	animatorSet.start();
}
{% endhighlight %}

<center> ![Linear Animation](/assets/article_images/easing-animations-android/linear.gif)</center>


This animations seems so boring. We need somthing cool.

---

#### Easing to make it awesome

[ValueAnimator][valueanimator] class accepts an evaluator, which defines on how the value is derived. So we make use of `setEvaluator` function and put our easing equations there to get the desired animation.

So make a class `Easing` implementing TypeEvaluator
> app/package.name/Easing.java

{% highlight javascript %}
public class Easing implements TypeEvaluator<Number> {
	@Override
    public Number evaluate(float fraction, Number startValue, Number endValue) {
    }
}
{% endhighlight %}

Now we have the evaluate methods which tell the `ValueAnimator` on how it should evaluate.
> app/package.name/Easing.java



{% highlight javascript %}
/**  
* Converts params to calculate easing values
* @param fraction
* @param startValue
* @param endValue
* @return
*/

@Override
public Number evaluate(float fraction, Number startValue, Number endValue) {
	float t = duration * fraction;
	float b = startValue.floatValue();
	float c = endValue.floatValue() - startValue.floatValue();
	float d = duration;
	float result = calculate(t,b,c,d);
	return result;

}
{% endhighlight %}


What's the calculate method here? 
This method decides which easing equation we are going to use. There is a lot mentioned about equations [here][gizma-easing-equations]. You can edit this method based on any of the equations given and get your desired animation.
> app/package.name/Easing.java


{% highlight javascript %}
/**
* @param t - Current Time
* @param b - Start Value
* @param c - Change in value
* @param d - Duration
* @return value calculated for cubic ease-in-out
*/

public float calculate(float t, float b, float c, float d){
	t /= d/2;
	if (t < 1) {
		return c/2*t*t*t + b;
	}
	t -= 2;
	return c/2*(t*t*t + 2) + b;
}
{% endhighlight %}

---

#### Update MainAcvitity

Now we are good with the `Easing` class and ready to include it in our `ValueAnimator`.
> app/package.name/MainActvity.java

{% highlight javascript %}
private void ease() {
	Easing easing = new Easing(1500);
	...
	valueAnimatorX.setEvaluator(easing);
	valueAnimatorX.addUpdateListener(...)
	...
}
{% endhighlight %}

Uh! is that enough ? 


|---|---|
|![Linear Animation](/assets/article_images/easing-animations-android/linear.gif) |  ![Easing Animation](/assets/article_images/easing-animations-android/ease.gif)|


---

Find the source code of the entire sample over here, [Easing on Android][easing-android].

[AnimationEasingFunctions][easing-library] seems an awesome library to make easing animatons easier and lively.


[robertpenner]:https://www.linkedin.com/in/robertpenner
[valueanimator]:http://developer.android.com/reference/android/animation/ValueAnimator.html
[animatorset]:http://developer.android.com/reference/android/animation/AnimatorSet.html
[gizma-easing-equations]:http://gizma.com/easing/
[easing-android]:https://github.com/shrikanthkr/SimpleEasingAndroid
[easing-library]:https://github.com/daimajia/AnimationEasingFunctions
