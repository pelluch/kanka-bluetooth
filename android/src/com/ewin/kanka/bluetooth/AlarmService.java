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
	protected void onHandleIntent(Intent arg0) {
		// TODO Auto-generated method stub
		Ringtone ringtone = KankaBluetoothModule.getRingtone();
		android.util.Log.d("TiAPI", "Clicked on notification");
		if(ringtone != null)
		{
			ringtone.stop();
		}
	}

}
