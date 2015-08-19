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
	
	public static void sendThresholdNotification() 
	{
		Context context = TiApplication.getInstance();
		Uri alarmTone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);
		Ringtone ringtoneManager = RingtoneManager.getRingtone(context, alarmTone);
		if (ringtone != null) {
			ringtone.stop();
		}
		ringtone = ringtoneManager;
		ringtone.play();

		Intent notificationIntent = new Intent(context, AlarmService.class);
		PendingIntent pendingIntent = PendingIntent.getService(context, 0, notificationIntent, 0);

		NotificationCompat.Builder builder = new NotificationCompat.Builder(context).setWhen(System.currentTimeMillis())
				.setSmallIcon(R.drawable.ic_dialog_alert).setContentTitle("Cocción finalizada")
				.setContentText("Ha finalizado la cocción. Haga click para descartar la alarma.")
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
}
