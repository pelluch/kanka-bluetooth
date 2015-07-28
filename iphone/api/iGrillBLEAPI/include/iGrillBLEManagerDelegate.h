//
//  iGrillBLEManagerDelegate.h
//  iGrillBLEAPI
//
//  Created by Michael Nannini on 2/21/14.
//  Copyright (c) 2014 iDevices, LLC. All rights reserved.
//

/*************************************************************************
 *  Created by iDevices LLC
 *  2010-2014 iDevices LLC
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

@class iGrillBLEManager;
@class iGrillBLEDevice;

@protocol iGrillBLEManagerDelegate <NSObject>

/*!
 * \brief Delegate receives this call when the Bluetooth state is such that it is able to scan for devices.  In the case that the Bluetooth state may be ready before the delegate instance is set, the iGrillBLEManager isReadyToScan method can be used to check scan readiness.
 *
 * \param manager The iGrillBLEManager that is ready to scan.
 */
-(void) igrillBLEManagerReadyToScan:(iGrillBLEManager*)manager;

/*!
 * \brief Delegate receives this call when the Bluetooth state changes from on to anything else.
 *
 * \param manager The iGrillBLEManager calling the method.
 */
-(void) igrillBLEManagerBluetoothUnavailable:(iGrillBLEManager*)manager;

/*!
 * \brief Delegate receives this call when a device is successfully connected.
 *
 * \param manager The iGrillBLEManager that connected the device.
 *
 * \param device The iGrill that connected
*/
-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnected:(iGrillBLEDevice*)device;

/*!
 * \brief Delegate receives this call when an iGrill disconnects, whether it is user initiated or not.
 *
 * \param manager The iGrillBLEManager that manages the device instance.
 *
 * \param device The iGrill that disconnected
*/
-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceDisconnected:(iGrillBLEDevice*)device;

/*!
 * \brief Delegate receives this call when an iGrill connection attempt fails.
 *
 * \param manager The iGrillBLEManager that attempted the connection
 *
 * \param device The iGrill that attempted to be connected.
 *
 */
-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceConnectFailed:(iGrillBLEDevice*)device;

/*!
 * \brief Delegate receives this call when the iGrillBLEManager discovers an iGrill that isn’t already in the discovered list.
 *
 * \param manager The iGrillBLEManager that discovered the device.
 *
 * \param device The iGrill that was discovered.
 */
-(void) igrillBLEManager:(iGrillBLEManager*)manager deviceDiscovered:(iGrillBLEDevice*)device;

/*!
 * \brief Delegate receives this call when devices are removed from the discovered list via iGrillBLEManager’s  cullDiscoveredDevicesOlderThan: method.
 *
 * \param manager The iGrillBLEManager that discovered the devices.
 *
 * \param device The iGrill that is being removed.
 */
-(void) igrillBLEManager:(iGrillBLEManager*)manager undiscoveredDevice:(iGrillBLEDevice*)device;
@end
