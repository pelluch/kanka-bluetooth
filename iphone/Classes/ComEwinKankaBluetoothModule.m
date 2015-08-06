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
    _testDevices = [[NSMutableDictionary alloc]initWithCapacity:10];
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
    ENSURE_ARG_COUNT(args, 1);
    NSDictionary * params = args[0];
    
    KrollCallback * onDiscover = params[@"onDiscover"];
    KrollCallback * onUndiscover = params[@"onUndiscover"];
    NSLog(@"Starting scan");
    
  
    [ onDiscover call:[ self addDevice:@"15f9ae61-7c0e-4ec8-bb4a-f393c5bd119a"] thisObject:self];
   
    
}

-(NSArray *)addDevice:(NSString *)uuid
{
    NSLog(uuid);
    NSNumber * discovered = @(true);
    NSMutableDictionary *device = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Test Device",
                                   @"deviceName", uuid, @"uniqueId", discovered, @"discovered", nil];
    NSLog(@"Created device");
    [_testDevices setObject:device forKey: uuid];
    NSLog(@"Set test devices hash");
    NSArray * args = [ NSArray arrayWithObject:device ];
    return args;
}


-(void)disconnectDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    NSLog(@"Disconnect device");
    NSString * uniqueId = args[0];
    NSLog(uniqueId);
    
    NSMutableDictionary * device = [ _testDevices objectForKey : uniqueId ];
    if(device != nil)
    {
        KrollCallback * onDisconnect = [ device objectForKey:@"onDisconnect" ];
        NSTimer * timer = [ device objectForKey:@"timer" ];
        if(timer != nil)
        {
            [ timer invalidate ];
        }
        [ onDisconnect call:[NSArray array] thisObject:self];
    }
}

-(void)onTick:(NSTimer *)timer
{
    NSLog(@"TICK");
    NSLog(@"Timer callback for %@", [ timer userInfo ]);
    NSMutableDictionary * device = [ timer userInfo ];
    NSNumber * temp = [ device objectForKey:@"temperature" ];
    NSMutableDictionary * map = [ [NSMutableDictionary alloc]
                                 initWithObjectsAndKeys:temp, @"temperature", nil ];
    KrollCallback * onTemperatureChange = [ device objectForKey:@"onTemperatureChange" ];
    [ onTemperatureChange call:[ NSArray arrayWithObject:map ] thisObject:self ];
    
    int newTemp = [ temp intValue ] + arc4random_uniform(20) - 10;
    if(newTemp > 200) {
        newTemp = 200;
    } else if(newTemp < 0) {
        newTemp = 0;
    }
    temp = [ NSNumber numberWithInt:newTemp ];
    [ device setObject:temp forKey:@"temperature" ];
}

-(void)connectDevice:(id)args
{
    ENSURE_ARG_COUNT(args, 2);
    NSLog(@"Connect device");
    NSString * uniqueId = args[0];
    NSLog(uniqueId);
    NSDictionary * params = args[1];
    
    KrollCallback * onTemperatureChange = params[@"onTemperatureChange"];
    KrollCallback * onThreshold = params[@"onThreshold"];
    KrollCallback * onAlarmAcknowledge = params[@"onAlarmAcknowledge"];
    KrollCallback * onPrealarmStateChange = params[@"onPrealarmStateChange"];
    KrollCallback * onConnect = params[@"onConnect"];
    KrollCallback * onDisconnect = params[@"onDisconnect"];
    
    NSMutableDictionary * device = [ _testDevices objectForKey : uniqueId ];
    if(device != nil)
    {
        
        NSNumber * temp = @(80);
        [ device setObject:onDisconnect forKey:@"onDisconnect" ];
        [ device setObject:onTemperatureChange forKey:@"onTemperatureChange" ];
        [ device setObject:temp forKey:@"temperature" ];
        [ onConnect call:[ NSArray array ] thisObject:self];
        
        NSLog(@"Initializing timer");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimer * timer = [ NSTimer
                     scheduledTimerWithTimeInterval:5
                     target:self
                     selector: @selector(onTick:)
                     userInfo: device
                     repeats: YES ];
            [ timer fire ];
            [ device setObject:timer forKey:@"timer" ];
        });
    }
}


-(id)test
{
    return _test;
}

-(void)setTest:(id)value
{
    _test = value;
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

-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceDiscovered:(iGrillBLEDevice*)device
{
    // [self.tableView reloadData];
}

-(void) igrillBLEManager:(iGrillBLEManager*)manager undiscoveredDevice:(iGrillBLEDevice*)device
{
    // [self.tableView reloadData];
}

@end
