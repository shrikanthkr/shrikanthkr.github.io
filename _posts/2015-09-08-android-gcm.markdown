---
layout: post
title:  "Basics of Android GCM"
date:   2015-09-08 14:34:25
categories: android
tags: android, gcm, google cloud messaging
image: /assets/article_images/borders-android/background.png

--- 

Google Cloud Messaging (GCM) is a service that enables developers to send data from servers to both `Android` applications or `Chrome` apps and extensions. [Wikipedia][wikipedia].

---

GCM basics involves four steps

+ Registering the client (Android Device)
+ Provide the registration ID to server
+ Send notifications from Server to GCM with registration ID
+ Receive notifications on the client

####Prerequisite 

- Project Number (_845696541232_)
- Server API Key (_XIzaSyBDRJ00YJbTE011CbWWjlcKYUGI3eLccdI_)

Refer to [Create Project][create-project] on creating a new project and [Generate API Key][server-key] for generating a Server key(API Key)

Once we have all the required data we can start with our client registration process.

####Creating a new Project

Ensure that we have the necessary dependencies added.

> app/build.gradle

{% prism javascript %}
dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    compile 'com.android.support:appcompat-v7:21.0.3'
    compile 'com.google.android.gms:play-services:6.5.87'
}
{% endprism %}

---

Adding Permissions
> app/src/main/Androidmanifest.xml

{% prism markup %}
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
	...
	<uses-permission android:name="android.permission.INTERNET" />
	<uses-permission android:name="android.permission.WAKE_LOCK" />
	<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
	<permission android:name="com.example.gcm.permission.C2D_MESSAGE" android:protectionLevel="signature" />
	<uses-permission android:name="com.example.gcm.permission.C2D_MESSAGE" />
	...      
</manifest>
{% endprism %}

---

####Registering the client (Android Device)

The client part has an interface with a registration button. On click of the button a call to GCM is made and `Registration ID` is obtained. While making the request it is necessary to note that we have the correct _**Project Number**_ from the developers console.

> res/layout/activity_main.xml

{% prism markup %}

<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
                xmlns:tools="http://schemas.android.com/tools"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:paddingLeft="@dimen/activity_horizontal_margin"
                android:paddingRight="@dimen/activity_horizontal_margin"
                android:paddingTop="@dimen/activity_vertical_margin"
                android:paddingBottom="@dimen/activity_vertical_margin"
                tools:context=".MainActivity">
    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Register"
        android:id="@+id/register"
        android:layout_below="@+id/textView"
        android:layout_centerHorizontal="true"
        android:layout_marginTop="117dp"/>

</RelativeLayout>

{% endprism %}

---

> src/main/java/.../MainActivity.java

Declaring necessary variables and functions

{% prism javascript %}
Button register_button;
String PROJECT_NUMBER = "845696541232";
GoogleCloudMessaging gcmObj;
String regId;

 protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    register_button = (Button) findViewById(R.id.register);
    register_button.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        registerInBackground();
      }
    });
{% endprism %}

---

Writing the registration function

{% prism javascript %}
private void registerInBackground() {
	new AsyncTask<Void, Void, String>() {
		@Override
		protected String doInBackground(Void... params) {
			String msg = "";
			try {
				gcmObj = GoogleCloudMessaging.getInstance(getApplicationContext());
				regId = gcmObj.register(PROJECT_NUMBER);
				msg = "Registration ID :" + regId;
			} catch (IOException ex) { msg = ex.getMessage();}
			return msg;
		}
		@Override
		protected void onPostExecute(String msg) {
			Toast.makeText(getApplicationContext(),"Registered with GCM Server successfully.\n\n"+ msg, Toast.LENGTH_SHORT).show();
			Log.d("MainActivity", regId);
		}
	}.execute(null, null, null);
}
{% endprism %}

---

####Provide the registration ID to server

Once the registration is successful,  `Registration ID` is obtained. This `Registration ID` is used by the server to send notifications to device. In our sample the `Registration ID` printed in logs is copied and used in the server part.

####Send notifications from Server to GCM with _Registration ID_ (Server Part)

The sample server code here is written in Nodejs. Using `node-gcm` library we can easily send messages to **GCM**. The server part includes two files. 

+ package.json
+ node-gcm-sample.js

> package.json

{% prism javascript %}
{
  "dependencies": {
    "node-gcm": "git+https://github.com/ToothlessGear/node-gcm.git"
  }
}
{% endprism%}

---

> node-gcm-sample.js

{% prism javascript %}
var gcm = require('node-gcm');
var message = new gcm.Message();
message.addData('key1', 'Awesome World!!'); /*Message to the client*/

var regIds = ['COPIED_ID_FROM_ANDROID_LOGS'];
var sender = new gcm.Sender('SERVER_API_KEY');

sender.send(message, { registrationIds: regIds } , function (err, result) {
  if(err) console.error(err);
  else    console.log(result);
});

{% endprism%}

---

Create both the files in a project folder, and execute `npm install`


####Receive notifications on the client

Now we enter into the last part of preparing our client to receive notifications. We have to intimate the client to listen for notifications using a `Receiver` and a `Service` to handle the data from server.

> src/main/java/.../GCMReceiver.java

Receiver code stating the necessary service `(GCMIntentService)` to be triggered.

{% prism javascript %}
public class GCMReceiver extends WakefulBroadcastReceiver{
	@Override
	public void onReceive(Context context, Intent intent) {
		ComponentName comp = new ComponentName(context.getPackageName(),GCMIntentService.class.getName());
		startWakefulService(context, (intent.setComponent(comp)));
		setResultCode(Activity.RESULT_OK);
	}
}
{% endprism %}

---

Update Androidmanifest

> app/src/main/Androidmanifest.xml

{% prism markup %}
<receiver
	android:name=".GCMReceiver"
	android:exported="true"
	android:permission="com.google.android.c2dm.permission.SEND" >
	<intent-filter>
		<action android:name="com.google.android.c2dm.intent.RECEIVE" />
		<category android:name="com.example.gcm" />
	</intent-filter>
</receiver>
{% endprism %}

---

> src/main/java/.../GCMReceiver.java

Service code for handling the notifications part. Here `MESSAGE_KEY` is the expected key that is set from the server. 

{% prism javascript %}
public class GCMIntentService extends IntentService {
	String MESSAGE_KEY = "key1";
	public GCMIntentService() {
		super("Message");
	}
	@Override
	protected void onHandleIntent(Intent intent) {
		Bundle extras = intent.getExtras();
		String message = intent.getStringExtra(MESSAGE_KEY);
		GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
		String messageType = gcm.getMessageType(intent);
		final int notificationID = (int) (Math.random() * 100000000);

		if (GoogleCloudMessaging.MESSAGE_TYPE_SEND_ERROR.equals(messageType)) {
			sendNotification("GCM notification: Send error" + extras.toString(), notificationID);
		}else if (GoogleCloudMessaging.MESSAGE_TYPE_DELETED.equals(messageType)) {
			sendNotification("Deleted messages on server" + extras.toString(), notificationID);
		}else if (GoogleCloudMessaging.MESSAGE_TYPE_MESSAGE.equals(messageType)) {
			sendNotification(message, notificationID);
		}
		GCMReceiver.completeWakefulIntent(intent);
	}

	private void sendNotification(String msg, int notificationID) {
		NotificationCompat.Builder builder = new NotificationCompat.Builder(this)
		.setSmallIcon(R.drawable.common_ic_googleplayservices);
		.setContentTitle("Notification");
		.setContentText(msg);
		Intent resultIntent = new Intent(this, MainActivity.class);
		PendingIntent resultPendingIntent = PendingIntent.getActivity(this,0,resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);
		NotificationManager mNotifyMgr = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
		mNotifyMgr.notify(notificationID, builder.build());
	}
}

{% endprism %}

---

Update Androidmanifest

> app/src/main/Androidmanifest.xml

{% prism markup %}
<service
	android:name=".GCMIntentService"
	android:exported="false" >
	<intent-filter>
		<action android:name="com.google.android.c2dm.intent.RECEIVE" />
	</intent-filter>
</service>
{% endprism %}

---

Now we are ready to check if our GCM component is working. Run the app in a device connected to internet, and open your server project folder from termial. Run `node node-gcm-sample.js`.Source code for [Android Client][client-code] and [Node Server][server-code]

[wikipedia]:https://en.wikipedia.org/wiki/Google_Cloud_Messaging
[create-project]:https://developers.google.com/console/help/new/#creatingdeletingprojects
[server-key]:https://developers.google.com/console/help/new/#api-keys
[client-code]:https://github.com/shrikanthkr/android-gcm-client
[server-code]:https://github.com/shrikanthkr/node-gcm-sample
