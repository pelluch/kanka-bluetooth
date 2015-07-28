/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package com.ewin.kanka.bluetooth;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiActivityResultHandler;
import org.appcelerator.titanium.util.TiActivitySupport;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.media.MediaPlayer;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;

import com.idevicesinc.device.iDevice;
import com.idevicesinc.device.iDeviceBle;
import com.idevicesinc.device.iDeviceManager;
import com.idevicesinc.device.iDevice.Listener.Event;
import com.idevicesinc.device.iDeviceManager.Listener;
import com.idevicesinc.device.iDeviceManagerConfig;
import com.idevicesinc.device.iGrill;
import com.idevicesinc.device.iGrillTempUnit;
import com.idevicesinc.device.iProbe;
import com.idevicesinc.device.iProbe.PreAlarmState;
import com.idevicesinc.device.metadata.Kanka;
import com.idevicesinc.sweetblue.BleDevice;
import com.idevicesinc.sweetblue.BleDevice.ConnectionFailListener.Status;
import com.idevicesinc.sweetblue.BleDeviceIterator;
import com.idevicesinc.sweetblue.BleDeviceState;
import com.idevicesinc.sweetblue.BleManager;

@Kroll.module(name="KankaBluetooth", id="com.ewin.kanka.bluetooth")
public class KankaBluetoothModule extends KrollModule
implements TiActivityResultHandler
{

	// Standard Debugging variables
	public static final String LCAT = "TiAPI";
	private static Random random = new Random();
	private static final boolean DBG = TiConfig.LOGD;
	private iDeviceManager deviceManager;
	public static BleManager bleManager;
	private int requestCode;
	private HashMap<String, iDevice> devices = new HashMap<String, iDevice>();
	private HashMap<String, HashMap<String, Object>> testDevices = 
			new HashMap<String, HashMap<String, Object>>();
	private boolean test = false;

	// You can define constants with @Kroll.constant, for example:
	// @Kroll.constant public static final String EXTERNAL_NAME = value;

	public KankaBluetoothModule()
	{
		super();
	}


	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
		Log.d(LCAT, "inside onAppCreate");
		// put module init code that needs to run when the application is created

	}


	@Override
	public void onDestroy(Activity activity) {
		Log.d(LCAT, "Module on destroy");
		// TODO Auto-generated method stub
		super.onDestroy(activity);

		if(test == true) 
		{

		}
		else
		{
			Iterator it = devices.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry<String, iDevice> pair = (Map.Entry<String, iDevice>)it.next();
				pair.getValue().disconnect();
			}			
		}

		bleManager.stopScan();
		bleManager.disconnectAll();
		bleManager.undiscoverAll();			
		bleManager.reset();
	}

	@Override
	public void onResume(Activity activity) {
		// TODO Auto-generated method stub
		super.onResume(activity);

		/*if(bleManager != null) {
			bleManager.onResume();
		}*/
		Log.d(LCAT, "module onResume");
	}


	@Override
	public void onStart(Activity activity) {
		// TODO Auto-generated method stub
		super.onStart(activity);
		Log.d(LCAT, "module onStart");
	}

	@Override
	public void onPause(Activity activity) {
		// TODO Auto-generated method stub
		super.onPause(activity);
		/*if(bleManager != null) {
			bleManager.onPause();
		}*/
		Log.d(LCAT, "module onPause");
	}

	@Override
	public void onStop(Activity activity) {
		// TODO Auto-generated method stub
		super.onStop(activity);
		Log.d(LCAT, "module onStop");
	}
	@Kroll.method
	public void disconnectDevice(String uniqueId) 
	{
		if(test == true) 
		{

			HashMap<String, Object> testDevice = testDevices.get(uniqueId);
			if(testDevice != null) 
			{
				KrollFunction onDisconnect = (KrollFunction)testDevice.get("onDisconnect");
				Timer timer = (Timer)testDevice.get("timer");
				if(timer != null) {
					timer.cancel();
				}
				onDisconnect.call(getKrollObject(), new HashMap<String, Object>());
			}

		}

		iDevice device = devices.get(uniqueId);
		if(device != null) 
		{
			device.disconnect();
		}
	}

	@Kroll.method
	public void connectDevice(String uniqueId, KrollDict params) 
	{

		final KrollFunction tempCallback = (KrollFunction)params.get("onTemperatureChange");
		final KrollFunction thresholdCallback = (KrollFunction)params.get("onThreshold");
		final KrollFunction alarmCallback = (KrollFunction)params.get("onAlarmAcknowledge");
		final KrollFunction preAlarmCallback = (KrollFunction)params.get("onPrealarmStateChange");
		final KrollFunction connectCallback = (KrollFunction)params.get("onConnect");
		final KrollFunction disconnectCallback = (KrollFunction)params.get("onDisconnect");

		final Integer lowThreshold = (Integer)params.get("lowThreshold");
		final Integer highThreshold = (Integer)params.get("highThreshold");
		final Integer preAlarmDelta = (Integer)params.get("preAlarmDelta");




		if(test == true)
		{
			final HashMap<String, Object> testDevice = testDevices.get(uniqueId);
			if(testDevice != null) 
			{
				testDevice.put("onDisconnect", disconnectCallback);
				testDevice.put("onTemperatureChange", tempCallback);
				testDevice.put("temperature", 80);
				connectCallback.call(getKrollObject(), new HashMap<String, Object>());
				final Timer timer = new Timer();
				testDevice.put("timer", timer);
				Log.d(LCAT, "Scheduling");
				timer.scheduleAtFixedRate(new TimerTask() {

					@Override
					public void run() {
						Log.d(LCAT, "Running Scheduling");
						int temp = (Integer)testDevice.get("temperature");						
						HashMap<String, Object> map = new HashMap<String, Object>();
						map.put("temperature", temp);
						tempCallback.call(getKrollObject(), map);
						temp += random.nextInt(20) -10;
						if(temp > 200) {
							temp = 200;
						} else if(temp < 0) {
							temp = 0;
						}
						testDevice.put("temperature", temp);
					}
				}, 0, 5*1000);

			}
		}
		else 
		{
			iDevice device = devices.get(uniqueId);
			if(device != null) 
			{

				final iGrill igrill = (iGrill) device;

				final int low, high;
				final short delta;

				igrill.getProbe(0).clearThresholds();

				// igrill.setTempUnit(iGrillTempUnit.C);

				if(lowThreshold != null) {
					Log.d(LCAT, "Setting low to " + lowThreshold.intValue());
					low = lowThreshold.intValue();					
				} else {
					low = 0;
				}


				if(highThreshold != null) {
					Log.d(LCAT, "Setting high to " + highThreshold.intValue());
					high = highThreshold.intValue();					
				} else {
					high = 100;
				}

				if(preAlarmDelta != null) {
					Log.d(LCAT, "Setting preAlarmDelta to " + preAlarmDelta.shortValue());
					delta = preAlarmDelta.shortValue();
				} else {
					delta = 0;
				}

				// igrill.getProbe(0).setThresholds(low, high);
				// igrill.getProbe(0).setPreAlarmDelta(delta);

				igrill.setProbeListener(new iProbe.Listener()
				{
					@Override public void onProbeEvent(final iProbe probe, Event event)
					{

						int currentTemp = igrill.getProbe(0).getCurrentTemp();

						// Whenever the temperature changes, refresh the temperature, thresholds, and pre-alarm delta elements in the GUI
						if(event == Event.TEMPERATURE_CHANGED)
						{



							HashMap<String, Object> map = new HashMap<String, Object>();
							map.put("temperature", currentTemp);
							map.put("event_type", "TEMPERATURE_CHANGED");
							if(tempCallback != null) {
								tempCallback.call(getKrollObject(), map);
							}
						}
						else if(event == Event.THRESHOLD_REACHED) 
						{
							if(thresholdCallback != null) {
								HashMap<String, Object> map = new HashMap<String, Object>();
								map.put("temperature", currentTemp);
								map.put("event_type", "THRESHOLD_REACHED");
								thresholdCallback.call(getKrollObject(), map);
							}
						}
						else if(event == Event.ALARM_ACKNOWLEDGED) 
						{
							if(alarmCallback != null) {
								HashMap<String, Object> map = new HashMap<String, Object>();
								map.put("event_type", "ALARM_ACKNOWLEDGED");
								map.put("temperature", currentTemp);
								alarmCallback.call(getKrollObject(), map);
							}
						}
						else if(event == Event.PRE_ALARM_STATE_CHANGED) 
						{
							if(preAlarmCallback != null) {

								PreAlarmState state = igrill.getProbe(0).getPreAlarmState();
								HashMap<String, Object> map = new HashMap<String, Object>();
								if(state == PreAlarmState.ACKNOWLEDGED_OR_REDUNDANT)
								{
									map.put("state", "ACKNOWLEDGED_OR_REDUNDANT");
								}
								else if(state == PreAlarmState.ACTIVE)
								{
									map.put("state", "ACTIVE");
								}
								else if(state == PreAlarmState.NOT_ACTIVE)
								{
									map.put("state", "NOT_ACTIVE");
								}
								map.put("event_type", "PRE_ALARM_STATE_CHANGED");

								map.put("temperature", currentTemp);
								preAlarmCallback.call(getKrollObject(), map);
							}
						}
					}

				});	

				igrill.setListener(new iGrill.Listener() {

					@Override
					public void onConnectionFailed(iDeviceBle arg0, Status arg1) {
						// TODO Auto-generated method stub

					}

					@Override
					public void onConnectionFailedWithRetries(iDeviceBle arg0,
							Status arg1) {
						// TODO Auto-generated method stub

					}

					@Override
					public void onDeviceStateChange(iDeviceBle arg0, int arg1,
							int arg2, int arg3) {
						// TODO Auto-generated method stub

					}

					@Override
					public void onDeviceStateChangeForView(iDeviceBle device,
							BleDeviceState state) {
						if(state == BleDeviceState.CONNECTING)
						{
							Log.d(LCAT, "CONNECTING");

						}
						else if(state == BleDeviceState.DISCOVERING_SERVICES)
						{
							Log.d(LCAT, "DISCOVERING_DEVICES");
						}
						else if(state == BleDeviceState.AUTHENTICATING)
						{
							Log.d(LCAT, "AUTHENTICATING");
						}
						else if(state == BleDeviceState.INITIALIZING)
						{
							Log.d(LCAT, "INITIALIZING");
						}
						// When the initialized state is reached, the app hass fully connected to the thermometer via BLE
						else if(state == BleDeviceState.INITIALIZED)
						{
							Log.d(LCAT, "INITIALIZED");
							iDevice connected = devices.get(device.getUniqueId());
							if(connected != null)
							{
								iGrill grill = (iGrill)connected;
								grill.setTempUnit(iGrillTempUnit.C);
								grill.getProbe(0).setThresholds(low, high);
								grill.getProbe(0).setPreAlarmDelta(delta);

							}
							if(connectCallback != null) {
								HashMap<String, Object> map = new HashMap<String, Object>();
								connectCallback.call(getKrollObject(), map);
							}

							int currentTemp = igrill.getProbe(0).getCurrentTemp();
							if(currentTemp > -1000) {
								HashMap<String, Object> map = new HashMap<String, Object>();
								map.put("temperature", currentTemp);
								map.put("event_type", "TEMPERATURE_CHANGED");
								if(tempCallback != null) {
									tempCallback.call(getKrollObject(), map);
								}
							}


						}
						else if(state == BleDeviceState.DISCONNECTED)
						{
							Log.d(LCAT, "DISCONNECTED");
							if(disconnectCallback != null) {
								HashMap<String, Object> map = new HashMap<String, Object>();
								disconnectCallback.call(getKrollObject(), map);
							}

						}
						else if(state == BleDeviceState.RECONNECTING_LONG_TERM)
						{
							Log.d(LCAT, "ATTEMPTING_RECONNECT");
						}

					}

					@Override
					public void onDeviceEvent(iDevice device, Event event) {
						if(event == Event.BATTERY_LEVEL_UPDATED)
						{
							if(igrill.hasBatteryLevel())
							{
								// Do something
							}
						}
						// After connecting to a device, it takes a few moments to read the firmware version from the device.  When the firmware version is
						// successfully read, the device event FIRMWARE_VERSION_AVAILABLE occurs.
						else if(event == Event.FIRMWARE_VERSION_AVAILABLE)
						{

							if(igrill.isFirmwareUpdateAvailable())
							{
								// Normally, this is where you can check if there are any firmware updates available,
								// and if so, call device.updateFirmware().  However, for the purposes of this sample app,
								// we simply added an "Update Firmware" button so you can force the firmware update.
							}
						}
						else if(event == Event.FIRMWARE_UPDATE_STARTED)
						{

						}
						else if(event == Event.FIRMWARE_UPDATE_PROGRESS)
						{

						}
						else if(event == Event.FIRMWARE_UPDATE_COMPLETED)
						{

						}
						else if(event == Event.FIRMWARE_UPDATE_FAILED)
						{

						}

					}

					@Override
					public void onConnectedProbeCountChanged(iGrill arg0) {
						// TODO Auto-generated method stub

					}


				});

				igrill.setTempUnit(iGrillTempUnit.C);
				device.connect();
			}
		}



	}


	private HashMap<String, Object> getDeviceMap(iDevice device, boolean discovered) 
	{
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("deviceName", device.getDeviceName());
		map.put("uniqueId", device.getUniqueId());
		map.put("discovered", discovered);
		return map;
	}

	private HashMap<String, Object> generateTestDevice(String uuid) 
	{
		HashMap<String, Object> map = new HashMap<String, Object>();
		// UUID uuid = UUID.randomUUID();

		map.put("deviceName", "Test device " + testDevices.size());
		map.put("uniqueId", uuid);
		map.put("discovered", true);
		testDevices.put(uuid, map);
		return map;
	}

	@Kroll.method
	public void setDeviceThreshold(String uniqueId, int temp)
	{

	}

	@Kroll.method
	public void startScan(KrollDict params) 
	{

		final KrollFunction onDiscover = (KrollFunction)params.get("onDiscover");
		final KrollFunction onUndiscover = (KrollFunction)params.get("onUndiscover");

		TiApplication appContext = TiApplication.getInstance();
		Activity activity = appContext.getCurrentActivity();
		TiActivitySupport support = (TiActivitySupport) activity;



		// Create a device manager, and give it a listener to listen for discovered/undiscovered devices
		iDeviceManagerConfig deviceManagerConfig = new iDeviceManagerConfig(new Kanka());

		deviceManager = iDeviceManager.get(activity, deviceManagerConfig);
		deviceManager.setListener(new Listener()
		{
			@Override public void onDeviceDiscovered(iDevice device)
			{
				Log.d(LCAT, "Device Discovered: " + device.getDeviceName());
				// updateDiscoveredDevicesList();

				devices.put(device.getUniqueId(), device);
				onDiscover.call(getKrollObject(), getDeviceMap(device, true));
			}

			@Override public void onDeviceUndiscovered(iDevice device)
			{
				Log.d(LCAT, "Device Undiscovered: " + device.getDeviceName());
				onUndiscover.call(getKrollObject(), getDeviceMap(device, false));
				// updateDiscoveredDevicesList();
			}
		});

		// Create a BLE manager
		bleManager = BleManager.get(appContext, deviceManagerConfig.newDefaultBleConfig());

		BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();


		if(bluetoothAdapter != null && !bluetoothAdapter.isEnabled())
		{	
			Log.d(LCAT, "Turning on");
			Intent bluetoothIntent = new Intent(activity, BluetoothActivity.class);

			Log.d(LCAT, "Created intent");
			// activity.startActivity(bluetoothIntent);
			requestCode = support.getUniqueResultCode();
			bluetoothIntent.putExtra("CODE", requestCode);
			support.launchActivityForResult(bluetoothIntent, requestCode, this);
			Log.d(LCAT, "Launched activity for result");

		}
		else
		{
			Log.d(LCAT, "Scanning");
			// Start scanning for devices

			bleManager.startScan(deviceManager);

			if(test == true) 
			{
				onDiscover.call(getKrollObject(), generateTestDevice("15f9ae61-7c0e-4ec8-bb4a-f393c5bd119a"));
				onDiscover.call(getKrollObject(), generateTestDevice("b5defc17-ea81-4f0c-a031-11f58b850393"));
				onDiscover.call(getKrollObject(), generateTestDevice("0f02f6a8-d97e-45e6-a8f1-d19bf5c7fbe1"));

				return;
			}

		}
	}

	@Kroll.getProperty
	public boolean getTest()
	{
		return this.test;
	}

	@Kroll.setProperty
	public void setTest(boolean test)
	{
		this.test = test;
	}

	@Override
	public void onError(Activity activity, int requestCode, Exception e) {
		// TODO Auto-generated method stub
		Log.d(LCAT, "Got an error");
	}

	@Override
	public void onResult(Activity activity, int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		Log.d(LCAT, "Am in onResult");
		Log.d(LCAT, "Result code is " + requestCode);
		Log.d(LCAT, "Resquest code is " + resultCode);
		if(requestCode == this.requestCode && resultCode == Activity.RESULT_OK)
		{
			// Start scanning for devices
			bleManager.startScan();

		}
	}
}

