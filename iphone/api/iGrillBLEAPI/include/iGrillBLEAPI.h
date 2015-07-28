//
//  iGrillBLEAPI.h
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

#import <iGrillBLEAPITypes.h>
#import <iGrillBLEManager.h>
#import <iGrillBLEDevice.h>
#import <iGrillBLEAPIUtility.h>


/*!
 *  \mainpage
 *
 *  \section gettingstarted_section Getting Started
 *
 *  \subsection requiredfiles_subsection Required Files
 *  
 *  Common iGrill BLE Support
 *  - Frameworks
 *      - Foundation
 *      - CoreBluetooth
 *      - Security
 *  - Headers
 *      - iGrillBLEAPI.h
 *      - iGrillBLEAPITypes.h
 *      - iGrillBLEAPIUtility.h
 *      - iGrillBLEDevice.h
 *      - iGrillBLEManager.h
 *      - iGrillBLEManagerDelegate.h
 *  - Libraries
 *      - libiGrillBLEAPI.a
 *      - libPeripheral.a
 *
 *  iGrill mini Support.
 *  In addition to Common iGrill BLE files
 *  - Headers
 *      - iGrillMiniDevice.h
 *  - Libraries
 *      - libiGrillMiniDevice.a
 *
 *  \subsection link_subsection Linking Libraries
 *
 *  The iGrill libraries contain categories on existing classes.  For categories to be properly linked into the project
 *  the -ObjC linker flag should be used.  Alternatively -force_load <library file path\> with the required libraries can be used
 *  if you don't want to use -ObjC.
 *
 *  \subsection managersetup_subsection iGrillBLEManager Setup
 *
 *  The iGrillBLEManager is responsible for discovering, connecting and disconnecting iGrill
 *  devices.  The steps to create and setup an iGrillBLEManager are as follows:
 *
 *  -# Create Instance
 <br>
 *      \code
        iGrillBLEManager* manager = [[iGrillBLEManager alloc] initWithDelegate:self andRestorationId:@"Your Restoration Id"];
        \endcode
 <br>
 *      In this example the calling object (self) is the delegate.  The delegate should implement the iGrillBLEManagerDelegate
 *      protocol so it can receive iGrill discovery, connect and disconnect events.
 *      The restoration id value is an optional argument to pass when Core Bluetooth state preservation and restoration support
 *      is wanted.  See \link staterestoration_section State Preservation and Restoration \endlink for more information.
 *  -# Register iGrill device classes
 *  <br>
 *      The iGrillBLEManager scans for devices based on advertised service UUIDs.  An iGrill device class must be an ancestor of 
 *  iGrillBLEDevice and implement +(NSString*) igrillServiceUUID that returns the string representation of the service UUID 
 *  advertised by the iGrill device.  Registering an iGrill device class serves two purposes: 1. It
 *  allows the manager to populate a list of service UUIDs to scan for and 2. associates each service UUID with an iGrill device 
 *  class.  When a new device is detected the manager creates an instance of the iGrill device class associated with the advertised 
 *  service UUID.
 <br>
 *      \code
        if ( ![manager registeriGrillDeviceClass:[iGrillMiniDevice class]] )
        {
            // Error!
        }
        \endcode
 *
 *      If the provided class does not implement igrillServiceUUID or the implementation returns a non-NSString object the
 *      register method will return NO.  Also if the returned string does not resolve to a UUID format an exception will be thrown.
 *
 *  -#  Begin Scanning
 *      <br>The next step is to start scanning for available iGrills.  But first we need to make Bluetooth is supported
 *      and available.  The iGrillBLEManagerDelegate protocol declares the method 
 *      iGrillBLEManagerDelegate::igrillBLEManagerReadyToScan: .  The delegate receives this call when the Bluetooth state
 *      has reached a point where scanning can begin.
 *      <br>
 *      \code
        -(void) igrillBLEManagerReadyToScan:(iGrillBLEManager*)manager
        {
            //Redundant check
            if ( [manager isReadyToScan] )
            {
                [manager startScan:YES];
            }
        }
        \endcode
 *      <br>
 *      Now when a registered iGrill device is discovered the iGrillBLEManagerDelegate will receive 
 *      iGrillBLEManagerDelegate::igrillBLEManager:deviceDiscovered:.  To get an array of currently advertising iGrills use 
 *      iGrillBLEManager::discoverediGrills.
 *
 *  \subsection connecting_subsection Connecting to iGrillBLEDevice
 *
 *  To connect to an iGrillBLEDevice simply pass it to iGrillBLEManager::connectiGrill:.  When the device successfully connects 
 *  the iGrillBLEManagerDelegate will receive iGrillBLEManagerDelegate::igrillBLEManager:deviceConnected:.  Additionally the iGrill 
 *  will be removed from the discovered list and moved into the iGrillBLEManager::connectediGrills list.  Any UI regarding these 
 *  arrays should be updated accordingly.
 *
 *
 *  Even though the iGrill has established a connection it may not be ready to communicate with.  The 
 *  iGrillBLEDevice::connectionState is provided to query the device on it's current connection state.  When the state is 
 *  iGrillConnectionState_Connecting the iGrill may be performing authentication checks.  Once the state is 
 *  iGrillConnectionState_Connected the iGrill is ready to communicate with the app.
 *
 *  \subsection communicating_subsection Communicating with iGrillBLEDevice
 *  
 *  When an iGrill device connects it needs to send over relevant data to the app.  When new data is received from the iGrill it
 *  notifies all data observers registered with it.  To register a data observer pass a target object and a selector to call 
 *  to iGrillBLEDevice::registerDataObserver:withSelector:.  When the iGrill sends data updates (such as temperature changes) the 
 *  provided selector is sent to the observer object.  The selector should take one argument of type iGrillBLEDevice*.
 *  \code
    [igrillDevice registerDataObserver:self withSelector:@selector(dataUpdated:)];
    \endcode
 *
 *  Read methods in iGrillBLEDevice that rely on data updates include:
 *  - iGrillBLEDevice::currentTemperatureForProbe:
 *  - iGrillBLEDevice::highThresholdForProbe:
 *  - iGrillBLEDevice::lowThresholdForProbe:
 *  - iGrillBLEDevice::tempUnitForDevice
 *  \note The probe temperature values will automatically update when the value changes.
 *
 *  .
 *  Some write methods also rely on data updates to synchronize the written data with the local cache.  The value to write is
 *  sent to the device and either initiates a read update or waits for a notify to update the locally cached value.
 *  - iGrillBLEDevice::setThresholdsForProbe:high:low:
 *  - iGrillBLEDevice::setHighThreshold:forProbe:
 *
 *  \subsection disconnecting_subsection Disconnecting an iGrillBLEDevice
 *
 *  To manually disconnect an iGrillBLEDevice pass the object to iGrillBLEManager::disconnectiGrill:.  When the device disconnects
 *  the iGrillBLEManagerDelegate will receive iGrillBLEManagerDelegate::igrillBLEManager:deviceDisconnected:.
 *  \note The delegate will receive this call any time the device disonnects regardless of the cause.
 *
 *  \subsection bluetoothoff_subsection Responding to change in Bluetooth state.
 *
 *  If at any Bluetooth becomes unavailable (via airplane more or turning it off), the iGrillBLEManagerDelegate will receive 
 *  iGrillBLEManagerDelegate::igrillBLEManagerBluetoothUnavailable:.  Additionally all connected devices will effectively be 
 *  disconnected.  When Bluetooth becomes available again the iGrillBLEManagerDelegate::igrillBLEManagerReadyToScan: method will be 
 *  called.
 *
 *  \section staterestoration_section State Preservation and Restoration
 *  As of iOS 7 CoreBluetooth supports state preservation and restortaion.  Your app can opt in to this feature to ask the system to
 *  preserve the state of your app’s central and peripheral managers and to continue performing certain Bluetooth-related tasks on 
 *  their behalf, even when your app is no longer running. When one of these tasks completes, the system relaunches your app into the 
 *  background and gives your app the opportunity to restore its state and to handle the event appropriately.
 *
 *  To opt into state preservation and restoration:
 *  -# The app must have the "App Communicates using CoreBluetooth" background mode
 *  included in "Required background modes" in the info.plist.
 *  -# When intializing the iGrillBLEManager, pass a unique string value as the restorationId argument.  The system uses this ID to 
 *  identify a specific central manager. As a result, the ID must remain the same for subsequent executions of the app in order for 
 *  the iGrillBLEManager to be successfully restored.
 *  .
 *  For each iGrill successfully restored the iGrillBLEManagerDelegate receives
 *  iGrillBLEManagerDelegate::igrillBLEManager:deviceConnected:.
 */