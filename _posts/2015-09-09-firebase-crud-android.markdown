---
layout: post
title:  "CRUD on Android with Firebase API"
date:   2015-09-09 14:34:25
categories: android
tags: android, firebase, firebase android, firebase sdk
image: /assets/article_images/firebase-crud-android/bg.jpg

--- 

Firebase provides a powerful API to **store, retrieve and sync** data in realtime, which paves way for an accelerated development reducing the pain of setting up your backend. In this post we will get a quick glance of making a CRUD with [Firebase Android SDK][firebase-android]. Firebase also provides you with a [Quick Start][firebase-quick-start] guide to get on with its SDKs. 

---

Once you have an account with [Firebase][firebase], create an `app` and note down the `app's` URL. This `app` URL will be used in our android application as the base URL to firebase.

#### Adding Dependencies


> app/build.gradle
{% highlight javascript%}
dependencies {
	compile 'com.firebase:firebase-client-android:2.3.1+'
}
{% endhighlight %}

Incase you end up with build errors, 

{% highlight javascript %}
android {
	...
	packagingOptions {
	exclude 'META-INF/LICENSE'
	exclude 'META-INF/LICENSE-FIREBASE.txt'
	exclude 'META-INF/NOTICE'
	}
}
{% endhighlight %}

---

#### Adding Permissions

> app/src/main/AndroidManifest.xml 
{% highlight markup %}
<uses-permission android:name="android.permission.INTERNET" />
{% endhighlight %}

---

#### Necessary Layout Components

Two `EditText` components,  a `ListView` and a `Button`. These `EditText` components holds the `name`(key) and the `message`(value) to be saved. `Button` is used to trigger the save action using **Firebase** sdk and a `ListView` to display the data.
{% highlight markup %}
<EditText
	android:layout_width="fill_parent"
	android:layout_height="60dp"
	android:hint="Enter Name"
	android:id="@+id/name"
	android:layout_marginTop="10dp"
	android:layout_alignParentLeft="true"
	android:layout_alignParentStart="true"/>
<EditText
	android:layout_width="fill_parent"
	android:layout_height="60dp"
	android:hint="Enter Message"
	android:layout_marginTop="10dp"
	android:id="@+id/message"
	android:layout_below="@+id/name"/>
<Button
	android:layout_width="wrap_content"
	android:layout_height="wrap_content"
	android:text="Save"
	android:id="@+id/save"
	android:layout_below="@+id/message"
	android:layout_marginTop="10dp"
	android:layout_centerHorizontal="true"/>
<ListView
	android:layout_width="wrap_content"
	android:layout_height="fill_parent"
	android:id="@+id/listView"
	android:layout_below="@+id/save"
	android:layout_alignParentLeft="true"
	android:layout_alignParentStart="true"/>

{% endhighlight %}

---

#### Saving data on Firebase - Create

Declare necessary attributes.

{% highlight javascript %}
Button save;
static Firebase myFirebaseRef;
EditText nameEditText;
EditText messageEditText;
ProgressBar progressBar;
static final String TAG = "Main Acvity";
ArrayAdapter<String> valuesAdapter;
ArrayList<String> displayArray;
ArrayList<String> keysArray;
ListView listView;
{% endhighlight %}

The OnCreate Function

{% highlight javascript %}
@Override
protected void onCreate(Bundle savedInstanceState) {
	super.onCreate(savedInstanceState);
	setContentView(R.layout.activity_main);

	/*View bindings*/
	save = (Button)findViewById(R.id.save);
	nameEditText = (EditText)findViewById(R.id.name);
	messageEditText= (EditText)findViewById(R.id.message);
	progressBar = (ProgressBar)findViewById(R.id.progressBar);
	listView = (ListView)findViewById(R.id.listView);

	/*Variable Initialization*/
	displayArray  = new ArrayList<>();
	keysArray = new ArrayList<>();
	valuesAdapter = new ArrayAdapter<String>(this,android.R.layout.simple_list_item_1,android.R.id.text1,displayArray);
	listView.setAdapter(valuesAdapter);
	/*listView.setOnItemClickListener(itemClickListener);*/
	save.setOnClickListener(this);

	/*Firebase Initialization*/
	Firebase.setAndroidContext(this);
	myFirebaseRef = new Firebase("<appurl>");
	/*myFirebaseRef.addChildEventListener(childEventListener);*/
}
{% endhighlight %}

Adding click Listener to fire save action

{% highlight javascript %}
@Override
public void onClick(View v) {
	switch (v.getId()){
		case R.id.save:
			String nameString = nameEditText.getText().toString();
			String messageString = messageEditText.getText().toString();
			save(nameString,messageString);
		break;
	}
}

private void save(String name,String message){
	myFirebaseRef.child(name).setValue(message, new Firebase.CompletionListener() {
		@Override
		public void onComplete(FirebaseError firebaseError, Firebase firebase) {
			nameEditText.setText("");
			messageEditText.setText("");
		}
	});
}
{% endhighlight %}

We have saved our data to firebase and on our onComplete method above we empty the `edittext` boxes. So where do we actually read our data and update the view?

---



#### Read data from Firebase - Read

**Firebase** provides a ChildEventListener which pops up when ever a change occurs to the specified child to which the event is bound. In our case we bind it to the `myFirebaseRef`, which is commented out initially on our `onCreate` method. 

Events which we could listen to are `onChildAdded`, `onChildChanged`, `onChildRemoved`, `onChildMoved`, `onCancelled`. 

{% highlight javascript %}
ChildEventListener childEventListener = new ChildEventListener() {
	@Override
	public void onChildAdded(DataSnapshot dataSnapshot, String s) {
		Log.d(TAG, dataSnapshot.getKey() + ":" + dataSnapshot.getValue().toString());
		String keyAndValue = "Key: " +dataSnapshot.getKey().toString() + "\t Value: " +  	dataSnapshot.getValue().toString();
		displayArray.add(keyAndValue);
		keysArray.add(dataSnapshot.getKey().toString());
		updateListView();
	}
	@Override
	public void onChildChanged(DataSnapshot dataSnapshot, String s) {}
	@Override
	public void onChildRemoved(DataSnapshot dataSnapshot) {}
	@Override
	public void onChildMoved(DataSnapshot dataSnapshot, String s) { }
	@Override
	public void onCancelled(FirebaseError firebaseError) {}
};

private void updateListView(){
	valuesAdapter.notifyDataSetChanged();
	listView.invalidate();
	Log.d(TAG, "Length: " + displayArray.size());
}
{% endhighlight %}

Whenever a new child is added `onChildAdded` will get triggered and the view is updated corresponding to the received data.

--- 

#### Listen for changes in the child - Update

As we had seen, the above code provides a method to listen on changes made to the child data. We update our code on `onChildChanged` method to publish updates and show it to the user.

{% highlight javascript %}
@Override
public void onChildChanged(DataSnapshot dataSnapshot, String s) {
	String changedKey = dataSnapshot.getKey();
	int changedIndex = keysArray.indexOf(changedKey);
	String keyAndValue = "Key: " +dataSnapshot.getKey().toString() + "\t Value: " + dataSnapshot.getValue().toString();
	displayArray.set(changedIndex,keyAndValue);
	updateListView();
}
{% endhighlight %}

---

#### Deleting a child - Delete

Now we uncomment `itemClickListener` for the listview. On click of an item in list view we delete the data based on the given `name`(Key).

{% highlight javascript %}
AdapterView.OnItemClickListener itemClickListener = new AdapterView.OnItemClickListener() {
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		String clickedKey = keysArray.get(position);
		myFirebaseRef.child(clickedKey).removeValue();
	}
};
{% endhighlight %}

And again we override the `onChildRemoved` function and update the view

{% highlight javascript %}
@Override
public void onChildRemoved(DataSnapshot dataSnapshot) {
	String deletedKey = dataSnapshot.getKey();
	int removedIndex = keysArray.indexOf(deletedKey);
	keysArray.remove(removedIndex);
	displayArray.remove(removedIndex);
	updateListView();
}
{% endhighlight %}

---

You can find the source code of the entire sample over here, [Firebase CRUD][firebase-crud] with few miscellaneous functions,
[firebase]:https://www.firebase.com/
[firebase-android]:https://www.firebase.com/docs/android/
[firebase-quick-start]:https://www.firebase.com/docs/android/quickstart.html
[firebase-crud]:https://github.com/shrikanthkr/FirebaseCRUD
