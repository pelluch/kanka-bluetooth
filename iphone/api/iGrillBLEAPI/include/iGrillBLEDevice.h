//
//  iGrillBLEDevice.h
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
#import <Foundation/NSUUID.h>

#import "iGrillBLEAPITypes.h"

@interface iGrillBLEDevice : NSObject

/*!
 * \brief  Returns the current connection state of the iGrill device.
 *
 * \return The current connection state of the iGrill
 */
-(iGrillConnectionState) connectionState;


/*!
 * \return The embedded name of the device.  For example: iGrillmini-0000.
 */
-(NSString*) deviceName;

/*!
 * \return Unique identifier for device.  This value is persistent between connections to the device.  The value is not guaranteed to be persistent if the network settings of the iOS device are reset.
 */
-(NSUUID*) deviceId;

/*!
 * \return The maximum temperature value that can be set for an alarm in the current unit of the device (C/F).
*/
-(NSInteger) maxAlarmTemp;

/*!
 * \return The minimum temperature value that can be set for an alarm in the current unit of the device (C/F).
 */
-(NSInteger) minAlarmTemp;

/*!
 * \return The current temperature unit used by the device.  iGrillTempUnit_C or iGrillTempUnit_F.
*/
-(iGrillTempUnit) tempUnitForDevice;

/*!
 \return The number of seconds the LED will light up when the button is pressed while the connected iOS device is out of proximity.
 */
-(NSInteger) displayDelay;

/*!
 * \return The current battery level as a percentage.  Range from 0-100.
Set Device Info
*/
-(NSInteger) batteryLevel;

/*!
 * \brief Set the temperature unit used by the device.  iGrillTempUnit_C or iGrillTempUnit_F.
 *
 * \param unit The temperature unit to use.
 */
-(void) setTempUnitForDevice:(iGrillTempUnit)unit;

/*!
 * \brief Set the number of seconds the LED will light up when the button is pressed while the connected iOS device is out of proximity.
 *
 * \param delay The number of seconds to light LED.
 */
-(void) setDisplayDelay:(NSInteger)delay;


///@{
//! @name Probe Info

/*!
 * \return The maximum number of probes supported by the iGrill device.
 */
-(NSInteger) numberOfProbesSupported;

/*!
 * \brief Returns whether the probe at the given index is connected.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return YES if the probe is connected, NO otherwise.
*/
-(BOOL)     isProbeConnected:(NSInteger)probeIndex;

/*!
 * \brief Tests whether the probe is returning temperature values within the supported range.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return YES if the temperatures are in the supported range, NO otherwise.
 */
-(BOOL)     isTempInRange:(NSInteger)probeIndex;

/*!
 * \brief Returns the current temperature reading for the probe at the given index in the current temperature unit used by the probe.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return The current probe temperature in the probe’s current temperature unit.
 */
-(NSInteger) currentTemperatureForProbe:(NSInteger)probeIndex;

/*!
 * \brief Returns whether the probe at the given index has the high alarm threshold value enabled.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return YES if the high threshold is enabled, NO otherwise.
 */
-(BOOL)     isHighThresholdEnabledForProbe:(NSInteger)probeIndex;

/*!
 * \brief Returns the high threshold alarm value of the probe at the given index in the current temperature unit used by the probe.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \param The high threshold alarm value in the current temperature unit used by the probe.
 */
-(NSInteger) highThresholdForProbe:(NSInteger)probeIndex;

/*!
 * \brief Retrieves the high threshold alarm value of the probe at the given index converted to the provided temperature unit.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \param tempUnit The temperature unit of the returned value.
 *
 * \return The high threshold alarm value converted to the given temperature unit if necessary.
 */
-(NSInteger) highThresholdForProbe:(NSInteger)probeIndex inUnit:(iGrillTempUnit)tempUnit;

/*!
 * \brief Returns whether the probe at the given index has the low alarm threshold value enabled.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return YES if the low threshold is enabled, NO otherwise.
 */
-(BOOL)     isLowThresholdEnabledForProbe:(NSInteger)probeIndex;

/*!
 * \brief Returns the low threshold alarm value of the probe at the given index in the current temperature unit used by the probe.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return The low threshold alarm value in the current temperature unit used by the probe.
 */
-(NSInteger) lowThresholdForProbe:(NSInteger)probeIndex;

/*!
 * \brief Retrieves the low threshold alarm value of the probe at the given index converted to the provided temperature unit.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \param tempUnit The temperature unit of the returned value.
 *
 * \return The low threshold alarm value converted to the given temperature unit if necessary.
 */
-(NSInteger) lowThresholdForProbe:(NSInteger)probeIndex inUnit:(iGrillTempUnit)tempUnit;

/*!
 * \brief Returns the temperature unit currently being used by the probe at the given index.
 This value will only differ from the value returned by tempUnitForDevice between the time the device unit is changed and the probe info is updated.  Most of the time the value will match.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return Either iGrillTempUnit_C or iGrillTempUnit_F.
 */
-(iGrillTempUnit) tempUnitForProbe:(NSInteger)probeIndex;

/*!
 * \brief Returns whether or not a temperature alarm has been triggered for the probe at the given index.
 *  Alarms are triggered when the temperature exceeds the high threshold or dips below the low threshold.
 *
 * \param probeIndex : The index of the probe to query.
 *
 * \return YES if the alarm is currently active, NO otherwise.
 */
-(BOOL)     alarmOnForProbe:(NSInteger)probeIndex;

/*!
 * \brief Returns whether either alarm threshold for the probe at the given index is set.
 *
 * \param probeIndex The index of the probe to query.
 *
 * \return YES if the alarm is enabled, NO otherwise.
 */
-(BOOL)     alarmEnabledForProbe:(NSInteger)probeIndex;

///@}

///@{
//! @name Set probe info

/*!
 * \brief Sets both the high and low temperature alarm thresholds for the probe at the given index.
 *  The passed values are assumed to be in the temperature unit used by the device.
 *
 * \param probeIndex The index of the probe to modify.
 *
 * \param high The high threshold value
 *
 * \param low  The low threshold value
 */
-(void) setThresholdsForProbe:(NSInteger)probeIndex high:(NSInteger)high low:(NSInteger)low;

/*!
 * \brief Sets the high temperature alarm threshold value for the probe at the given index.
 *  The value is assumed to be in the temperature unit of the device.
 *  Making this call also disables the probe's low threshold.
 *
 * \param high The high threshold value.
 *
 * \param probeIndex The index of the probe to modify.
 */
-(void) setHighThreshold:(NSInteger)high forProbe:(NSInteger)probeIndex;


/*!
 * \brief Turns off the alarm for the probe at the given index.
 * This method essentially sets the high and low thresholds to the “off” value.
 *
 * \param probeIndex : The index of the probe to modify.
 */
-(void) turnOffAlarmForProbe:(NSInteger)probeIndex;

/*!
 * \brief Sends an acknowledgement to the device that the user is aware the alarm is going off.
 * This will stop the alarm sound on the device without turning off any of the probes’ alarms.  When the temperature falls back within the active threshold range the alarm will become active again and go off if the temperature exceeds the threshold values.
 */
-(void) sendAcknowledgementForAlarm;

///@}

///@{
//! \name RSSI

/*!
 *  \brief Initiates an RSSI update on the underlying peripheral object.
 *  The update is not synchronous.  Once the RSSI update is complete the registered
 *  data observers will be notified.
 */
-(void) updateRSSI;

/*!
 *  \brief The last RSSI value received from the iGrill.
 *  RSSI is a measurement of signal strength in decibels.  The higher the number the stronger the signal.
 *  \return RSSI value
 */
-(NSInteger) RSSIValue;


///@}

///@{
//! @name Firmware Info

/*!
 * \return the firmware version currently on the device.
*/
-(NSString*) firmwareVersion;

/*!
 *  \brief Period deliited version string of firmware available to upgrade to if available.
 *  Implementes in child class for specific iGrill device type
 *  \example 1.0.0
 *  
 *  \return Period delimited version string of available firmware.
 */
-(NSString*) localFirmwareVersion;

/*!
 *  \brief Returns whether a firmware update is available.
 *  The default implementation of this compares the localFirmareVersion and the version
 *  returned by the device and returns YES if the local version is greater.
 *
 *  \return YES if firmware update available, NO otherwise
 */
-(BOOL)     firmwareUpdateAvailable;

/*!
 *  \brief Returns whether the firmware is currently being updated.
 *  \return YES if firmware updating, NO otherwise
 */
-(BOOL)     updatingFirmware;

/*!
 *  \brief returns the firmware update progress.
 *  The progress is returned as a percent between 0 and 100 inclusive.
 *  
 *  \return Firmware udpate progress
 */
-(NSInteger) firmwareUpdateProgress;

/*!
 *  \brief Initiates firmware update
 *  Firmware update will only begin if firmwareUpdateAvailable returns YES and the
 *  firmware isn't already being updated.
 */
-(void) updateFirmware;

///@}

///@{
//! @name Data Observer

/*!
 *  \brief Registers an observer that receives a selector call when the iGrill's data is updated.
 *  The observer is stored with weak referencing to prevent dangling references or reference loops.
 *  The selector should take one argument of type iGrillBLEDevice*.
 *
 *  \param  observer    The target to call the selector on when the iGrill's data is updated
 *  \param  selector    The selector to call on the observer when the iGrill's data is updated.
 */
-(void) registerDataObserver:(id<NSObject>)observer withSelector:(SEL)selector;

/*!
 *  \brief Unregisters an observer.
 *  Specifiying a selector will remove just the instance of the observer using that selector.
 *  If selector is passed as nil then all references to the observer are removed.
 *
 *  \param  observer    Observer to remove
 *  \param  selector    Selector to filter observer on, or nil to remove all instances of observer.
 */
-(void) removeDataObserver:(id<NSObject>)observer forSelector:(SEL)selector;

///@}
@end
