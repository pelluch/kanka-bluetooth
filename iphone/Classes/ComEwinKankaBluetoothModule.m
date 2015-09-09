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

	// NSLog(@"[INFO] %@ loaded",self);
    // NSLog(@"MODULE HAS LOADED!!");
    _devices = [[NSMutableDictionary alloc]initWithCapacity:10];
    // NSLog(@"Startup done");
    [ self registerForNotifications ];
    [ [ UIApplication sharedApplication ] cancelAllLocalNotifications ];
    
    _tempUnit = iGrillTempUnit_C;
}

-(void)setTemperatureUnit:(id)args
{
    NSUserDefaults * defaults = [[NSUserDefaults standardUserDefaults] retain];
    NSString * termUnit = [ defaults stringForKey:@"termUnit" ];
    if(termUnit)
    {
        if([termUnit rangeOfString:@"C"].location != NSNotFound)
        {
            _tempUnit = iGrillTempUnit_C;
        }
        else if([termUnit rangeOfString:@"F"].location != NSNotFound)
        {
            _tempUnit = iGrillTempUnit_F;
        }
        else
        {
            _tempUnit = iGrillTempUnit_C;
        }
    }
    else
    {
        _tempUnit = iGrillTempUnit_C;
    }
    
    for(id key in _devices)
    {
        id deviceData = [ _devices objectForKey:key ];
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        if(device) {
            [ device setTempUnitForDevice:_tempUnit ];
        }
    }
    NSLog(@"termUnit is %@", termUnit);
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
    
    //NSLog(@"Starting scan");
    ENSURE_ARG_COUNT(args, 1);
    
    [ self setTemperatureUnit:nil ];
    
    NSDictionary * params = [ [ args objectAtIndex:0 ] retain ];
    
    _onDiscover = params[@"onDiscover"];
    _onUndiscover = params[@"onUndiscover"];
    
    _iGrillBLEManager = [[iGrillBLEManager alloc] initWithDelegate:self andRestorationId:nil];
    
    if (![_iGrillBLEManager registeriGrillDeviceClass:[KankaDevice class]]) {
        // NSLog(@"Error registering Kanka device.");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _cullTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                      target:self
                                                    selector:@selector(checkForUndiscoveredDevices)
                                                    userInfo:nil
                                                     repeats:YES];

    });
    
}


-(void)disconnectDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    // NSLog(@"Disconnect device");
    NSString * uniqueId = args[0];
    NSLog(uniqueId);
    
    
}

-(void)connectDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    // NSLog(@"Connect device");
    NSString * uniqueId = [ args[0] retain ];
    NSLog(uniqueId);
    NSDictionary * params = [ args[1] retain ];
    
    KrollCallback * onTemperatureChange = params[@"onTemperatureChange"];
    KrollCallback * onThreshold = params[@"onThreshold"];
    KrollCallback * onAlarmAcknowledge = params[@"onAlarmAcknowledge"];
    KrollCallback * onPrealarmStateChange = params[@"onPrealarmStateChange"];
    KrollCallback * onConnect = params[@"onConnect"];
    KrollCallback * onDisconnect = params[@"onDisconnect"];
    KrollCallback * onConnectionFailedWithRetries = params[@"onConnectionFailedWithRetries"];
    KrollCallback * onConnectionFailed = params[@"onConnectionFailed"];
    KrollCallback * onConnectedProbeCountChange = params[@"onConnectedProbeCountChange"];
    
    
    NSNumber * preAlarmDelta = params[@"preAlarmDelta" ];
    NSNumber * highThreshold = params[@"highThreshold"];
    NSNumber * lowThreshold = params[@"lowThreshold"];
    NSMutableDictionary * deviceData = [ _devices objectForKey : uniqueId ];
    
    NSLog(@"deviceData: %@", deviceData);
    
    if(deviceData)
    {
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        
        NSLog(@"There is deviceData");
        [ deviceData setObject:onTemperatureChange forKey:@"onTemperatureChange" ];
        [ deviceData setObject:onThreshold forKey:@"onThreshold" ];
        [ deviceData setObject:onAlarmAcknowledge forKey:@"onAlarmAcknowledge" ];
        [ deviceData setObject:onPrealarmStateChange forKey:@"onPrealarmStateChange" ];
        [ deviceData setObject:onConnect forKey:@"onConnect" ];
        [ deviceData setObject:onDisconnect forKey:@"onDisconnect" ];
        if(!preAlarmDelta) {
            preAlarmDelta = [ NSNumber numberWithInteger:6 ];
        }
        [ deviceData setObject:preAlarmDelta forKey:@"preAlarmDelta" ];
        if(!highThreshold) {
            [ deviceData setObject:[ NSNumber numberWithInt:-2000 ] forKey:@"highThreshold" ];
            [ deviceData setObject:[ NSNumber numberWithBool:NO] forKey:@"hasRecipe" ];
        } else {
            [ deviceData setObject:highThreshold forKey:@"highThreshold" ];
            [ deviceData setObject:[ NSNumber numberWithBool:YES] forKey:@"hasRecipe" ];
        }
        
        if(!lowThreshold) {
            [ deviceData setObject:[ NSNumber numberWithInt:-2000 ] forKey:@"lowThreshold" ];
        } else {
            [ deviceData setObject:lowThreshold forKey:@"lowThreshold" ];
        }
        
        NSLog(@"Done setting device data");
        
        if(device)
        {
            if( [device connectionState ] == iGrillConnectionState_Connected)
            {
                [ self deviceConnected:device ];
            }
            else
            {
                NSLog(@"Calling connectiGrill");
                [ _iGrillBLEManager connectiGrill:device ];
            }
            
            NSLog(@"There is device");
            [ device setTempUnitForDevice:iGrillTempUnit_C ];
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

- (void) unblockUpdate:(NSTimer *)timer
{
    NSMutableDictionary * deviceData = [ timer userInfo ];
    if(deviceData)
    {
        [ deviceData setObject:[ NSNumber numberWithBool:NO ] forKey:@"blocked"];
        [ timer invalidate ];
    }
}

- (void) dataUpdated:(iGrillBLEDevice *)device
{
    
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    
    if(deviceData)
    {
        NSNumber * blocked = [ deviceData objectForKey:@"blocked" ];
        if(blocked != nil)
        {
            BOOL blockedBool = [ blocked boolValue ];
            if(blockedBool) {
                return;
            }
        }
        
        [deviceData setObject:[ NSNumber numberWithBool:YES ] forKey:@"blocked" ];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimer * blockTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                          target:self
                                                                  selector:@selector(unblockUpdate:)
                                                        userInfo:deviceData
                                                         repeats:YES];
            
        });
        
        // NSLog(@"Data updated");
        NSInteger newTemp = [ device currentTemperatureForProbe:0 ];
        // NSLog(@"Temp: %d", newTemp);
        NSInteger temp = [ [ deviceData objectForKey:@"temperature" ] intValue ];
        // NSLog(@"Stored temp: %d", temp);
        NSInteger highTemp = [ device highThresholdForProbe:0 inUnit:_tempUnit ];
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        // NSLog(@"Map: %@", deviceMap);
        
        NSInteger highInt = [ [ deviceData objectForKey:@"highThreshold" ] integerValue ];
        NSInteger lowInt = [ [ deviceData objectForKey:@"lowThreshold" ] integerValue ];
        // NSLog(@"High: %d low: %d", highInt, lowInt);
        
        if([ device tempUnitForProbe:0 ] == iGrillTempUnit_C) {
            // NSLog(@"Probe temp in Celsius");
        } else {
            // NSLog(@"Probe temp in Fahrenheit, converting");
            float highFloat = (highInt*9.0/5.0 + 32.0);
            float lowFloat = lowInt > -2000.0 ? (lowInt*9.0/5.0 + 32.0) : -2000.0;
            lowInt = (NSInteger)roundf(lowFloat);
            highInt = (NSInteger)roundf(highFloat);
            // NSLog(@"High: %d low: %d", highInt, lowInt);
        }
        
        
        // [ device setThresholdsForProbe:0 high:highInt low:lowInt ];
        
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
                [ self scheduleNotificationWithDevice:device ];
                [ onThreshold call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
                [ deviceData setObject:[ NSNumber numberWithBool:NO ] forKey:@"alarmAcknowledged "];
            }
        } else if( [ thresholdReached boolValue ] && highTemp > -2000 && newTemp < highTemp) {
            [ deviceData setObject:[ NSNumber numberWithBool:NO ] forKey:@"thresholdReached" ];
        }
        
        if( [ [ deviceData objectForKey:@"alarmAcknowledged" ] boolValue ] == YES) {
            [ device sendAcknowledgementForAlarm ];
            // [ device turnOffAlarmForProbe:0 ];
        }
    }
}

- (void) acknowledgeAlarm:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    NSLog(@"Acknowledge alarm");
    
    NSString * uniqueId = args[0];
    NSLog(@"Id is %@", uniqueId);
    
    NSMutableDictionary * deviceData = [ _devices objectForKey:uniqueId ];
    if(deviceData)
    {
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        if(device)
        {
            NSLog(@"Sending ack");
            [ deviceData setObject:[ NSNumber numberWithBool:YES ] forKey:@"alarmAcknowledged" ];
            // [ device turnOffAlarmForProbe:0 ];
            [ device sendAcknowledgementForAlarm ];
        }
        else
        {
            NSLog(@"No device");
        }
    }
    else
    {
        NSLog(@"No deviceData");
    }

}

- (void) deviceConnected:(iGrillBLEDevice*)device
{
    NSLog(@"deviceConnected");
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    KrollCallback * onConnect = [ deviceData objectForKey:@"onConnect" ];
    
    
    NSLog(@"Gets here");
    NSInteger highInt = -2000;
    [ device setTempUnitForDevice:_tempUnit ];
    if([ deviceData objectForKey:@"highThreshold" ] != [ NSNull null ] ) {
        highInt = [ [ deviceData objectForKey:@"highThreshold" ] integerValue ];
        [ device setHighThreshold:highInt forProbe:0 ];
    }


    NSLog(@"High: %d", highInt);
    
    
    if(onConnect) {
        [ deviceData setObject:[ NSNumber numberWithInteger:[ device currentTemperatureForProbe:0 ]] forKey:@"temperature" ];
        NSLog(@"Registering data updated observer");
        
        [ device registerDataObserver:self withSelector:@selector(dataUpdated:)];
        
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        [ onConnect call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }

}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnected:(iGrillBLEDevice*)device
{
    [ self deviceConnected:device ];
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

- (void) registerForNotifications
{
    /* UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
     */
}



- (void)scheduleNotificationWithDevice:(iGrillBLEDevice *)device  {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"La cocción de la sonda %@ ha finalizado",
                            [ device deviceName ] ];
    localNotif.alertAction = NSLocalizedString(@"Ver cocción", nil);
    localNotif.alertTitle = NSLocalizedString(@"Cocción Finalizada", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    NSString * uuid = [[ device deviceId ] UUIDString];

    NSDictionary * infoDict = [NSDictionary dictionaryWithObject:uuid forKey:@"uniqueId" ];
    localNotif.userInfo = infoDict;
    localNotif.applicationIconBadgeNumber = 1;
    // NSLog(@"Scheduling not");
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(id) getDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    // NSLog(@"Connect device");
    NSString * uniqueId = [ args[0] retain ];
    NSMutableDictionary * deviceData = [ _devices objectForKey:uniqueId ];
    if(deviceData)
    {
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        if(device)
        {
            return [ self getDeviceMap:device ];
        }
    }
    return NULL;
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
    
    BOOL hasRecipe = NO;
    NSInteger highThreshold = [ device highThresholdForProbe:0 inUnit:_tempUnit];
    if(highThreshold > -2000) {
        hasRecipe = YES;
    }
    NSNumber * preAlarmDelta;
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    if(deviceData) {
        preAlarmDelta = [ deviceData objectForKey:@"preAlarmDelta" ];
    }
    
    NSMutableDictionary * deviceMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Device",
                                    @"deviceName", uuid, @"uniqueId", discovered, @"discovered",
                                       [ NSNumber numberWithInteger:[device currentTemperatureForProbe:0 ]],
                                       @"temperature",
                                       [ device deviceName ], @"deviceName",
                                       unitString, @"temperatureUnit",
                                       [NSNumber numberWithInteger:[device batteryLevel]], @"batteryLevel",
                                       [NSNumber numberWithInteger:[device lowThresholdForProbe:0 inUnit:_tempUnit]], @"lowThreshold",
                                       [NSNumber numberWithInteger:[device highThresholdForProbe:0 inUnit:_tempUnit]], @"highThreshold",
                                       [ NSNumber numberWithBool:[ device isProbeConnected:0 ]],
                                       @"connected",
                                       [ NSNumber numberWithBool:hasRecipe ],
                                       @"hasRecipe",
                                       preAlarmDelta,
                                       @"preAlarmDelta",
                                       nil ];
    return deviceMap;

}

-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceDiscovered:(iGrillBLEDevice*)device
{
    // NSLog(@"deviceDiscovered");
    NSMutableDictionary * data = [[ NSMutableDictionary alloc ] initWithCapacity:10 ];
    [ data setObject:device forKey:@"device" ];
    [ _devices setObject:data forKey:[[ device deviceId ] UUIDString ]];
    NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
    if(_onDiscover) {
        [ _onDiscover call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
    
}

-(void) igrillBLEManager:(iGrillBLEManager*)manager undiscoveredDevice:(iGrillBLEDevice*)device
{
    // NSLog(@"undiscoveredDevice");
    NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
    if(_onUndiscover) {
        [ _onUndiscover call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
}

- (void)checkForUndiscoveredDevices
{
    // NSLog(@"Checking for undiscovered devices");
    [_iGrillBLEManager cullDiscoveredDevicesOlderThan:20];
}



@end
