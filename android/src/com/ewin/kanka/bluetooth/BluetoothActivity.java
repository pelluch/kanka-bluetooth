package com.ewin.kanka.bluetooth;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;


public class BluetoothActivity extends Activity {

	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		Utils.log("On activity result? " + resultCode);
		Utils.log("On activity request? " + requestCode);
	
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
		Utils.log("Got here");
		super.onCreate(savedInstanceState);		
		KankaBluetoothModule.bleManager.turnOnWithIntent(this, code);
	}
}
