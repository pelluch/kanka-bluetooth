//
//  iGrillBLEAPITypes.h
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


//! \file

#ifndef __iGrillBLEAPI_iGrillBLEAPITypes_h__
#define __iGrillBLEAPI_iGrillBLEAPITypes_h__

/*!
 \brief iGrill Temperature Units
 */
typedef enum
{
    //! Fahrenheit
    iGrillTempUnit_F = 0,
    //! Celsius
    iGrillTempUnit_C
} iGrillTempUnit;

/*!
 *  \brief Connection state of iGrill device
 */
typedef enum
{
    
    //! Not connected
    iGrillConnectionState_NotConnected = 0,
    //! Device in process of connecting
    iGrillConnectionState_Connecting,
    //! Device is connected and ready for use
    iGrillConnectionState_Connected
}iGrillConnectionState;

#endif
