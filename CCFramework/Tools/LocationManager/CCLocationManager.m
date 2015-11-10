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
#import "Config.h"
#import <UIKit/UIKit.h>

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
@property (nonatomic, strong) Completion completion;

@end

@implementation CCLocationManager

-(id)init
{
    if (self = [super init])
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

    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }

    if (__IPHONE_8_0)
    {
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager setDistanceFilter:kCLLocationAccuracyNearestTenMeters];
    }
}

-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
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
    [self.locationManager startUpdatingLocation];
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
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [self.locationManager requestAlwaysAuthorization]; // 永久授权
                [self.locationManager requestWhenInUseAuthorization]; //使用中授权
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
    [self.locationManager stopUpdatingLocation];
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
        _completion([NSString stringWithFormat:@"请在系统设置中，打开\"隐私 - 定位服务\", 并允许%@使用定位服务",AppName]);
}


@end
