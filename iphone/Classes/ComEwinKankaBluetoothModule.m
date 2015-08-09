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
    
    _cullTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(checkForUndiscoveredDevices)
                                                userInfo:nil
                                                 repeats:YES];
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
    
    NSMutableDictionary * deviceData = [ _devices objectForKey : uniqueId ];
    
    if(deviceData)
    {
        [ deviceData setObject:onConnect forKey:@"onTemperatureChange" ];
        [ deviceData setObject:onConnect forKey:@"onThreshold" ];
        [ deviceData setObject:onConnect forKey:@"onAlarmAcknowledge" ];
        [ deviceData setObject:onConnect forKey:@"onPrealarmStateChange" ];
        [ deviceData setObject:onConnect forKey:@"onConnect" ];
        [ deviceData setObject:onConnect forKey:@"onDisconnect" ];
        
        iGrillBLEDevice * device = [ deviceData objectForKey:@"device" ];
        if(device)
        {
            [ _iGrillBLEManager connectiGrill:device ];
        }
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
}

- (void) igrillBLEManagerBluetoothUnavailable:(iGrillBLEManager*)manager
{
    
}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnected:(iGrillBLEDevice*)device
{
    NSLog(@"Connected!!");
    NSString * uuid = [[ device deviceId ] UUIDString];
    
    NSMutableDictionary * deviceData = [ _devices objectForKey:uuid ];
    NSLog(@"%@", deviceData);
    KrollCallback * onConnect = [ deviceData objectForKey:@"onConnect" ];
    
    if(onConnect) {
        NSLog(@"Calling onConnect");
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        [ onConnect call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
    //We assume that when a device is connected we will display the details.
    // [self displayDeviceDetail:device];
    
    // [self.tableView reloadData];
}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceDisconnected:(iGrillBLEDevice*)device
{
    // [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDeviceDisconnected object:device];
    
    // [self.tableView reloadData];
}

- (void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnectFailed:(iGrillBLEDevice*)device
{
    // [self.tableView reloadData];
}

-(NSMutableDictionary*) getDeviceMap:(iGrillBLEDevice*)device
{
    NSString * uuid = [[ device deviceId ] UUIDString];
    NSNumber * discovered = @(true);
    NSMutableDictionary * deviceMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Device",
                                    @"deviceName", uuid, @"uniqueId", discovered, @"discovered", nil];
    return deviceMap;

}

-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceDiscovered:(iGrillBLEDevice*)device
{
    NSLog(@"Device discovered");
    
    NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
    NSLog(@"Returning %@", deviceMap);
    
    NSMutableDictionary * data = [[ NSMutableDictionary alloc ] initWithCapacity:10 ];
    [ data setObject:device forKey:@"device" ];
    [ _devices setObject:data forKey:[[ device deviceId ] UUIDString ]];
    
     NSLog(@"Calling onDiscover");
    
    if(_onDiscover) {
        // NSLog(@"%@ %@", _onDiscover, args);
        [ _onDiscover call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
        NSLog(@"Done");
    } else {
        NSLog(@"On discover null?");
    }
    
}

-(void) igrillBLEManager:(iGrillBLEManager*)manager undiscoveredDevice:(iGrillBLEDevice*)device
{
    NSLog(@"Device undiscovered");
    if(_onDiscover) {
        NSMutableDictionary * deviceMap = [ self getDeviceMap:device ];
        [ _onUndiscover call:[ NSArray arrayWithObject:deviceMap ] thisObject:self ];
    }
    // [self.tableView reloadData];
}

@end
