/**
 * kanka-bluetooth-ios
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import <iGrillBLEManager.h>
#import <KankaDevice.h>

@protocol DeviceManagerProtocol <NSObject>

- (void)forgetDevice:(iGrillBLEDevice *)device;
- (void)pairDevice:(iGrillBLEDevice *)device;

@end

@interface ComEwinKankaBluetoothModule : TiModule
{
    NSDictionary *_devices;
    NSMutableDictionary *_testDevices;
    BOOL _test;
}

@end
