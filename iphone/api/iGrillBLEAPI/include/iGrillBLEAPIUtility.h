//
//  iGrillBLEAPIUtility.h
//  iGrillBLEAPI
//
//  Created by Michael Nannini on 2/25/14.
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

@interface iGrillBLEAPIUtility : NSObject

/*!
 *  \brief Converts Fahrenheit to Celsius
 */
+(NSInteger) convertFtoC:(NSInteger)f;

/*!
 *  \brief Converts Celsuis to Fahrenheit
 */
+(NSInteger) convertCtoF:(NSInteger)c;

@end
