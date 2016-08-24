//
//  UIImageView+Additions.m
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

#import "UIImageView+Additions.h"
#import <objc/runtime.h>
#import "UIView+Method.h"
#import "CCRingProgressView.h"
#import "CCProperty.h"

typedef NS_ENUM(NSInteger, CCImageViewStatus) {
    /** 默认 */
    CCImageViewStatusNone = 0,
    /** 下载完成 */
    CCImageViewStatusLoaded = 1,
    /** 下载中 */
    CCImageViewStatusLoading = 2,
    /** 下载失败 */
    CCImageViewStatusFail = 3,
    /** 点击下载状态 */
    CCImageViewStatusClickDownload = 4
};


@implementation UIImageView (Additions)

#pragma mark -
#pragma mark :. Additions

+ (id)imageViewWithImageNamed:(NSString *)imageName
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
}

+ (id)imageViewWithFrame:(CGRect)frame
{
    return [[UIImageView alloc] initWithFrame:frame];
}

+ (id)imageViewWithStretchableImage:(NSString *)imageName
                              Frame:(CGRect)frame
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
    return imageView;
}

- (void)setImageWithStretchableImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    self.image = [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
}

+ (id)imageViewWithImageArray:(NSArray *)imageArray
                     duration:(NSTimeInterval)duration;
{
    if (imageArray && !([imageArray count] > 0)) {
        return nil;
    }
    UIImageView *imageView = [UIImageView imageViewWithImageNamed:[imageArray objectAtIndex:0]];
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 0; i < imageArray.count; i++) {
        UIImage *image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [images addObject:image];
    }
    [imageView setImage:[images objectAtIndex:0]];
    [imageView setAnimationImages:images];
    [imageView setAnimationDuration:duration];
    [imageView setAnimationRepeatCount:0];
    return imageView;
}

// 画水印
- (void)setImage:(UIImage *)image
   withWaterMark:(UIImage *)mark
          inRect:(CGRect)rect
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    // CGContextRef thisctx = UIGraphicsGetCurrentContext();
    // CGAffineTransform myTr = CGAffineTransformMake(1, 0, 0, -1, 0, self.height);
    // CGContextConcatCTM(thisctx, myTr);
    //CGContextDrawImage(thisctx,CGRectMake(0,0,self.width,self.height),[image CGImage]); //原图
    //CGContextDrawImage(thisctx,rect,[mask CGImage]); //水印图
    //原图
    [image drawInRect:self.bounds];
    //水印图
    [mark drawInRect:rect];
    // NSString *s = @"dfd";
    // [[UIColor redColor] set];
    // [s drawInRect:self.bounds withFont:[UIFont systemFontOfSize:15.0]];
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}

- (void)setImage:(UIImage *)image withStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    //原图
    [image drawInRect:self.bounds];
    //文字颜色
    [color set];
    // const CGFloat *colorComponents = CGColorGetComponents([color CGColor]);
    // CGContextSetRGBFillColor(context, colorComponents[0], colorComponents[1], colorComponents [2], colorComponents[3]);
    //水印文字
    if ([markString respondsToSelector:@selector(drawInRect:withAttributes:)]) {
        [markString drawInRect:rect withAttributes:@{NSFontAttributeName : font}];
    } else {
        // pre-iOS7.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [markString drawInRect:rect withFont:font];
#pragma clang diagnostic pop
    }

    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}

- (void)setImage:(UIImage *)image
withStringWaterMark:(NSString *)markString
         atPoint:(CGPoint)point
           color:(UIColor *)color
            font:(UIFont *)font
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
    //原图
    [image drawInRect:self.bounds];
    //文字颜色
    [color set];
    //水印文字

    if ([markString respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
        [markString drawAtPoint:point withAttributes:@{NSFontAttributeName : font}];
    } else {
        // pre-iOS7.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [markString drawAtPoint:point withFont:font];
#pragma clang diagnostic pop
    }


    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newPic;
}

/**
 *  @author C C, 2015-10-14
 *
 *  @brief  网络异步请求
 *
 *  @param url         请求地址
 *  @param placeholder 默认图片
 */
- (void)setImageWithURL:(NSString *)url
            placeholder:(UIImage *)placeholder
{
    self.image = placeholder;
    self.contentMode = UIViewContentModeCenter;

    NSURL *mURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        NSData *imgData = [NSData dataWithContentsOfURL:mURL options:NSDataReadingMappedIfSafe error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imgData];

            self.image = image;
            self.contentMode = UIViewContentModeScaleToFill;
            self.clipsToBounds = YES;
        });
    });
}

+ (void)LoadImageWithURL:(NSString *)url
                Complete:(void (^)(UIImage *images))block
{
    NSURL *mURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        NSData *imgData = [NSData dataWithContentsOfURL:mURL options:NSDataReadingMappedIfSafe error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (block)
                block([UIImage imageWithData:imgData]);
        });
    });
}

#pragma mark -
#pragma mark :. BetterFace

#define BETTER_LAYER_NAME @"BETTER_LAYER_NAME"
#define GOLDEN_RATIO (0.618)

static CIDetector *detector;

void hack_uiimageview_bf()
{
    Method oriSetImgMethod = class_getInstanceMethod([UIImageView class], @selector(setImage:));
    Method newSetImgMethod = class_getInstanceMethod([UIImageView class], @selector(setBetterFaceImage:));
    method_exchangeImplementations(newSetImgMethod, oriSetImgMethod);
}

- (void)setBetterFaceImage:(UIImage *)image
{
    [self setBetterFaceImage:image];
    if (![self needsBetterFace]) {
        return;
    }

    [self faceDetect:image];
}

char nbfKey;
- (void)setNeedsBetterFace:(BOOL)needsBetterFace
{
    objc_setAssociatedObject(self, &nbfKey, [NSNumber numberWithBool:needsBetterFace], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)needsBetterFace
{
    NSNumber *associatedObject = objc_getAssociatedObject(self, &nbfKey);
    return [associatedObject boolValue];
}

char fastSpeedKey;
- (void)setFast:(BOOL)fast
{
    objc_setAssociatedObject(self, &fastSpeedKey, [NSNumber numberWithBool:fast], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

char detectorKey;
- (void)setDetector:(CIDetector *)detector
{
    objc_setAssociatedObject(self, &detectorKey, detector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CIDetector *)detector
{
    return objc_getAssociatedObject(self, &detectorKey);
}

- (BOOL)fast
{
    NSNumber *associatedObject = objc_getAssociatedObject(self, &fastSpeedKey);
    return [associatedObject boolValue];
}

- (void)faceDetect:(UIImage *)aImage
{
    dispatch_queue_t queue = dispatch_queue_create("com.croath.betterface.queue", NULL);
    dispatch_async(queue, ^{
        CIImage* image = aImage.CIImage;
        if (image == nil) { // just in case the UIImage was created using a CGImage revert to the previous, slower implementation
            image = [CIImage imageWithCGImage:aImage.CGImage];
        }
        if (detector == nil) {
            NSDictionary  *opts = [NSDictionary dictionaryWithObject:[self fast] ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh
                                                              forKey:CIDetectorAccuracy];
            detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                          context:nil
                                          options:opts];
        }

        NSArray* features = [detector featuresInImage:image];

        if ([features count] == 0) {
            NSLog(@"no faces");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self imageLayer] removeFromSuperlayer];
            });
        } else {
            NSLog(@"succeed %lu faces", (unsigned long)[features count]);
            [self markAfterFaceDetect:features
                                 size:CGSizeMake(CGImageGetWidth(aImage.CGImage),
                                                 CGImageGetHeight(aImage.CGImage))];
        }
    });
}

- (void)markAfterFaceDetect:(NSArray *)features size:(CGSize)size
{
    CGRect fixedRect = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    CGFloat rightBorder = 0, bottomBorder = 0;
    for (CIFaceFeature *f in features) {
        CGRect oneRect = f.bounds;
        oneRect.origin.y = size.height - oneRect.origin.y - oneRect.size.height;

        fixedRect.origin.x = MIN(oneRect.origin.x, fixedRect.origin.x);
        fixedRect.origin.y = MIN(oneRect.origin.y, fixedRect.origin.y);

        rightBorder = MAX(oneRect.origin.x + oneRect.size.width, rightBorder);
        bottomBorder = MAX(oneRect.origin.y + oneRect.size.height, bottomBorder);
    }

    fixedRect.size.width = rightBorder - fixedRect.origin.x;
    fixedRect.size.height = bottomBorder - fixedRect.origin.y;

    CGPoint fixedCenter = CGPointMake(fixedRect.origin.x + fixedRect.size.width / 2.0,
                                      fixedRect.origin.y + fixedRect.size.height / 2.0);
    CGPoint offset = CGPointZero;
    CGSize finalSize = size;
    if (size.width / size.height > self.bounds.size.width / self.bounds.size.height) {
        //move horizonal
        finalSize.height = self.bounds.size.height;
        finalSize.width = size.width / size.height * finalSize.height;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;

        offset.x = fixedCenter.x - self.bounds.size.width * 0.5;
        if (offset.x < 0) {
            offset.x = 0;
        } else if (offset.x + self.bounds.size.width > finalSize.width) {
            offset.x = finalSize.width - self.bounds.size.width;
        }
        offset.x = -offset.x;
    } else {
        //move vertical
        finalSize.width = self.bounds.size.width;
        finalSize.height = size.height / size.width * finalSize.width;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;

        offset.y = fixedCenter.y - self.bounds.size.height * (1 - GOLDEN_RATIO);
        if (offset.y < 0) {
            offset.y = 0;
        } else if (offset.y + self.bounds.size.height > finalSize.height) {
            offset.y = finalSize.height = self.bounds.size.height;
        }
        offset.y = -offset.y;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        CALayer *layer = [self imageLayer];
        layer.frame = CGRectMake(offset.x,
                                 offset.y,
                                 finalSize.width,
                                 finalSize.height);
        layer.contents = (id)self.image.CGImage;
    });
}

- (CALayer *)imageLayer
{
    for (CALayer *layer in [self.layer sublayers]) {
        if ([[layer name] isEqualToString:BETTER_LAYER_NAME]) {
            return layer;
        }
    }

    CALayer *layer = [CALayer layer];
    [layer setName:BETTER_LAYER_NAME];
    layer.actions = @{ @"contents" : [NSNull null],
                       @"bounds" : [NSNull null],
                       @"position" : [NSNull null] };
    [self.layer addSublayer:layer];
    return layer;
}

#pragma mark -
#pragma mark :. FaceAwareFill

static CIDetector *_faceDetector;

+ (void)initialize
{
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
}

- (void)faceAwareFill
{
    // Safe check!
    if (self.image == nil) {
        return;
    }

    CGRect facesRect = [self rectWithFaces];
    if (facesRect.size.height + facesRect.size.width == 0)
        return;
    self.contentMode = UIViewContentModeTopLeft;
    [self scaleImageFocusingOnRect:facesRect];
}

- (CGRect)rectWithFaces
{
    // Get a CIIImage
    CIImage *image = self.image.CIImage;

    // If now available we create one using the CGImage
    if (!image) {
        image = [CIImage imageWithCGImage:self.image.CGImage];
    }

    // Use the static CIDetector
    CIDetector *detector = _faceDetector;

    // create an array containing all the detected faces from the detector
    NSArray *features = [detector featuresInImage:image];

    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected.
    CGRect totalFaceRects = CGRectMake(self.image.size.width / 2.0, self.image.size.height / 2.0, 0, 0);

    if (features.count > 0) {
        //We get the CGRect of the first detected face
        totalFaceRects = ((CIFaceFeature *)[features objectAtIndex:0]).bounds;

        // Now we find the minimum CGRect that holds all the faces
        for (CIFaceFeature *faceFeature in features) {
            totalFaceRects = CGRectUnion(totalFaceRects, faceFeature.bounds);
        }
    }

    //So now we have either a CGRect holding the center of the image or all the faces.
    return totalFaceRects;
}

- (void)scaleImageFocusingOnRect:(CGRect)facesRect
{
    CGFloat multi1 = self.frame.size.width / self.image.size.width;
    CGFloat multi2 = self.frame.size.height / self.image.size.height;
    CGFloat multi = MAX(multi1, multi2);

    //We need to 'flip' the Y coordinate to make it match the iOS coordinate system one
    facesRect.origin.y = self.image.size.height - facesRect.origin.y - facesRect.size.height;

    facesRect = CGRectMake(facesRect.origin.x * multi, facesRect.origin.y * multi, facesRect.size.width * multi, facesRect.size.height * multi);

    CGRect imageRect = CGRectZero;
    imageRect.size.width = self.image.size.width * multi;
    imageRect.size.height = self.image.size.height * multi;
    imageRect.origin.x = MIN(0.0, MAX(-facesRect.origin.x + self.frame.size.width / 2.0 - facesRect.size.width / 2.0, -imageRect.size.width + self.frame.size.width));
    imageRect.origin.y = MIN(0.0, MAX(-facesRect.origin.y + self.frame.size.height / 2.0 - facesRect.size.height / 2.0, -imageRect.size.height + self.frame.size.height));

    imageRect = CGRectIntegral(imageRect);

    UIGraphicsBeginImageContextWithOptions(imageRect.size, YES, 2.0);
    [self.image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.image = newImage;

    //This is to show the red rectangle over the faces
#ifdef DEBUGGING_FACE_AWARE_FILL
    NSInteger theRedRectangleTag = -3312;
    UIView *facesRectLine = [self viewWithTag:theRedRectangleTag];
    if (!facesRectLine) {
        facesRectLine = [[UIView alloc] initWithFrame:facesRect];
        facesRectLine.tag = theRedRectangleTag;
    } else {
        facesRectLine.frame = facesRect;
    }

    facesRectLine.backgroundColor = [UIColor clearColor];
    facesRectLine.layer.borderColor = [UIColor redColor].CGColor;
    facesRectLine.layer.borderWidth = 4.0;

    CGRect frame = facesRectLine.frame;
    frame.origin.x = imageRect.origin.x + frame.origin.x;
    frame.origin.y = imageRect.origin.y + frame.origin.y;
    facesRectLine.frame = frame;

    [self addSubview:facesRectLine];
#endif
}

#pragma mark -
#pragma mark :. GeometryConversion

- (CGPoint)convertPointFromImage:(CGPoint)imagePoint
{
    CGPoint viewPoint = imagePoint;

    CGSize imageSize = self.image.size;
    CGSize viewSize = self.bounds.size;

    CGFloat ratioX = viewSize.width / imageSize.width;
    CGFloat ratioY = viewSize.height / imageSize.height;

    UIViewContentMode contentMode = self.contentMode;

    switch (contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw: {
            viewPoint.x *= ratioX;
            viewPoint.y *= ratioY;
            break;
        }

        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            CGFloat scale;

            if (contentMode == UIViewContentModeScaleAspectFit) {
                scale = MIN(ratioX, ratioY);
            } else /*if (contentMode == UIViewContentModeScaleAspectFill)*/ {
                scale = MAX(ratioX, ratioY);
            }

            viewPoint.x *= scale;
            viewPoint.y *= scale;

            viewPoint.x += (viewSize.width - imageSize.width * scale) / 2.0f;
            viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0f;

            break;
        }

        case UIViewContentModeCenter: {
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;

            break;
        }

        case UIViewContentModeTop: {
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;

            break;
        }

        case UIViewContentModeBottom: {
            viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0f;
            viewPoint.y += viewSize.height - imageSize.height;

            break;
        }

        case UIViewContentModeLeft: {
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;

            break;
        }

        case UIViewContentModeRight: {
            viewPoint.x += viewSize.width - imageSize.width;
            viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0f;

            break;
        }

        case UIViewContentModeTopRight: {
            viewPoint.x += viewSize.width - imageSize.width;

            break;
        }


        case UIViewContentModeBottomLeft: {
            viewPoint.y += viewSize.height - imageSize.height;

            break;
        }


        case UIViewContentModeBottomRight: {
            viewPoint.x += viewSize.width - imageSize.width;
            viewPoint.y += viewSize.height - imageSize.height;

            break;
        }

        case UIViewContentModeTopLeft:
        default: {
            break;
        }
    }

    return viewPoint;
}

- (CGRect)convertRectFromImage:(CGRect)imageRect
{
    CGPoint imageTopLeft = imageRect.origin;
    CGPoint imageBottomRight = CGPointMake(CGRectGetMaxX(imageRect),
                                           CGRectGetMaxY(imageRect));

    CGPoint viewTopLeft = [self convertPointFromImage:imageTopLeft];
    CGPoint viewBottomRight = [self convertPointFromImage:imageBottomRight];

    CGRect viewRect;
    viewRect.origin = viewTopLeft;
    viewRect.size = CGSizeMake(ABS(viewBottomRight.x - viewTopLeft.x),
                               ABS(viewBottomRight.y - viewTopLeft.y));

    return viewRect;
}

- (CGPoint)convertPointFromView:(CGPoint)viewPoint
{
    CGPoint imagePoint = viewPoint;

    CGSize imageSize = self.image.size;
    CGSize viewSize = self.bounds.size;

    CGFloat ratioX = viewSize.width / imageSize.width;
    CGFloat ratioY = viewSize.height / imageSize.height;

    UIViewContentMode contentMode = self.contentMode;

    switch (contentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw: {
            imagePoint.x /= ratioX;
            imagePoint.y /= ratioY;
            break;
        }

        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            CGFloat scale;

            if (contentMode == UIViewContentModeScaleAspectFit) {
                scale = MIN(ratioX, ratioY);
            } else /*if (contentMode == UIViewContentModeScaleAspectFill)*/ {
                scale = MAX(ratioX, ratioY);
            }

            // Remove the x or y margin added in FitMode
            imagePoint.x -= (viewSize.width - imageSize.width * scale) / 2.0f;
            imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0f;

            imagePoint.x /= scale;
            imagePoint.y /= scale;

            break;
        }

        case UIViewContentModeCenter: {
            imagePoint.x -= (viewSize.width - imageSize.width) / 2.0f;
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;

            break;
        }

        case UIViewContentModeTop: {
            imagePoint.x -= (viewSize.width - imageSize.width) / 2.0f;

            break;
        }

        case UIViewContentModeBottom: {
            imagePoint.x -= (viewSize.width - imageSize.width) / 2.0f;
            imagePoint.y -= (viewSize.height - imageSize.height);

            break;
        }

        case UIViewContentModeLeft: {
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;

            break;
        }

        case UIViewContentModeRight: {
            imagePoint.x -= (viewSize.width - imageSize.width);
            imagePoint.y -= (viewSize.height - imageSize.height) / 2.0f;

            break;
        }

        case UIViewContentModeTopRight: {
            imagePoint.x -= (viewSize.width - imageSize.width);

            break;
        }


        case UIViewContentModeBottomLeft: {
            imagePoint.y -= (viewSize.height - imageSize.height);

            break;
        }


        case UIViewContentModeBottomRight: {
            imagePoint.x -= (viewSize.width - imageSize.width);
            imagePoint.y -= (viewSize.height - imageSize.height);

            break;
        }

        case UIViewContentModeTopLeft:
        default: {
            break;
        }
    }

    return imagePoint;
}

- (CGRect)convertRectFromView:(CGRect)viewRect
{
    CGPoint viewTopLeft = viewRect.origin;
    CGPoint viewBottomRight = CGPointMake(CGRectGetMaxX(viewRect),
                                          CGRectGetMaxY(viewRect));

    CGPoint imageTopLeft = [self convertPointFromView:viewTopLeft];
    CGPoint imageBottomRight = [self convertPointFromView:viewBottomRight];

    CGRect imageRect;
    imageRect.origin = imageTopLeft;
    imageRect.size = CGSizeMake(ABS(imageBottomRight.x - imageTopLeft.x),
                                ABS(imageBottomRight.y - imageTopLeft.y));

    return imageRect;
}


#pragma mark -
#pragma mark :. Letters

// This multiplier sets the font size based on the view bounds
static const CGFloat kFontResizingProportion = 0.42f;

- (void)setImageWithString:(NSString *)string
{
    [self setImageWithString:string color:nil circular:NO textAttributes:nil];
}

- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
{
    [self setImageWithString:string
                       color:color
                    circular:NO
              textAttributes:nil];
}

- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
                  circular:(BOOL)isCircular
{
    [self setImageWithString:string color:color circular:isCircular textAttributes:nil];
}

- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
                  circular:(BOOL)isCircular
                  fontName:(NSString *)fontName
{
    [self setImageWithString:string
                       color:color
                    circular:isCircular
              textAttributes:@{
                               NSFontAttributeName : [self fontForFontName:fontName],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               }];
}

- (void)setImageWithString:(NSString *)string
                     color:(UIColor *)color
                  circular:(BOOL)isCircular
            textAttributes:(NSDictionary *)textAttributes
{
    if (!textAttributes) {
        textAttributes = @{
                           NSFontAttributeName : [self fontForFontName:nil],
                           NSForegroundColorAttributeName : [UIColor whiteColor]
                           };
    }

    NSMutableString *displayString = [NSMutableString stringWithString:@""];

    NSMutableArray *words = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];

    //
    // Get first letter of the first and last word
    //
    if ([words count]) {
        NSString *firstWord = [words firstObject];
        if ([firstWord length]) {
            // Get character range to handle emoji (emojis consist of 2 characters in sequence)
            NSRange firstLetterRange = [firstWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
            [displayString appendString:[firstWord substringWithRange:firstLetterRange]];
        }

        if ([words count] >= 2) {
            NSString *lastWord = [words lastObject];

            while ([lastWord length] == 0 && [words count] >= 2) {
                [words removeLastObject];
                lastWord = [words lastObject];
            }

            if ([words count] > 1) {
                // Get character range to handle emoji (emojis consist of 2 characters in sequence)
                NSRange lastLetterRange = [lastWord rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
                [displayString appendString:[lastWord substringWithRange:lastLetterRange]];
            }
        }
    }

    UIColor *backgroundColor = color ? color : [self randomColor];

    self.image = [self imageSnapshotFromText:[displayString uppercaseString]
                             backgroundColor:backgroundColor
                                    circular:isCircular
                              textAttributes:textAttributes];
}

#pragma mark :. Helpers

- (UIFont *)fontForFontName:(NSString *)fontName
{

    CGFloat fontSize = CGRectGetWidth(self.bounds) * kFontResizingProportion;
    if (fontName) {
        return [UIFont fontWithName:fontName size:fontSize];
    } else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

- (UIColor *)randomColor
{

    float red = 0.0;
    while (red < 0.1 || red > 0.84) {
        red = drand48();
    }

    float green = 0.0;
    while (green < 0.1 || green > 0.84) {
        green = drand48();
    }

    float blue = 0.0;
    while (blue < 0.1 || blue > 0.84) {
        blue = drand48();
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (UIImage *)imageSnapshotFromText:(NSString *)text
                   backgroundColor:(UIColor *)color
                          circular:(BOOL)isCircular
                    textAttributes:(NSDictionary *)textAttributes
{

    CGFloat scale = [UIScreen mainScreen].scale;

    CGSize size = self.bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill ||
        self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit ||
        self.contentMode == UIViewContentModeRedraw) {
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (isCircular) {
        //
        // Clip context to a circle
        //
        CGPathRef path = CGPathCreateWithEllipseInRect(self.bounds, NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }

    //
    // Fill background of context
    //
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));

    //
    // Draw text in the context
    //
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect bounds = self.bounds;

    [text drawInRect:CGRectMake(bounds.size.width / 2 - textSize.width / 2,
                                bounds.size.height / 2 - textSize.height / 2,
                                textSize.width,
                                textSize.height)
      withAttributes:textAttributes];

    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return snapshot;
}

#pragma mark -
#pragma mark :. Reflect

/**
 *  @brief  倒影
 */
- (void)reflect
{
    CGRect frame = self.frame;
    frame.origin.y += (frame.size.height + 1);

    UIImageView *reflectionImageView = [[UIImageView alloc] initWithFrame:frame];
    self.clipsToBounds = TRUE;
    reflectionImageView.contentMode = self.contentMode;
    [reflectionImageView setImage:self.image];
    reflectionImageView.transform = CGAffineTransformMakeScale(1.0, -1.0);

    CALayer *reflectionLayer = [reflectionImageView layer];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.bounds = reflectionLayer.bounds;
    gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width / 2, reflectionLayer.bounds.size.height * 0.5);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor clearColor] CGColor],
                            (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor], nil];

    gradientLayer.startPoint = CGPointMake(0.5, 0.5);
    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    reflectionLayer.mask = gradientLayer;

    [self.superview addSubview:reflectionImageView];
}

#pragma mark -
#pragma mark :. WebCache

static char imageURLKey;
static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
static char TAG_ACTIVITY_SHOW;

- (void)sd_setImageWithURLStr:(NSString *)url
{
    [self sd_setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)sd_setImageWithURL:(NSURL *)url
{
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)sd_setImageWithURLStr:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:placeholder];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }

    if (url) {

        // check if activityView is enabled or not
        if ([self showActivityIndicatorView]) {
            [self addActivityIndicator];
        }

        __weak __typeof(self) wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [wself removeActivityIndicator];
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self cc_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [self removeActivityIndicator];
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];

    [self sd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];
}

- (NSURL *)sd_imageURL
{
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)sd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs
{
    [self sd_cancelCurrentAnimationImagesLoad];
    __weak __typeof(self) wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self cc_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)sd_cancelCurrentImageLoad
{
    [self cc_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)sd_cancelCurrentAnimationImagesLoad
{
    [self cc_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

- (UIActivityIndicatorView *)activityIndicator
{
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)setShowActivityIndicatorView:(BOOL)show
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, [NSNumber numberWithBool:show], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)showActivityIndicatorView
{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)getIndicatorStyle
{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}

- (void)addActivityIndicator
{
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self getIndicatorStyle]];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

        dispatch_main_async_safe(^{
            [self addSubview:self.activityIndicator];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        });
    }

    dispatch_main_async_safe(^{
        [self.activityIndicator startAnimating];
    });
}

- (void)removeActivityIndicator
{
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

#pragma mark -
#pragma mark :. HighlightedWebCache

#define UIImageViewHighlightedWebCacheOperationKey @"highlightedImage"

- (void)sd_setHighlightedImageWithURL:(NSURL *)url
{
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options
{
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_cancelCurrentHighlightedImageLoad];

    if (url) {
        __weak __typeof(self) wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe (^
                                     {
                                         if (!wself) return;
                                         if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock)
                                         {
                                             completedBlock(image, error, cacheType, url);
                                             return;
                                         }
                                         else if (image) {
                                             wself.highlightedImage = image;
                                             [wself setNeedsLayout];
                                         }
                                         if (completedBlock && finished) {
                                             completedBlock(image, error, cacheType, url);
                                         }
                                     });
        }];
        [self cc_setImageLoadOperation:operation forKey:UIImageViewHighlightedWebCacheOperationKey];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)sd_cancelCurrentHighlightedImageLoad
{
    [self cc_cancelImageLoadOperationWithKey:UIImageViewHighlightedWebCacheOperationKey];
}

#pragma mark - 2G/3G/4G点击加载图片、WIFI自动加载
static char tapEventLoadedKey;
static char imageTapEventKey;
static char imageURLKey;
static char imageStatusKey;
static char placeholderKey;
static char errorPlaceholderKey;
static char imageReloadCountKey;
static char imageLoadedModeKey;

#pragma mark :. getset

- (int)reloadCount
{
    NSNumber *value = objc_getAssociatedObject(self, &imageReloadCountKey);
    return [value intValue];
}

- (void)setReloadCount:(int)count
{
    objc_setAssociatedObject(self, &imageReloadCountKey, @(count), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCImageViewStatus)cc_status
{
    NSNumber *value = objc_getAssociatedObject(self, &imageStatusKey);
    if (value)
        return [value intValue];
    return CCImageViewStatusNone;
}

- (void)setCc_status:(CCImageViewStatus)cc_status
{
    objc_setAssociatedObject(self, &imageStatusKey, @(cc_status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCc_ImageURL:(id)cc_imageURL
{
    objc_setAssociatedObject(self, &imageURLKey, cc_imageURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)cc_ImageURL
{
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)cc_loadTapEvent
{
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &tapEventLoadedKey);
    if (tap == nil) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cc_handleTapEvent:)];
        [self addGestureRecognizer:tap];
        objc_setAssociatedObject(self, &tapEventLoadedKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cc_handleTapEvent:(UITapGestureRecognizer *)sender
{
    CCImageViewStatus status = self.cc_status;
    if (status == CCImageViewStatusClickDownload || status == CCImageViewStatusFail) {
        [self cc_reloadImageURL];
    } else {
        if (self.onTouchTapBlock) {
            self.onTouchTapBlock(self);
        }
    }
}

- (void)setOnTouchTapBlock:(void (^)(UIImageView *))onTouchTapBlock
{
    [self cc_loadTapEvent];
    objc_setAssociatedObject(self, &imageTapEventKey, onTouchTapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIImageView *))onTouchTapBlock
{
    return objc_getAssociatedObject(self, &imageTapEventKey);
}

- (CCRingProgressView *)cc_progressView:(BOOL)isCreate
{
    const int imageProgressTag = 204517;
    CCRingProgressView *progressView = (id)[self viewWithTag:imageProgressTag];
    if (isCreate) {
        if (progressView == nil) {
            progressView = [[CCRingProgressView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
            progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            progressView.progressTintColor = [UIColor whiteColor];
            progressView.annular = NO;
            progressView.percentShow = YES;
            progressView.percentLabelTextColor = [[UIColor alloc] initWithWhite:0.2f alpha:.8f];
            progressView.progressBackgroundColor = [[UIColor alloc] initWithWhite:1 alpha:.8];
            progressView.hidden = YES;
            progressView.tag = imageProgressTag;

            [self addSubview:progressView];
        }
        progressView.center = self.center;
        progressView.hidden = NO;

        [self bringSubviewToFront:progressView];
    }

    return progressView;
}

- (void)setCc_Placeholder:(id)cc_Placeholder
{
    objc_setAssociatedObject(self, &placeholderKey, cc_Placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)cc_Placeholder
{
    return objc_getAssociatedObject(self, &placeholderKey);
}

- (void)setCc_ErrorPlaceholder:(id)cc_ErrorPlaceholder
{
    objc_setAssociatedObject(self, &errorPlaceholderKey, cc_ErrorPlaceholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)cc_ErrorPlaceholder
{
    return objc_getAssociatedObject(self, &errorPlaceholderKey);
}

- (UIViewContentMode)loadedViewContentMode
{
    NSNumber *value = objc_getAssociatedObject(self, &imageLoadedModeKey);
    if (value == nil) {
        return -1;
    }
    return [value intValue];
}
- (void)setLoadedViewContentMode:(UIViewContentMode)loadedViewContentMode
{
    objc_setAssociatedObject(self, &imageLoadedModeKey, @(loadedViewContentMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark :.
/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param url         图片请求网址
 *  @param placeholder 默认图片
 */
- (void)cc_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
{
    [self cc_setImageWithURL:url
            placeholderImage:placeholder
       ErrorPlaceholderImage:CCResourceImage(@"cc_noimage")];
}

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param url              图片请求网址
 *  @param placeholder      默认图片
 *  @param errorPlaceholder 错误图片
 */
- (void)cc_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
     ErrorPlaceholderImage:(UIImage *)errorPlaceholder
{
    self.cc_Placeholder = placeholder;
    self.cc_ErrorPlaceholder = errorPlaceholder;

    [self cc_loadTapEvent];

    if (self.cc_ImageURL && self.image && self.image.duration == 0 && self.cc_status == CCImageViewStatusLoaded && self.imageURL) {
        if ([[self.cc_ImageURL absoluteString] isEqualToString:[url absoluteString]]) //相同的图片URL 就不在设置了
            return;
    }

    self.cc_ImageURL = url;
    if (url) {
        [self setReloadCount:0];

        BOOL hasShowClickDownload = NO;
        if (![[self obtainNetWorkStates] isEqualToString:@"WIFI"]) {
            hasShowClickDownload = YES;
        }

        BOOL hasCache = NO;
        if (hasShowClickDownload)
            hasCache = [[SDImageCache sharedImageCache] diskImageExistsWithKey:[url absoluteString]];

        //需要显示点击下载图片的选项
        if (hasShowClickDownload && hasCache == NO) {
            [self cc_init_imageview];
            self.cc_status = CCImageViewStatusClickDownload;
            [self cc_showImage:placeholder];
        } else {
            [self cc_reloadImageURL];
        }
    } else {
        [self cc_hideProgressView];
        [self sd_cancelCurrentImageLoad];
        self.image = nil;
        self.backgroundColor = [UIColor colorWithRed:233 / 255.0 green:228 / 255.0 blue:223 / 255.0 alpha:1];
        self.cc_status = CCImageViewStatusNone;
    }
}

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param urlString   图片地址
 *  @param placeholder 默认图片
 */
- (void)cc_setImageWithURLStr:(NSString *)urlString
             placeholderImage:(UIImage *)placeholder
{
    [self cc_setImageWithURLStr:urlString
               placeholderImage:placeholder
          ErrorPlaceholderImage:CCResourceImage(@"cc_noimage")];
}

/**
 *  @author CC, 16-08-23
 *
 *  @brief 网络判断加载图片
 *
 *  @param urlString        图片地址
 *  @param placeholder      默认图片
 *  @param errorPlaceholder 错图图片
 */
- (void)cc_setImageWithURLStr:(NSString *)urlString
             placeholderImage:(UIImage *)placeholder
        ErrorPlaceholderImage:(UIImage *)errorPlaceholder
{
    NSURL *imageURL = [self cc_URLWithImageURL:urlString];
    [self cc_setImageWithURL:imageURL
            placeholderImage:placeholder
       ErrorPlaceholderImage:errorPlaceholder];
}

- (void)cc_reloadImageURL
{
    __weak UIImageView *wself = self;
    self.cc_status = CCImageViewStatusLoading;
    __block CCRingProgressView *pv = [self cc_progressView:YES];
    pv.progress = 0;
    pv.hidden = NO;
    [pv setNeedsDisplay];
    [self setNeedsDisplay];

    [self sd_setImageWithURL:self.cc_ImageURL placeholderImage:self.cc_Placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if(expectedSize <= 0)
            return;

        float pvalue = MAX(0, MIN(1, receivedSize / (float) expectedSize));
        dispatch_main_sync_safe(^{
            if(!wself.image){
                if(!pv)
                    pv = [wself cc_progressView:YES];

                pv.hidden = NO;
            }
            pv.progress = pvalue;
        });
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image){
            [wself cc_hideProgressView];
            wself.cc_status = CCImageViewStatusLoaded;
            if(image.duration == 0){
                if(wself.loadedViewContentMode > 0 && wself.contentMode != wself.loadedViewContentMode){
                    wself.contentMode = wself.loadedViewContentMode;
                    wself.image = image;
                    [wself setNeedsDisplay];
                }
                wself.backgroundColor = [UIColor clearColor];
            }
        }else{
            if (error){
                int reloadCount = [wself reloadCount];
                if(reloadCount < 2){
                    [wself setReloadCount:reloadCount+1];
                    [wself cc_reloadImageURL];
                    return ;
                }

                [wself cc_hideProgressView];
                wself.cc_status = CCImageViewStatusFail;
                [wself cc_showImage:self.cc_ErrorPlaceholder];
            }else{
                wself.cc_status = CCImageViewStatusNone;
                [wself cc_hideProgressView];
            }
        }
    }];
}

- (void)cc_init_imageview
{
    [self sd_cancelCurrentImageLoad];
    [self cc_progressView:NO].hidden = YES;

    self.image = nil;
    self.backgroundColor = [UIColor colorWithRed:233 / 255.0 green:228 / 255.0 blue:223 / 255.0 alpha:1];
}

- (void)cc_hideProgressView
{
    CCRingProgressView *pv = [self cc_progressView:NO];
    pv.hidden = YES;
    pv.progress = 0;
    [pv removeFromSuperview];
}

- (NSURL *)cc_URLWithImageURL:(id)imageURL
{
    if ([imageURL isKindOfClass:[NSString class]]) {
        if ([imageURL hasPrefix:@"http"] || [imageURL hasPrefix:@"ftp"]) {
            imageURL = [NSURL URLWithString:imageURL];
        } else {
            imageURL = [NSURL fileURLWithPath:imageURL];
        }
    }
    if ([imageURL isKindOfClass:[NSURL class]] == NO) {
        imageURL = nil;
    }
    return imageURL;
}

- (void)cc_showImage:(UIImage *)image
{
    if (self.bounds.size.width < image.size.width || self.bounds.size.height < image.size.height) {
        self.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.contentMode = UIViewContentModeCenter;
    }
    self.image = image;
    [self setNeedsDisplay];
}

- (NSString *)obtainNetWorkStates
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *state;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            NSInteger netType = [[child valueForKeyPath:@"dataNetworkType"] integerValue];
            switch (netType) {
                case 0:
                    state = @"无网络";
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5: {
                    state = @"WIFI";
                } break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}

@end

#pragma mark -
#pragma mark :. HighlightedWebCacheDeprecated

@implementation UIImageView (HighlightedWebCacheDeprecated)

- (void)setHighlightedImageWithURL:(NSURL *)url
{
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options
{
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)setHighlightedImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setHighlightedImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setHighlightedImageWithURL:url options:0 progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)cancelCurrentHighlightedImageLoad
{
    [self sd_cancelCurrentHighlightedImageLoad];
}

@end

#pragma mark -
#pragma mark :. WebCacheDeprecated

@implementation UIImageView (WebCacheDeprecated)

- (NSURL *)imageURL
{
    return [self sd_imageURL];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)cancelCurrentArrayLoad
{
    [self sd_cancelCurrentAnimationImagesLoad];
}

- (void)cancelCurrentImageLoad
{
    [self sd_cancelCurrentImageLoad];
}

- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs
{
    [self sd_setAnimationImagesWithURLs:arrayOfURLs];
}


@end
