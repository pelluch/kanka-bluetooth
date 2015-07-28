//
//  KankaDevice.h
//  KankaDevice
//
//  Created by Shane Wheeler on 5/20/15.
//  Copyright (c) 2015 iDevices, LLC. All rights reserved.
//

/*************************************************************************
 *  Created by iDevices LLC
 *  2010-2015 iDevices LLC
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of iDevices LLC and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to iDevices LLC
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from iDevices LLC.
 ***************************************************************************/

#import <Foundation/Foundation.h>
#import <iGrillBLEDevice.h>

@interface KankaDevice : iGrillBLEDevice

+(NSString*) igrillServiceUUID;

@end
