//
//  CCImageScrollView.m
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

#import "CCImageScrollView.h"

@interface CCImageScrollView () <UIScrollViewDelegate> {
    CGSize _imageSize;

    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}

@end

@implementation CCImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _aspectFill = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.scrollsToTop = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];

    [self centerZoomView];
}

- (void)setAspectFill:(BOOL)aspectFill
{
    if (_aspectFill != aspectFill) {
        _aspectFill = aspectFill;

        if (_zoomView) {
            [self setMaxMinZoomScalesForCurrentBounds];

            if (self.zoomScale < self.minimumZoomScale) {
                self.zoomScale = self.minimumZoomScale;
            }
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);

    if (sizeChanging) {
        [self prepareToResize];
    }

    [super setFrame:frame];

    if (sizeChanging) {
        [self recoverFromResizing];
    }

    [self centerZoomView];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

- (void)scrollViewDidZoom:(__unused UIScrollView *)scrollView
{
    [self centerZoomView];
}

#pragma mark - Center zoomView within scrollView

- (void)centerZoomView
{
    // center zoomView as it becomes smaller than the size of the screen

    // we need to use contentInset instead of contentOffset for better positioning when zoomView fills the screen
    if (self.aspectFill) {
        CGFloat top = 0;
        CGFloat left = 0;

        // center vertically
        if (self.contentSize.height < CGRectGetHeight(self.bounds)) {
            top = (CGRectGetHeight(self.bounds) - self.contentSize.height) * 0.5f;
        }

        // center horizontally
        if (self.contentSize.width < CGRectGetWidth(self.bounds)) {
            left = (CGRectGetWidth(self.bounds) - self.contentSize.width) * 0.5f;
        }

        self.contentInset = UIEdgeInsetsMake(top, left, top, left);
    } else {
        CGRect frameToCenter = self.zoomView.frame;

        // center horizontally
        if (CGRectGetWidth(frameToCenter) < CGRectGetWidth(self.bounds)) {
            frameToCenter.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frameToCenter)) * 0.5f;
        } else {
            frameToCenter.origin.x = 0;
        }

        // center vertically
        if (CGRectGetHeight(frameToCenter) < CGRectGetHeight(self.bounds)) {
            frameToCenter.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frameToCenter)) * 0.5f;
        } else {
            frameToCenter.origin.y = 0;
        }

        self.zoomView.frame = frameToCenter;
    }
}

#pragma mark - Configure scrollView to display new image

- (void)displayImage:(UIImage *)image
{
    // clear view for the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;

    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;

    // make views to display the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_zoomView];

    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setInitialZoomScale];
    [self setInitialContentOffset];
    self.contentInset = UIEdgeInsetsZero;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;

    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / _imageSize.width;   // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height; // the scale needed to perfectly fit the image height-wise
    CGFloat minScale;
    if (!self.aspectFill) {
        minScale = MIN(xScale, yScale); // use minimum of these to allow the image to become fully visible
    } else {
        minScale = MAX(xScale, yScale); // use maximum of these to allow the image to fill the screen
    }
    CGFloat maxScale = MAX(xScale, yScale);

    // Image must fit/fill the screen, even if its size is smaller.
    CGFloat xImageScale = maxScale * _imageSize.width / boundsSize.width;
    CGFloat yImageScale = maxScale * _imageSize.height / boundsSize.width;
    CGFloat maxImageScale = MAX(xImageScale, yImageScale);

    maxImageScale = MAX(minScale, maxImageScale);
    maxScale = MAX(maxScale, maxImageScale);

    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }

    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (void)setInitialZoomScale
{
    CGSize boundsSize = self.bounds.size;
    CGFloat xScale = boundsSize.width / _imageSize.width;   // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height; // the scale needed to perfectly fit the image height-wise
    CGFloat scale = MAX(xScale, yScale);
    self.zoomScale = scale;
}

- (void)setInitialContentOffset
{
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.zoomView.frame;

    CGPoint contentOffset;
    if (CGRectGetWidth(frameToCenter) > boundsSize.width) {
        contentOffset.x = (CGRectGetWidth(frameToCenter) - boundsSize.width) * 0.5f;
    } else {
        contentOffset.x = 0;
    }
    if (CGRectGetHeight(frameToCenter) > boundsSize.height) {
        contentOffset.y = (CGRectGetHeight(frameToCenter) - boundsSize.height) * 0.5f;
    } else {
        contentOffset.y = 0;
    }

    [self setContentOffset:contentOffset];
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.zoomView];

    _scaleToRestoreAfterResize = self.zoomScale;

    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];

    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);

    // Step 2: restore center point, first making sure it is within the allowable range.

    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:self.zoomView];

    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);

    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];

    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);

    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);

    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

@end
