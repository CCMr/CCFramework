//
//  CCAnnotation.m
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


#import "CCAnnotation.h"

@implementation CCAnnotation

- (id)initWithCLRegion:(CLRegion *)newRegion title:(NSString *)title subtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        self.region = newRegion;
        _coordinate = _region.center;
        self.radius = _region.radius;
        self.title = title;
        self.subtitle = subtitle;
    }

    return self;
}


/*
 This method provides a custom setter so that the model is notified when the subtitle value has changed.
 */
- (void)setRadius:(CLLocationDistance)newRadius {
    [self willChangeValueForKey:@"subtitle"];

    _radius = newRadius;

    [self didChangeValueForKey:@"subtitle"];
}

- (void)dealloc {
    _region = nil;
    _title = nil;
    _subtitle = nil;
}


@end
