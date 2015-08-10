/**
 * kanka-bluetooth-ios
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "ComEwinKankaBluetoothModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"


@interface ComEwinKankaBluetoothModule() <iGrillBLEManagerDelegate, DeviceManagerProtocol>
{
    iGrillBLEManager *_iGrillBLEManager;
    NSTimer *_cullTimer;
}
@end

@implementation ComEwinKankaBluetoothModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"4bd11bed-3447-4ce5-b7c9-20cf8d3fe325";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.ewin.kanka.bluetooth";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
    NSLog(@"MODULE HAS LOADED!!");
    _devices = [[NSMutableDictionary alloc]initWithCapacity:10];
    NSLog(@"Startup done");
}



-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs


-(void)startScan:(id)args
{
    
    NSLog(@"Starting scan");
    ENSURE_ARG_COUNT(args, 1);
    
    
    
    NSDictionary * params = [ [ args objectAtIndex:0 ] retain ];
    
    _onDiscover = params[@"onDiscover"];
    _onUndiscover = params[@"onUndiscover"];
    
    _iGrillBLEManager = [[iGrillBLEManager alloc] initWithDelegate:self andRestorationId:nil];
    
    if (![_iGrillBLEManager registeriGrillDeviceClass:[KankaDevice class]]) {
        NSLog(@"Error registering Kanka device.");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _cullTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(checkForUndiscoveredDevices)
                                                    userInfo:nil
                                                     repeats:YES];

    });
    
}


-(void)disconnectDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    NSLog(@"Disconnect device");
    NSString * uniqueId = args[0];
    NSLog(uniqueId);
    
    
}

-(void)connectDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    NSLog(@"Connect device");
    NSString * uniqueId = [ args[0] retain ];
    NSLog(uniqueId);
    NSDictionary * params = [ args[1] retain ];
    
    KrollCallback * onTemperatureChange = params[@"onTemperatureChange"];
    KrollCallback * onThreshold = params[@"onThreshold"];
    KrollCallback * onAlarmAcknowledge = params[@"onAlarmAcknowledge"];
    KrollCallback * onPrealarmStateChange = params[@"onPrealarmStateChange"];
    KrollCallback * onConnect = params[@"onConnect"];
    KrollCallback * onDisconnect = params[@"onDisconnect"];
    
    NSLog(@"Params: %@", params);
    NSNumber * highThreshold = params[@"highThreshold"];
    NSNumber * lowThreshold = params[@"lowThreshold"];
    NSMutableDictionary * deviceData = [ _devices objectForKey : uniqueId ];
    
    NSLog(@"hightThreshold: %d", [ highThreshold intValue ]);
    NSLog(@"lowThreshold: %d", [ lowThreshold intValue ]);
    NSLog(@"deviceData: %@", deviceData);
    
    if(deviceData)
    {
        NSLog(@"There is deviceData");
        [ deviceData setObject:onTemperatureChange forKey:@"onTemperatureChange" ];
        [ deviceData setObject:onThreshold forKey:@"onThreshold" ];
        [ deviceData setObject:onAlarmAcknowledge forKey:@"onAlarmAcknowledge" ];
        [ deviceData setObject:onPrealarmStateChange forKey:@"onPrealarmStateChange" ];
        [ deviceData setObject:onConnect forKey:@"onConnect" ];
        [ deviceData setObject:onDisconnect forKey:@"onDisconnect" ];
        [ deviceData setObject:highThreshold forKey:@"highThreshold" ];
        [ deviceData setObject:lowThreshold forKey:@"lowThreshold" ];
        
        NSInteger highInt = [ highThreshold integerValue ];
        NSInteger lowInt = [ lowThreshold integerValue ];
        NSLog(@"High: %d low: %d", highInt, lowInt);
        
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        if(device)
        {   NSLog(@"There is device");
            [ device setTempUnitForDevice:iGrillTempUnit_C ];
            
            NSLog(@"Calling connectiGrill");
            [ _iGrillBLEManager connectiGrill:device ];
        }
        else
        {
            NSLog(@"There is no device");
        }
    }
    else
    {
        NSLog(@"No data for device %@", uniqueId);
    }
}



#pragma mark - Device Manager Protocol
-(void)forgetDevice:(iGrillBLEDevice *)device
{
    [_iGrillBLEManager disconnectiGrill:device];
}

-(void)pairDevice:(iGrillBLEDevice *)device
{
    [_iGrillBLEManager cullDiscoveredDevicesOlderThan:5];
}

#pragma mark - iGrillBLEManagerDelegate

- (void) igrillBLEManagerReadyToScan:(iGrillBLEManager*)manager
{
    if( [manager isReadyToScan] )
    {
        [manager startScan:YES];
    }
    else
    {
        NSLog(@"Unable to scan");
    }
}

- (void) igrillBLEManagerBluetoothUnavailable:(iGrillBLEManager*)manager
{
    NSLog(@"Bluetooth unavailable");
}

- (void) dataUpdated:(iGrillBLEDevice *)device
{
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    
    if(deviceData)
    {
        // NSLog(@"Data updated");
        NSInteger newTemp = [ device currentTemperatureForProbe:0 ];
        // NSLog(@"Temp: %d", newTemp);
        NSInteger temp = [ [ deviceData objectForKey:@"temperature" ] intValue ];
        // NSLog(@"Stored temp: %d", temp);
        NSInteger highTemp = [ device highThresholdForProbe:0 inUnit:iGrillTempUnit_C ];
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        // NSLog(@"Map: %@", deviceMap);
        
        if(newTemp != temp)
        {
            // NSLog(@"Temperatures not equal, setting object");
            [ deviceData setObject:[ NSNumber numberWithInteger:newTemp ] forKey:@"temperature" ];
            KrollCallback * onTemperatureChange = [ deviceData objectForKey:@"onTemperatureChange" ];
            if(onTemperatureChange)
            {
                // NSLog(@"Calling onTemperatureChange");
                [ onTemperatureChange call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
            }
        }
        
        NSNumber * thresholdReached = [ deviceData objectForKey:@"thresholdReached" ];
        if(![ thresholdReached boolValue ] && highTemp > -2000 && newTemp >= highTemp)
        {
            NSLog(@"Threshold reached!");
            // NSNumber * alarmOn = [ device alarmOnForProbe:0 ];
            // NSLog(@"%@", alarmOn);
            thresholdReached = @YES;
            [ deviceData setObject:thresholdReached forKey:@"thresholdReached" ];
            KrollCallback * onThreshold = [ deviceData objectForKey:@"onThreshold" ];
            if(onThreshold)
            {
                NSLog(@"Calling onThreshold");
                [ onThreshold call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
            }
        }
    }
}

- (void) acknowledgeAlarm:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    NSLog(@"Acknowledge alarm");
    
    NSString * uniqueId = args[0];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uniqueId ];
    if(deviceData)
    {
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        if(device)
        {
            NSLog(@"Sending ack");
            [ device sendAcknowledgementForAlarm ];
        }
    }

}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnected:(iGrillBLEDevice*)device
{
    NSLog(@"deviceConnected");
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    KrollCallback * onConnect = [ deviceData objectForKey:@"onConnect" ];
    
    // [ device setTempUnitForDevice:iGrillTempUnit_C ];
    
    NSInteger highInt = [ [ deviceData objectForKey:@"highThreshold" ] integerValue ];
    NSInteger lowInt = [ [ deviceData objectForKey:@"lowThreshold" ] integerValue ];
    NSLog(@"High: %d low: %d", highInt, lowInt);
    
    if([ device tempUnitForProbe:0 ] == iGrillTempUnit_C) {
        NSLog(@"Probe temp in Celsius");
    } else {
        NSLog(@"Probe temp in Fahrenheit, converting");
        float highFloat = (highInt*9.0/5.0 + 32.0);
        float lowFloat = lowInt > -2000.0 ? (lowInt*9.0/5.0 + 32.0) : -2000.0;
        lowInt = (NSInteger)roundf(lowFloat);
        highInt = (NSInteger)roundf(highFloat);
        NSLog(@"High: %d low: %d", highInt, lowInt);
    }
    
    
    [ device setThresholdsForProbe:0 high:highInt low:lowInt ];
    //[ device setThresholdsForProbe:0 high:[ [deviceData objectForKey:@"highThreshold"] integerValue ]
    //                            low:[ [deviceData objectForKey:@"lowThreshold"] integerValue ]];
    if(onConnect) {
        [ deviceData setObject:[ NSNumber numberWithInteger:[ device currentTemperatureForProbe:0 ]] forKey:@"temperature" ];
        [ device registerDataObserver:self withSelector:@selector(dataUpdated:)];
        
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        [ onConnect call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceDisconnected:(iGrillBLEDevice*)device
{
    NSLog(@"deviceDisconnected");
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    KrollCallback * onDisconnect = [ deviceData objectForKey:@"onDisconnect" ];
    
    if(onDisconnect) {
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        [ onDisconnect call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnectFailed:(iGrillBLEDevice*)device
{
    NSLog(@"deviceConnectFailed");
}

-(NSMutableDictionary*) getDeviceMap:(iGrillBLEDevice*)device
{
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSNumber * discovered = @(true);
    iGrillTempUnit unit = [ device tempUnitForProbe:0 ];
    NSString * unitString;
    
    if(unit == iGrillTempUnit_C)
    {
        unitString = @"C";
    }
    else
    {
        unitString = @"F";
    }
    
    NSString * connectionStateString = @"";
    iGrillConnectionState state = [ device connectionState ];
    if(state == iGrillConnectionState_Connected)
    {
        connectionStateString = @"Connected";
    }
    else if(state == iGrillConnectionState_Connecting)
    {
        connectionStateString = @"Connecting";
    }
    else if(state == iGrillConnectionState_NotConnected)
    {
        connectionStateString = @"NotConnected";
    }
    
    NSMutableDictionary * deviceMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Device",
                                    @"deviceName", uuid, @"uniqueId", discovered, @"discovered",
                                       [ NSNumber numberWithInteger:[device currentTemperatureForProbe:0 ]],
                                       @"temperature",
                                       [ device deviceName ], @"deviceName",
                                       unitString, @"temperatureUnit",
                                       [NSNumber numberWithInteger:[device batteryLevel]], @"batteryLevel",
                                       [NSNumber numberWithInteger:[device lowThresholdForProbe:0 inUnit:iGrillTempUnit_C]], @"lowThreshold",
                                       [NSNumber numberWithInteger:[device highThresholdForProbe:0 inUnit:iGrillTempUnit_C]], @"highThreshold",
                                       nil ];
    return deviceMap;

}

-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceDiscovered:(iGrillBLEDevice*)device
{
    NSLog(@"deviceDiscovered");
    
    NSMutableDictionary * existing = [ _devices objectForKey:[[ device deviceId ] UUIDString ]];
    if(!existing)
    {
        NSMutableDictionary * data = [[ NSMutableDictionary alloc ] initWithCapacity:10 ];
        [ device setTempUnitForDevice:iGrillTempUnit_C ];
        [ data setObject:device forKey:@"device" ];
        NSNumber * thresholdReached = @NO;
        [ data setObject:thresholdReached forKey:@"thresholdReached" ];
        NSLog(@"Setting _devices for %@", [[ device deviceId ] UUIDString ]);
        [ _devices setObject:data forKey:[[ device deviceId ] UUIDString ]];
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        if(_onDiscover) {
            [ _onDiscover call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
        }
    }
}

-(void) igrillBLEManager:(iGrillBLEManager*)manager undiscoveredDevice:(iGrillBLEDevice*)device
{
    NSLog(@"undiscoveredDevice");
    NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
    if(_onUndiscover) {
        [ _onUndiscover call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
}

- (void)checkForUndiscoveredDevices
{
    NSLog(@"Checking for undiscovered devices");
    [_iGrillBLEManager cullDiscoveredDevicesOlderThan:5];
}


@end
