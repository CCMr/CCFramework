//
//  CLLocation+CH1903.h
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

//This small extension allows you to easly manage CH1903 (swiss coordinate system) within the CLLocation object.
//All the calculation are based on the official swiss federal informations:
// 瑞士坐标系转换

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocation (CH1903)

/*!
 @method     initWithCH1903x
 @abstract   initialize a CLLocation-Instance with CH1903 x/y coorinates
 */
- (id)initWithCH1903x:(double)x y:(double)y;


/*!
 @method     CH1903Y
 @abstract   returns the CH1903 y value of the location
 */
- (double)CH1903Y;

/*!
 @method     CH1903X
 @abstract   returns the CH1903 x value of the location
 */
- (double)CH1903X;


#pragma mark -
#pragma mark static methodes

+ (double)CHtoWGSlatWithX:(double)x y:(double)y;
+ (double)CHtoWGSlongWithX:(double)x y:(double)y;
+ (double)WGStoCHyWithLatitude:(double)lat longitude:(double)lng;
+ (double)WGStoCHxWithLatitude:(double)lat longitude:(double)lng;

+ (double)decToSex:(double)angle;
+ (double)degToSec:(double)angle;
+ (double)sexToDec:(double)angle;


@end