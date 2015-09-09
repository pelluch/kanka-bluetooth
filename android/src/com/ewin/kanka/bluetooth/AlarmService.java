package com.ewin.kanka.bluetooth;

import android.app.IntentService;
import android.content.Intent;
import android.media.Ringtone;

public class AlarmService extends IntentService {

	public AlarmService() {
		super("AlarmService");
		// TODO Auto-generated constructor stub
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		// TODO Auto-generated method stub
		Ringtone ringtone = Utils.getRingtone();
		String uniqueId = intent.getStringExtra("uniqueId");
		boolean isPrealarm = intent.getBooleanExtra("isPrealarm", false);
		Utils.log("Clicked on notification for uniqueId " + uniqueId +
				" with playAlarm = " + isPrealarm);
		KankaBluetoothModule.acknowledgeAlarmFromNotification(uniqueId, isPrealarm);
		if(ringtone != null && !isPrealarm)
		{
			ringtone.stop();
		}
	}

}
