//
//  UILabel+Additions.m
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

#import "UILabel+Additions.h"
#import "CCMessagePhotoImageView.h"
#import "SETextAttachment.h"
#import "SETextLayout.h"
#import "SELineLayout.h"
//#import "CCMessageBubbleHelper.h"
#include <objc/runtime.h>

@implementation UILabel (Additions)

#pragma mark -
#pragma mark :. Additions
/**
 *  @author CC, 15-09-25
 *
 *  @brief  设置CellLabel背景颜色
 *
 *  @param color 颜色值
 */
- (void)cellLabelSetColor:(UIColor *)color
{
    [self setBackgroundColor:color];
    [self performSelector:@selector(setBackgroundColor:)
               withObject:color
               afterDelay:0.01];
}

#pragma mark -
#pragma mark :. AutomaticWriting

NSTimeInterval const UILabelAWDefaultDuration = 0.4f;

unichar const UILabelAWDefaultCharacter = 124;

static inline void AutomaticWritingSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static char kAutomaticWritingOperationQueueKey;
static char kAutomaticWritingEdgeInsetsKey;


#pragma mark :. Public Methods

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AutomaticWritingSwizzleSelector([self class], @selector(textRectForBounds:limitedToNumberOfLines:), @selector(automaticWritingTextRectForBounds:limitedToNumberOfLines:));
        AutomaticWritingSwizzleSelector([self class], @selector(drawTextInRect:), @selector(drawAutomaticWritingTextInRect:));
    });
}

- (void)drawAutomaticWritingTextInRect:(CGRect)rect
{
    [self drawAutomaticWritingTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
    if (self.attachments.count) {
        [self drawTextAttachmentsInContext:UIGraphicsGetCurrentContext()];
    }
}

- (CGRect)automaticWritingTextRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [self automaticWritingTextRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    return textRect;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    objc_setAssociatedObject(self, &kAutomaticWritingEdgeInsetsKey, [NSValue valueWithUIEdgeInsets:edgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)edgeInsets
{
    NSValue *edgeInsetsValue = objc_getAssociatedObject(self, &kAutomaticWritingEdgeInsetsKey);
    
    if (edgeInsetsValue) {
        return edgeInsetsValue.UIEdgeInsetsValue;
    }
    
    edgeInsetsValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero];
    
    objc_setAssociatedObject(self, &kAutomaticWritingEdgeInsetsKey, edgeInsetsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return edgeInsetsValue.UIEdgeInsetsValue;
}

- (void)setAutomaticWritingOperationQueue:(NSOperationQueue *)automaticWritingOperationQueue
{
    objc_setAssociatedObject(self, &kAutomaticWritingOperationQueueKey, automaticWritingOperationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSOperationQueue *)automaticWritingOperationQueue
{
    NSOperationQueue *operationQueue = objc_getAssociatedObject(self, &kAutomaticWritingOperationQueueKey);
    
    if (operationQueue) {
        return operationQueue;
    }
    
    operationQueue = NSOperationQueue.new;
    operationQueue.name = @"Automatic Writing Operation Queue";
    operationQueue.maxConcurrentOperationCount = 1;
    
    objc_setAssociatedObject(self, &kAutomaticWritingOperationQueueKey, operationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return operationQueue;
}

- (void)setTextWithAutomaticWritingAnimation:(NSString *)text
{
    [self setText:text automaticWritingAnimationWithBlinkingMode:UILabelCCBlinkingModeNone];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithBlinkingMode:(UILabelCCBlinkingMode)blinkingMode
{
    [self setText:text automaticWritingAnimationWithDuration:UILabelAWDefaultDuration blinkingMode:blinkingMode];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration
{
    [self setText:text automaticWritingAnimationWithDuration:duration blinkingMode:UILabelCCBlinkingModeNone];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode
{
    [self setText:text automaticWritingAnimationWithDuration:duration blinkingMode:blinkingMode blinkingCharacter:UILabelAWDefaultCharacter];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter
{
    [self setText:text automaticWritingAnimationWithDuration:duration blinkingMode:blinkingMode blinkingCharacter:blinkingCharacter completion:nil];
}

- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelCCBlinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter completion:(void (^)(void))completion
{
    self.automaticWritingOperationQueue.suspended = YES;
    self.automaticWritingOperationQueue = nil;
    
    self.text = @"";
    
    NSMutableString *automaticWritingText = NSMutableString.new;
    
    if (text) {
        [automaticWritingText appendString:text];
    }
    
    [self.automaticWritingOperationQueue addOperationWithBlock:^{
        [self automaticWriting:automaticWritingText duration:duration mode:blinkingMode character:blinkingCharacter completion:completion];
    }];
}

#pragma mark :. Private Methods

- (void)automaticWriting:(NSMutableString *)text duration:(NSTimeInterval)duration mode:(UILabelCCBlinkingMode)mode character:(unichar)character completion:(void (^)(void))completion
{
    NSOperationQueue *currentQueue = NSOperationQueue.currentQueue;
    if ((text.length || mode >= UILabelCCBlinkingModeWhenFinish) && !currentQueue.isSuspended) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (mode != UILabelCCBlinkingModeNone)
            {
                if ([self isLastCharacter:character])
                {
                    [self deleteLastCharacter];
                }
                else if (mode != UILabelCCBlinkingModeWhenFinish || !text.length)
                {
                    [text insertString:[self stringWithCharacter:character] atIndex:0];
                }
            }
            
            if (text.length)
            {
                [self appendCharacter:[text characterAtIndex:0]];
                [text deleteCharactersInRange:NSMakeRange(0, 1)];
                if ((![self isLastCharacter:character] && mode == UILabelCCBlinkingModeWhenFinishShowing) || (!text.length && mode == UILabelCCBlinkingModeWhenFinishShowing))
                {
                    [self appendCharacter:character];
                }
            }
            
            if (!currentQueue.isSuspended)
            {
                [currentQueue addOperationWithBlock:^{
                    [self automaticWriting:text duration:duration mode:mode character:character completion:completion];
                }];
            }
            else if (completion)
            {
                completion();
            }
        });
    } else if (completion) {
        completion();
    }
}

- (NSString *)stringWithCharacter:(unichar)character
{
    return [self stringWithCharacters:@[ @(character) ]];
}

- (NSString *)stringWithCharacters:(NSArray *)characters
{
    NSMutableString *string = NSMutableString.new;
    
    for (NSNumber *character in characters) {
        [string appendFormat:@"%C", character.unsignedShortValue];
    }
    
    return string.copy;
}

- (void)appendCharacter:(unichar)character
{
    [self appendCharacters:@[ @(character) ]];
}

- (void)appendCharacters:(NSArray *)characters
{
    self.text = [self.text stringByAppendingString:[self stringWithCharacters:characters]];
}

- (BOOL)isLastCharacters:(NSArray *)characters
{
    if (self.text.length >= characters.count) {
        return [self.text hasSuffix:[self stringWithCharacters:characters]];
    }
    return NO;
}

- (BOOL)isLastCharacter:(unichar)character
{
    return [self isLastCharacters:@[ @(character) ]];
}

- (BOOL)deleteLastCharacters:(NSUInteger)characters
{
    if (self.text.length >= characters) {
        self.text = [self.text substringToIndex:self.text.length - characters];
        return YES;
    }
    return NO;
}

- (BOOL)deleteLastCharacter
{
    return [self deleteLastCharacters:1];
}

#pragma mark -
#pragma mark :. CCAdjustableLabel

// General method. If minSize is set to CGSizeZero then
// it is ignored.
// =====================================================
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                     minimumSize:(CGSize)minSize
                 minimumFontSize:(CGFloat)minFontSize
{
    //// 1) Calculate new label size
    //// ---------------------------
    // First, reset some basic parameters
    [self setNumberOfLines:0];
    //    [self setLineBreakMode:UILineBreakModeWordWrap];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    
    // If maxSize is set to CGSizeZero, then assume the max width
    // is the size of the device screen minus the default
    // recommended edge distances (2 * 20)
    if (maxSize.height == CGSizeZero.height) {
        maxSize.width = [[UIScreen mainScreen] bounds].size.width - 40.0;
        maxSize.height = MAXFLOAT; // infinite height
    }
    
    // Now, calculate the size of the label constrained to maxSize
    CGSize tempSize = [[self text] sizeWithFont:[self font]
                              constrainedToSize:maxSize
                                  lineBreakMode:[self lineBreakMode]];
    
    // If minSize is specified (not CGSizeZero) then
    // check if the new calculated size is smaller than
    // the minimum size
    if (minSize.height != CGSizeZero.height) {
        if (tempSize.width <= minSize.width) tempSize.width = minSize.width;
        if (tempSize.height <= minSize.height) tempSize.height = minSize.height;
    }
    
    // Create rect
    CGRect newFrameSize = CGRectMake([self frame].origin.x, [self frame].origin.y, tempSize.width, tempSize.height);
    
    //// 2) Change the font size if necessary
    //// ------------------------------------
    UIFont *labelFont = [self font];	  // temporary label object
    CGFloat fSize = [labelFont pointSize];    // temporary font size value
    CGSize calculatedSizeWithCurrentFontSize; // temporary frame size
    
    // Calculate label size as if there was no constrain
    CGSize unconstrainedSize = CGSizeMake(tempSize.width, MAXFLOAT);
    
    // Keep reducing the font size until the calculated frame size
    // is smaller than the maxSize parameter
    do {
        // Create a temporary font object
        labelFont = [UIFont fontWithName:[labelFont fontName]
                                    size:fSize];
        // Calculate the frame size
        calculatedSizeWithCurrentFontSize =
        [[self text] sizeWithFont:labelFont
                constrainedToSize:unconstrainedSize
                    lineBreakMode:NSLineBreakByWordWrapping];
        // Reduce the temporary font size value
        fSize--;
    } while (calculatedSizeWithCurrentFontSize.height > maxSize.height);
    
    // Reset the font size to the last calculated value
    [self setFont:labelFont];
    
    // Reset the frame size
    [self setFrame:newFrameSize];
}

// Adjust label using only the maximum size and the
// font size as constraints
// =====================================================
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                 minimumFontSize:(CGFloat)minFontSize
{
    [self adjustLabelToMaximumSize:maxSize
                       minimumSize:CGSizeZero
                   minimumFontSize:minFontSize];
}

// Adjust the size of the label using only the font
// size as a constraint (the maximum size will be
// calculated automatically based on the screen size)
// =====================================================
- (void)adjustLabelSizeWithMinimumFontSize:(CGFloat)minFontSize
{
    [self adjustLabelToMaximumSize:CGSizeZero
                       minimumSize:CGSizeZero
                   minimumFontSize:minFontSize];
}

// Adjust label without any constraints (the maximum
// size will be calculated automatically based on the
// screen size)
// =====================================================
- (void)adjustLabel
{
    [self adjustLabelToMaximumSize:CGSizeZero
                       minimumSize:CGSizeZero
                   minimumFontSize:[self minimumScaleFactor]];
}

#pragma mark -
#pragma mark :. SuggestSize

- (CGSize)suggestedSizeForWidth:(CGFloat)width
{
    if (self.attributedText)
        return [self suggestSizeForAttributedString:self.attributedText width:width];
    
    return [self suggestSizeForString:self.text width:width];
}

- (CGSize)suggestSizeForAttributedString:(NSAttributedString *)string width:(CGFloat)width
{
    if (!string) {
        return CGSizeZero;
    }
    return [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
}

- (CGSize)suggestSizeForString:(NSString *)string width:(CGFloat)width
{
    if (!string) {
        return CGSizeZero;
    }
    return [self suggestSizeForAttributedString:[[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : self.font}] width:width];
}

#pragma mark -
#pragma mark :. AutoSize

- (UILabel *)resizeLabelHorizontal
{
    return [self resizeLabelHorizontal:0];
}

- (UILabel *)resizeLabelVertical
{
    return [self resizeLabelVertical:0];
}

- (UILabel *)resizeLabelVertical:(CGFloat)minimumHeigh
{
    CGRect newFrame = self.frame;
    CGSize constrainedSize = CGSizeMake(newFrame.size.width, CGFLOAT_MAX);
    NSString *text = self.text;
    UIFont *font = self.font;
    CGSize size = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy};
        
        size = [text boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    } else {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED <= 60000)
        size = [text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    newFrame.size.height = ceilf(size.height);
    if (minimumHeigh > 0) {
        newFrame.size.height = (newFrame.size.height < minimumHeigh ? minimumHeigh : newFrame.size.height);
    }
    self.frame = newFrame;
    return self;
}

- (UILabel *)resizeLabelHorizontal:(CGFloat)minimumWidth
{
    CGRect newFrame = self.frame;
    CGSize constrainedSize = CGSizeMake(CGFLOAT_MAX, newFrame.size.height);
    NSString *text = self.text;
    UIFont *font = self.font;
    CGSize size = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy};
        
        size = [text boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    } else {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED <= 60000)
        size = [text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    newFrame.size.width = ceilf(size.width);
    if (minimumWidth > 0) {
        newFrame.size.width = (newFrame.size.width < minimumWidth ? minimumWidth : newFrame.size.width);
    }
    self.frame = newFrame;
    return self;
}

#pragma mark -
#pragma mark :. 图文混排
static NSString *const OBJECT_REPLACEMENT_CHARACTER = @"\uFFFC";

- (void)setCoreTeletext:(NSString *)coreTeletext
{
    objc_setAssociatedObject(self, @selector(coreTeletext), coreTeletext, OBJC_ASSOCIATION_COPY);
}

- (NSString *)coreTeletext
{
    return objc_getAssociatedObject(self, @selector(coreTeletext));
}

- (void)setCoreTeletextAttributed:(NSAttributedString *)coreTeletextAttributed
{
    objc_setAssociatedObject(self, @selector(coreTeletextAttributed), coreTeletextAttributed, OBJC_ASSOCIATION_COPY);
}

- (NSAttributedString *)coreTeletextAttributed
{
    return objc_getAssociatedObject(self, @selector(coreTeletextAttributed));
}

/**
 *  textLayout
 */
- (void)setTextLayout:(SETextLayout *)textLayout
{
    objc_setAssociatedObject(self, @selector(textLayout), textLayout, OBJC_ASSOCIATION_RETAIN);
}

- (SETextLayout *)textLayout
{
    return objc_getAssociatedObject(self, @selector(textLayout));
}

/**
 *  attachments
 */
- (void)setAttachments:(NSMutableSet *)attachments
{
    objc_setAssociatedObject(self, @selector(attachments), attachments, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableSet *)attachments
{
    return objc_getAssociatedObject(self, @selector(attachments));
}


/**
 *  @author CC, 16-05-27
 *  
 *  @brief  图文混排
 *
 *  @param text         文本内容
 *  @param replaceAry   替换标签
 *  @param teletextPath 图片地址
 *  @param teletextSize 图片大小 
 *                      命名规则 @[@{ @"width" : 20, @"height" : 20}]
 */
- (void)coreTeletext:(NSString *)text
          ReplaceAry:(NSArray<NSString *> *)replaceAry
        TeletextPath:(NSArray<NSString *> *)teletextPath
        teletextSize:(NSArray<NSDictionary *> *)teletextSize
{
    if (!self.textLayout)
        self.textLayout = [[SETextLayout alloc] init];
    
    self.textLayout.bounds = self.bounds;
    
    NSMutableSet *attachments = [NSMutableSet set];
    
    self.coreTeletext = text;
    
    for (NSString *replaceStr in replaceAry)
        self.coreTeletext = [self.coreTeletext stringByReplacingOccurrencesOfString:replaceStr withString:OBJECT_REPLACEMENT_CHARACTER];
    
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:OBJECT_REPLACEMENT_CHARACTER options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:self.coreTeletext options:0 range:NSMakeRange(0, self.coreTeletext.length)];
    
    for (int i = 0; i < resultArray.count; i++) {
        NSDictionary *sizeDic = [teletextSize objectAtIndex:i];
        NSTextCheckingResult *match = [resultArray objectAtIndex:i];
        
        NSString *path = @"";
        if (teletextPath.count && i < teletextPath.count)
            path = [teletextPath objectAtIndex:i];
        
        CGSize size = CGSizeMake([[sizeDic objectForKey:@"width"] integerValue], [[sizeDic objectForKey:@"height"] integerValue]);
        UIImage *Images = [UIImage imageWithContentsOfFile:path];
        if (Images)
            size = CGSizeMake(Images.size.width < size.width ? Images.size.width : size.width, Images.size.height < size.height ? Images.size.height : size.height);
        
        CCMessagePhotoImageView *messagePhotoImageView = [[CCMessagePhotoImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        messagePhotoImageView.imageFilePath = path;
        
        SETextAttachment *attachment = [[SETextAttachment alloc] initWithObject:messagePhotoImageView size:size range:[match range]];
        [attachments addObject:attachment];
    }
    
    self.attachments = attachments;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.coreTeletext];
    [attributedString addAttributes:@{ NSForegroundColorAttributeName : self.textColor } range:NSMakeRange(0, self.coreTeletext.length)];
    
    self.coreTeletextAttributed = attributedString; //[[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:self.coreTeletext];
}

- (void)updateLayout
{
    [self setTextAttachmentAttributes];
    
    self.textLayout.bounds = self.bounds;
    self.textLayout.attributedString = self.coreTeletextAttributed;
    self.textLayout.lineBreakMode = (CTLineBreakMode)self.lineBreakMode;
    
    [self.textLayout update];
}

- (void)setTextAttachmentAttributes
{
    NSString *replacementString = OBJECT_REPLACEMENT_CHARACTER;
    
    NSArray *attachments = [self.attachments.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SETextAttachment *attachment1 = obj1;
        SETextAttachment *attachment2 = obj2;
        NSRange range1 = attachment1.range;
        NSRange range2 = attachment2.range;
        NSUInteger maxRange1 = NSMaxRange(range1);
        NSUInteger maxRange2 = NSMaxRange(range2);
        if (maxRange1 < maxRange2) {
            return NSOrderedDescending;
        } else if (maxRange1 > maxRange2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    for (SETextAttachment *attachment in attachments) {
        NSMutableAttributedString *editingAttributedText = self.coreTeletextAttributed.mutableCopy;
        if (!attachment.replacedString) {
            if (attachment.range.length > 0) {
                NSAttributedString *originalAttributedString = [editingAttributedText attributedSubstringFromRange:attachment.range];
                attachment.originalAttributedString = originalAttributedString;
                
                [editingAttributedText replaceCharactersInRange:attachment.range withString:replacementString];
                attachment.replacedString = replacementString;
            } else {
                [editingAttributedText insertAttributedString:[[NSAttributedString alloc] initWithString:replacementString] atIndex:attachment.range.location];
                attachment.replacedString = replacementString;
            }
            
            CTRunDelegateCallbacks callbacks = attachment.callbacks;
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)attachment);
            [editingAttributedText addAttributes:@{(id)kCTRunDelegateAttributeName : (__bridge id)runDelegate } range:attachment.range];
            CFRelease(runDelegate);
            
            self.coreTeletextAttributed = editingAttributedText;
        }
    }
}

- (void)drawTextAttachmentsInContext:(CGContextRef)context
{
    [self updateLayout];
    
    NSMutableSet *attachmentsToLeave = [[NSMutableSet alloc] init];
    
    [self.coreTeletextAttributed enumerateAttribute:(id)kCTRunDelegateAttributeName inRange:NSMakeRange(0, self.coreTeletext.length) options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (!value) {
            return;
        }
        
        CTRunDelegateRef runDelegate = (__bridge CTRunDelegateRef)value;
        SETextAttachment *attachment = (__bridge SETextAttachment *)CTRunDelegateGetRefCon(runDelegate);
        if (!attachment) {
            return;
        }
        
        [attachmentsToLeave addObject:attachment];
        
        for (SELineLayout *lineLayout in self.textLayout.lineLayouts) {
            CGRect lineRect = lineLayout.rect;
            CGRect rect = [lineLayout rectOfStringWithRange:range];
            if (!CGRectIsEmpty(rect) && CGRectGetMaxX(rect) <= (CGRectGetMaxX(lineRect) - lineLayout.truncationTokenWidth)) {
                id object = attachment.object;
                CGSize size = attachment.size;
                rect.origin.x += (CGRectGetWidth(rect) - size.width) / 2;
                rect.origin.y += CGRectGetHeight(rect) - size.height;
                rect.size = size;
                rect = CGRectIntegral(rect);
                if ([object isKindOfClass:[NSView class]]) {
                    UIView *view = object;
                    view.frame = rect;
                    if (!view.superview) {
                        [self addSubview:view];
                    }
                } else if ([object isKindOfClass:[NSImage class]]) {
                    NSImage *image = object;
#if TARGET_OS_IPHONE
                    [image drawInRect:rect];
#else
                    [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
#endif
                } else if ([object isKindOfClass:NSClassFromString(@"NSBlock")]) {
                    //                    SETextAttachmentDrawingBlock draw = attachment.object;
                    //                    CGContextSaveGState(context);
                    //                    draw(rect, context);
                    //                    CGContextRestoreGState(context);
                }
            }
        }
    }];
    
    self.attachments = attachmentsToLeave;
    [self.textLayout drawInContext:context];
}

@end
