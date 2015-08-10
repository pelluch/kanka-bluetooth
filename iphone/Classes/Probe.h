//
//  Probe.h
//  kanka-bluetooth-ios
//
//  Created by Pablo Lluch on 8/10/15.
//
//

#ifndef kanka_bluetooth_ios_Probe_h
#define kanka_bluetooth_ios_Probe_h

#import <iGrillBLEManager.h>
#import <KankaDevice.h>

@interface Probe : NSObject
{
    NSInteger lowThreshold;
    NSInteger highThreshold;
    iGrillBLEDevice * device;
    iGrillConnectionState state;
    iGrillTempUnit tempUnit;
    NSInteger temp;
}
@end

#endif
