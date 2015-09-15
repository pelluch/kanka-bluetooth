//
//  Device.h
//  kanka-bluetooth-ios
//
//  Created by Pablo Lluch on 9/14/15.
//
//

#ifndef kanka_bluetooth_ios_Device_h
#define kanka_bluetooth_ios_Device_h

#import <iGrillBLEManager.h>
#import <KankaDevice.h>

@interface Device : NSObject
{
    iGrillBLEDevice * _device;
    NSString * _uuid;
    NSInteger _preAlarmDelta;
    NSInteger _highThreshold;
    
}
@end

#endif
