package com.ewin.kanka.bluetooth;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;


public class BluetoothActivity extends Activity {

	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		Log.d(KankaBluetoothModule.LCAT, "On activity result? " + resultCode);
		Log.d(KankaBluetoothModule.LCAT, "On activity request? " + requestCode);
	
		setResult(resultCode, data);
		finish();
	}
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		Intent i = getIntent();
        Bundle extras = i.getExtras();
		int code = extras.getInt("CODE");
		Log.d(KankaBluetoothModule.LCAT, "Got here");
		super.onCreate(savedInstanceState);		
		KankaBluetoothModule.bleManager.turnOnWithIntent(this, code);
	}
}
