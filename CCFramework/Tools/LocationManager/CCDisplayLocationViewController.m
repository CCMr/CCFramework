//
//  CCDisplayLocationViewController.m
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


#import "CCDisplayLocationViewController.h"
#import <MapKit/MapKit.h>
#import "CCAnnotation.h"

@interface CCDisplayLocationViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation CCDisplayLocationViewController

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    }
    return _mapView;
}

- (void)loadLocations {
    CLLocationCoordinate2D coord = [_location coordinate];
    CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord
                                                                  radius:10.0
                                                              identifier:[NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude]];

    // Create an annotation to show where the region is located on the map.
    CCAnnotation *myRegionAnnotation = [[CCAnnotation alloc] initWithCLRegion:newRegion title:NSLocalizedStringFromTable(@"MessageLocation", @"MessageDisplayKitString", nil) subtitle:_geolocations];
    myRegionAnnotation.coordinate = newRegion.center;
    myRegionAnnotation.radius = newRegion.radius;

    [self.mapView addAnnotation:myRegionAnnotation];

    //放大到标注的位置
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 150, 150);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Life cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadLocations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"Location", @"MessageDisplayKitString", @"地理位置");

    [self.view addSubview:self.mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.mapView = nil;
}


@end
