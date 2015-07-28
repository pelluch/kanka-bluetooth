//
//  iGrillBLEManager.h
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
#import "iGrillBLEManagerDelegate.h"

@interface iGrillBLEManager : NSObject

//!An object that implements the iGrillBLEManagerDelegateProtocol protocol.  The delegate will receive calls from iGrillBLEManager when certain events occur.
@property (nonatomic) id<iGrillBLEManagerDelegate> delegate;

/*!
 * \brief Initializes iGrillBLEManager with a delegate and an identifier used for CoreBluetooth state restoration.
 *
 *
 * \param delegate Object that implements iGrillBLEManagerProtcol.  The delegate will receive updates from the iGrillBLEManager.  Can be nil.
 *
 * \param restorationId  Used by CoreBluetooth for state restoration if the app is killed by the system to maintain connected devices.  Pass nil if state restoration isn’t required.  CoreBluetooth state restoration is only supported in iOS 7 and up.  If iOS version is less than 7 restorationId is ignored.
 *
 * \return The initialized instance of iGrillBLEManager.
 */
-(id) initWithDelegate:(id<iGrillBLEManagerDelegate>) delegate andRestorationId:(NSString*)restorationId;

/*!
 * \brief Registers a class derived from iGrillBLEDevice.  Used to retrieve service UUIDs to scan for.  Can be called multiple times to support additional iGrill device types.
 *
 *
 * \param deviceClass : Class instance of the device type to support and scan for.  This class definition must include a static class method of signature +(NSString*) igrillServiceUUID : which returns a the UUID string of an iGrill device service to support.
 *
 *
 * \return YES if deviceClass is successfully registered, or NO if deviceClass doesn’t implement igrillServiceUUID method.
 */
-(BOOL) registeriGrillDeviceClass:(Class)deviceClass;


/*!
 * \return YES if Bluetooth state is ready for scanning, NO if Bluetooth isn’t ready or not supported.
 */
-(BOOL) isReadyToScan;

/*!
 * \return YES if the system supports Bluetooth Low Energy,  NO otherwise.
 */
-(BOOL) isBLESupported;

/*!
 * \brief Initiates device scan using the currently registered classes.
 *
 * \param allowDuplicates   YES disables duplicate device advertisement filtering.  NO results in only one advertisement to be processed per device unless the data in the advertisement changes.  If you plan on using iGrillBLEManager::cullDiscoveredDevicesOlderThan: allowDuplicates should be YES.
 *
 * \returns YES if scan starts successfully, NO if Bluetooth state isn’t ready or no device classes registered.
 */
-(BOOL) startScan:(BOOL)allowDuplicates;

/*!
 * \brief Stops the current scan.
 */
-(void) stopScan;

/*!
 * \brief Attempts to connect to an advertising iGrill device.
 *
 *  On successful connection the iGrillBLEManager’s delegate will receive igrillBLEManager:deviceConnected: call.  If the connection fails the delegate will receive igrillBLEManager:deviceConnectFailed:withError:.
 *
 * \param device The discovered device to connected to.
 */
-(void) connectiGrill:(iGrillBLEDevice*)device;

/*!
 * \brief Disconnects a connected iGrill.  Upon disconnect the iGrillBLEManager will receive iGrillBLEManager:deviceDisconnected: call.
 *
 * \param device The iGrill to disconnect
 */
-(void) disconnectiGrill:(iGrillBLEDevice*)device;

/*!
 * \return an array of iGrill devices that have been discovered and no yet connected.
 */
-(NSArray*) discoverediGrills;

/*!
 \return an array of currently connected iGrill devices.
 */
-(NSArray*) connectediGrills;

/*!
 * \brief Processes the discovered iGrills list and removes instances that were discovered before the current time – the passed seconds parameter.
 * The iGrillBLEManager uses duplicate advertisement packets to keep discovered devices “fresh”.  This method allows devices that haven’t sent an advertisement (because they are out of range, turned off or connected to another device) in a while to be removed from the discovered list.
 * For each device removed from the discovered list the iGrillBLEManager’s delegate will receive a iGrillBLEManager:undiscoveredDevice: call.
 *
 *
 * \param seconds The time interval before the current time to test discovered devices against.  Devices that haven’t sent an advertisement in this amount of time will be removed from the discovered list.
 */
-(void) cullDiscoveredDevicesOlderThan:(NSTimeInterval)seconds;

@end
