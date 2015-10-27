//
//  CCVideoOutputSampleBufferFactory.m
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

#import "CCVideoOutputSampleBufferFactory.h"
#import <UIKit/UIKit.h>

@implementation CCVideoOutputSampleBufferFactory

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // Lock the base address of the pixel buffer
  CVPixelBufferLockBaseAddress(imageBuffer, 0);

  // Get the number of bytes per row for the pixel buffer
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // Get the pixel buffer width and height
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);

  // Create a device-dependent RGB color space
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  if (!colorSpace) {
    NSLog(@"CGColorSpaceCreateDeviceRGB failure");
    return nil;
  }

  // Get the base address of the pixel buffer
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  // Get the data size for contiguous planes of the pixel buffer.
  size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);

  // Create a Quartz direct-access data provider that uses data we supply
  CGDataProviderRef provider =
      CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
  // Create a bitmap image from data supplied by our data provider
  CGImageRef cgImage =
      CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace,
                    kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                    provider, NULL, true, kCGRenderingIntentDefault);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);

  // Create and return an image object representing the specified Quartz image
  UIImage *image = [UIImage imageWithCGImage:cgImage];
  CGImageRelease(cgImage);

  CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

  return image;
}

@end
