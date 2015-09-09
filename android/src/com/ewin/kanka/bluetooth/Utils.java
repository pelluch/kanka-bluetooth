package com.ewin.kanka.bluetooth;

import java.util.concurrent.atomic.AtomicInteger;

import org.appcelerator.titanium.TiApplication;
import android.R;
import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.support.v4.app.NotificationCompat;

public class Utils {

	private final static AtomicInteger notificationCounter = new AtomicInteger(0);
	private static Ringtone ringtone;
	
	public static Ringtone getRingtone() 
	{
		return ringtone;
	}
	
	public static void sendThresholdNotification(boolean isPrealarm, String title, 
			String message, String uniqueId) 
	{
		Context context = TiApplication.getInstance();
		if(!isPrealarm) {
			Uri alarmTone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);
			Ringtone ringtoneManager = RingtoneManager.getRingtone(context, alarmTone);
			if (ringtone != null) {
				ringtone.stop();
			}
			ringtone = ringtoneManager;
			ringtone.play();
		}
		
		Intent notificationIntent = new Intent(context, AlarmService.class);
		notificationIntent.putExtra("uniqueId", uniqueId);
		notificationIntent.putExtra("isPrealarm", isPrealarm);
		PendingIntent pendingIntent = PendingIntent.getService(context, 0, notificationIntent,
				PendingIntent.FLAG_UPDATE_CURRENT);

		NotificationCompat.Builder builder = new NotificationCompat.Builder(context).setWhen(System.currentTimeMillis())
				.setSmallIcon(R.drawable.ic_dialog_alert).setContentTitle(title)
				.setContentText(message)
				.setContentIntent(pendingIntent);

		Notification notification = builder.build();
		notification.flags = Notification.FLAG_AUTO_CANCEL | Notification.FLAG_SHOW_LIGHTS;

		NotificationManager manager = (NotificationManager) context.getSystemService(Activity.NOTIFICATION_SERVICE);
		manager.notify(notificationCounter.incrementAndGet(), notification);

	}
	
	public static void stopRingtone()
	{
		if (ringtone != null && ringtone.isPlaying()) 
		{
			ringtone.stop();
		}
	}
	
	public static void log(String message)
	{
		if(KankaBluetoothModule.VERBOSE_LOG)
		{
			android.util.Log.d(KankaBluetoothModule.LCAT, message);
		}
	}
}
