package com.ewin.kanka.bluetooth;

import java.util.HashMap;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollObject;
import org.appcelerator.kroll.common.Log;

import com.idevicesinc.device.iDevice;
import com.idevicesinc.device.iDeviceBle;
import com.idevicesinc.device.iGrill;
import com.idevicesinc.device.iGrillTempUnit;
import com.idevicesinc.device.iProbe;
import com.idevicesinc.device.iProbe.PreAlarmState;
import com.idevicesinc.sweetblue.BleDeviceState;
import com.idevicesinc.sweetblue.BleDevice.ConnectionFailListener.Status;

public class KankaDevice {

	private iGrill _grill;
	private boolean _thresholded = false;
	private KrollObject _krollObject;
	private Recipe _recipe = null;
	
	public KankaDevice(iGrill grill, KrollObject krollObject)
	{
		_grill = grill;
		_krollObject = krollObject;
	}

	public void disconnect()
	{
		_grill.disconnect();
	}

	public void acknowledgeAlarm(int index)
	{
		if(_grill != null && _grill.getProbe(index) != null)
		{
			_grill.getProbe(index).acknowledgeAlarm();
		}
	}

	public void acknowledgeAlarm()
	{
		acknowledgeAlarm(0);
	}

	public HashMap<String, Object> getAttributes()
	{
		HashMap<String, Object> map = new HashMap<String, Object>();
		if(_grill != null && _grill.getProbe(0) != null)
		{
			iProbe probe = _grill.getProbe(0);

			map.put("deviceName", _grill.getDeviceName());
			map.put("uniqueId", _grill.getUniqueId());
			map.put("batteryLevel", _grill.getBatteryLevel());
			map.put("firmwareVersion", _grill.getFirmwareVersion());
			iGrillTempUnit unit = probe.getTempUnit();

			String unitString = "";
			if (unit == iGrillTempUnit.C) {
				unitString = "C";
			} else {
				unitString = "F";
			}

			map.put("temperatureUnit", unitString);
			map.put("temperature", probe.getCurrentTemp());
			map.put("highThreshold", probe.getHighThreshold(iGrillTempUnit.C));
			map.put("lowThreshold", probe.getLowThreshold(iGrillTempUnit.C));
			map.put("preAlarmDelta", probe.getPreAlarmDelta());
			PreAlarmState state = probe.getPreAlarmState();
			String stateString = "";
			if (state == PreAlarmState.ACKNOWLEDGED_OR_REDUNDANT) {
				stateString = "ACKNOWLEDGED_OR_REDUNDANT";
			} else if (state == PreAlarmState.ACTIVE) {
				stateString = "ACTIVE";
			} else if (state == PreAlarmState.NOT_ACTIVE) {
				stateString = "NOT_ACTIVE";
			}

			boolean connected = probe.isConnected();
			map.put("preAlarmState", stateString);
			map.put("connected", connected);
			
			if(_recipe != null)
			{
				HashMap<String, Object> recipeMap = new HashMap<String, Object>();
				recipeMap.put("highThreshold", _recipe.highThreshold);
				recipeMap.put("highThreshold", _recipe.lowThreshold);
				recipeMap.put("highThreshold", _recipe.preAlarmDelta);
				map.put("recipe", recipeMap);
				map.put("hasRecipe", true);
			}
			else 
			{
				map.put("hasRecipe", false);
			}
		}
		return map;
	}

	public void connect(KrollDict params)
	{
		connect(0, params);
	}

	public void setRecipe(int index, KrollDict params)
	{
		if(_grill != null && _grill.getProbe(index) != null)
		{	
			iProbe probe = _grill.getProbe(index);
			final Integer lowThreshold = (Integer) params.get("lowThreshold");
			final Integer highThreshold = (Integer) params.get("highThreshold");
			final Integer preAlarmDelta = (Integer) params.get("preAlarmDelta");
			
			_recipe = new Recipe();
			_recipe.lowThreshold = lowThreshold;
			_recipe.highThreshold = highThreshold;
			_recipe.preAlarmDelta = preAlarmDelta;
			
			_grill.setTempUnit(iGrillTempUnit.C);

			if(highThreshold != null) {
				probe.setHighThreshold(highThreshold.intValue());
			}
			if(lowThreshold != null) {
				probe.setLowThreshold(lowThreshold.intValue());
			}
			if(preAlarmDelta != null) {
				probe.setPreAlarmDelta(preAlarmDelta.shortValue());
			}
		}
	}

	public void setRecipe(KrollDict params)
	{
		setRecipe(0, params);
	}

	private String getStatusString(Status status) {
		if (status == Status.ALREADY_CONNECTING_OR_CONNECTED) {

			return "ALREADY_CONNECTING_OR_CONNECTED";
		} else if (status == Status.AUTHENTICATION_FAILED) {
			return "AUTHENTICATION_FAILED";
		} else if (status == Status.BLE_TURNING_OFF) {
			return "BLE_TURNING_OFF";
		} else if (status == Status.BLE_TURNING_OFF) {
			return "BLE_TURNING_OFF";
		} else if (status == Status.BONDING_FAILED) {
			return "BONDING_FAILED";
		} else if (status == Status.DISCOVERING_SERVICES_FAILED) {
			return "DISCOVERING_SERVICES_FAILED";
		} else if (status == Status.EXPLICIT_DISCONNECT) {
			return "EXPLICIT_DISCONNECT";
		} else if (status == Status.INITIALIZATION_FAILED) {
			return "INITIALIZATION_FAILED";
		} else if (status == Status.NATIVE_CONNECTION_FAILED) {
			return "NATIVE_CONNECTION_FAILED";
		} else if (status == Status.NULL) {
			return "NULL";
		} else if (status == Status.NULL_DEVICE) {
			return "NULL_DEVICE";
		} else if (status == Status.ROGUE_DISCONNECT) {
			return "ROGUE_DISCONNECT";
		}

		return "";
	}

	public void connect(final int index, KrollDict params)
	{
		if(_grill.getProbe(index) == null)
		{
			return;
		}

		final KrollFunction tempCallback = (KrollFunction) params.get("onTemperatureChange");
		final KrollFunction thresholdCallback = (KrollFunction) params.get("onThreshold");
		final KrollFunction alarmCallback = (KrollFunction) params.get("onAlarmAcknowledge");
		final KrollFunction preAlarmCallback = (KrollFunction) params.get("onPrealarmStateChange");
		final KrollFunction connectCallback = (KrollFunction) params.get("onConnect");
		final KrollFunction disconnectCallback = (KrollFunction) params.get("onDisconnect");

		final Integer lowThreshold = (Integer) params.get("lowThreshold");
		final Integer highThreshold = (Integer) params.get("highThreshold");
		final Integer preAlarmDelta = (Integer) params.get("preAlarmDelta");


		_grill.getProbe(index).clearThresholds();


		_grill.setTempUnit(iGrillTempUnit.C);

		if(highThreshold != null) {
			_grill.getProbe(index).setHighThreshold(highThreshold.intValue());
		}
		if(_grill != null) {
			_grill.getProbe(index).setLowThreshold(lowThreshold.intValue());
		}
		if(preAlarmDelta != null) {
			_grill.getProbe(index).setPreAlarmDelta(preAlarmDelta.shortValue());
		}

		_grill.setProbeListener(new iProbe.Listener() {
			@Override
			public void onProbeEvent(final iProbe probe, Event event) {

				// Whenever the temperature changes, refresh the
				// temperature, thresholds, and pre-alarm delta elements in
				// the GUI
				if (event == Event.TEMPERATURE_CHANGED) {
					if (tempCallback != null) {
						tempCallback.callAsync(_krollObject, getAttributes());
					}
				} else if (event == Event.THRESHOLD_REACHED) {
					if (thresholdCallback != null) {

						if(!_thresholded)
						{
							Utils.sendThresholdNotification();
							_thresholded = true;
						}

						thresholdCallback.callAsync(_krollObject, getAttributes());
					}
				} else if (event == Event.ALARM_ACKNOWLEDGED) {
					if (alarmCallback != null) {
						alarmCallback.callAsync(_krollObject, getAttributes());
					}
				} else if (event == Event.PRE_ALARM_STATE_CHANGED) {
					if (preAlarmCallback != null) {

						PreAlarmState state = _grill.getProbe(index).getPreAlarmState();
						if (state == PreAlarmState.ACKNOWLEDGED_OR_REDUNDANT) {
						} else if (state == PreAlarmState.ACTIVE) {
						} else if (state == PreAlarmState.NOT_ACTIVE) {
						}
						preAlarmCallback.callAsync(_krollObject, getAttributes());
					}
				}
			}

		});

		_grill.setListener(new iGrill.Listener() {

			@Override
			public void onConnectionFailed(iDeviceBle device, Status status) {
				// TODO Auto-generated method stub
				Log.d(KankaBluetoothModule.LCAT, "Connection failed with status " + getStatusString(status));
				if (status == Status.ALREADY_CONNECTING_OR_CONNECTED) {
					device.disconnect();
				}

			}

			@Override
			public void onConnectionFailedWithRetries(iDeviceBle device, Status status) {
				Log.d(KankaBluetoothModule.LCAT, "onConnectionFailedWithRetries with status " + getStatusString(status));
				// TODO Auto-generated method stub

			}

			@Override
			public void onDeviceStateChange(iDeviceBle device, int arg1, int arg2, int arg3) {
				Log.d(KankaBluetoothModule.LCAT, "onDeviceStateChange");
				// TODO Auto-generated method stub

			}

			@Override
			public void onDeviceStateChangeForView(iDeviceBle device, BleDeviceState state) {
				if (state == BleDeviceState.CONNECTING) {
					Log.d(KankaBluetoothModule.LCAT, "CONNECTING");

				} else if (state == BleDeviceState.DISCOVERING_SERVICES) {
					Log.d(KankaBluetoothModule.LCAT, "DISCOVERING_DEVICES");
				} else if (state == BleDeviceState.AUTHENTICATING) {
					Log.d(KankaBluetoothModule.LCAT, "AUTHENTICATING");
				} else if (state == BleDeviceState.INITIALIZING) {
					Log.d(KankaBluetoothModule.LCAT, "INITIALIZING");
				}
				// When the initialized state is reached, the app hass fully
				// connected to the thermometer via BLE
				else if (state == BleDeviceState.INITIALIZED) {
					Log.d(KankaBluetoothModule.LCAT, "INITIALIZED");

					_grill.setTempUnit(iGrillTempUnit.C);
					if(highThreshold != null) {
						_grill.getProbe(index).setHighThreshold(highThreshold.intValue());
					}
					if(lowThreshold != null) {
						_grill.getProbe(index).setLowThreshold(lowThreshold.intValue());
					}
					if(preAlarmDelta != null) {
						_grill.getProbe(index).setPreAlarmDelta(preAlarmDelta.shortValue());
					}
					if (connectCallback != null) {
						Log.d(KankaBluetoothModule.LCAT, "Calling connectCallback");
						connectCallback.callAsync(_krollObject, getAttributes());
					}

					int currentTemp = _grill.getProbe(index).getCurrentTemp();
					if (currentTemp > -1000) {
						if (tempCallback != null) {
							Log.d(KankaBluetoothModule.LCAT, "TEMPERATURE_CHANGED " + currentTemp);
							tempCallback.callAsync(_krollObject, getAttributes());
						}
					}

				} else if (state == BleDeviceState.DISCONNECTED) {
					Log.d(KankaBluetoothModule.LCAT, "DISCONNECTED");
					if (disconnectCallback != null) {
						disconnectCallback.callAsync(_krollObject, getAttributes());
					}

				} else if (state == BleDeviceState.RECONNECTING_LONG_TERM) {
					Log.d(KankaBluetoothModule.LCAT, "ATTEMPTING_RECONNECT");
				}

			}

			@Override
			public void onDeviceEvent(iDevice device, Event event) {
				if (event == Event.BATTERY_LEVEL_UPDATED) {
					if (_grill.hasBatteryLevel()) {
						// Do something
					}
				}
				// After connecting to a device, it takes a few moments to
				// read the firmware version from the device. When the
				// firmware version is
				// successfully read, the device event
				// FIRMWARE_VERSION_AVAILABLE occurs.
				else if (event == Event.FIRMWARE_VERSION_AVAILABLE) {

					if (_grill.isFirmwareUpdateAvailable()) {
						// Normally, this is where you can check if there
						// are any firmware updates available,
						// and if so, call device.updateFirmware(). However,
						// for the purposes of this sample app,
						// we simply added an "Update Firmware" button so
						// you can force the firmware update.
					}
				} else if (event == Event.FIRMWARE_UPDATE_STARTED) {

				} else if (event == Event.FIRMWARE_UPDATE_PROGRESS) {

				} else if (event == Event.FIRMWARE_UPDATE_COMPLETED) {

				} else if (event == Event.FIRMWARE_UPDATE_FAILED) {

				}

			}

			@Override
			public void onConnectedProbeCountChanged(iGrill arg0) {
				// TODO Auto-generated method stub

			}

		});
		Log.d(KankaBluetoothModule.LCAT, "Setting temp unit");
		_grill.setTempUnit(iGrillTempUnit.C);
		Log.d(KankaBluetoothModule.LCAT, "Connecting");
		if(!_grill.getProbe(index).isConnected()) {
			_grill.connect();
		} else {
			connectCallback.callAsync(_krollObject, getAttributes());
		}
	}
	
	private class Recipe
	{
		public Integer highThreshold;
		public Integer lowThreshold;
		public Integer preAlarmDelta;
	}
}
