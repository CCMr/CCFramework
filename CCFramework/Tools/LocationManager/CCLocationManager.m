//
//  CCLocationManager.m
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

#import "CCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "Config.h"

@interface CCLocationManager ()<CLLocationManagerDelegate>

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  定位服务
 *
 *  @since <#version number#>
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  回调函数
 *
 *  @since <#version number#>
 */
@property (nonatomic, assign) Completion completion;

@end

@implementation CCLocationManager

-(id)init
{
    if ([super init])
    {
        [self initWithLocation];
    }
    return self;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  创建定位服务
 *
 *  @since 1.0
 */
- (void)initWithLocation{
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (__IPHONE_8_0)
    {
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager setDistanceFilter:kCLLocationAccuracyNearestTenMeters];
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  启动跟踪定位
 *
 *  @since 1.0
 */
- (void)startUpdatingLocation:(Completion)completion
{
    _completion = completion;
    [_locationManager startUpdatingLocation];
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  验证授权
 *
 *  @param manager <#manager description#>
 *  @param status  <#status description#>
 *
 *  @since <#version number#>
 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status){
        case kCLAuthorizationStatusNotDetermined:
            //如果没有授权则请求用户授权
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestAlwaysAuthorization]; // 永久授权
                [_locationManager requestWhenInUseAuthorization]; //使用中授权
            }
            break;
        default:
            break;
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  获取到详细地址
 *
 *  @param manager   <#manager description#>
 *  @param locations <#locations description#>
 *
 *  @since 1.0
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations firstObject];
    //    NSLog(@"%@",[NSString stringWithFormat:@"经度:%3.5f\n纬度:%3.5f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude]);
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            if (_completion)
                _completion(@{@"currentLocation":currentLocation,@"address":[placemark addressDictionary]});
        }
    }];
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  定位错误信息
 *
 *  @param manager <#manager description#>
 *  @param error   <#error description#>
 *
 *  @since 1.0
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied)
        NSLog(@"Loaction %ld",(long)error.code);
}


@end
