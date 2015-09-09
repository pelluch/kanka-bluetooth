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
    
    NSMutableDictionary * _devices;
    BOOL _test;
    KrollCallback * _onDiscover;
    KrollCallback * _onUndiscover;
    ComEwinKankaBluetoothModule * _this;
    iGrillTempUnit _tempUnit;
    NSInteger ACTIVE;
    NSInteger NOT_ACTIVE;
    NSInteger ACKNOWLEDGED_OR_REDUNDANT;
}

@end
