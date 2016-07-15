//
//  CCTextAttachment.m
//  CCFramework
//
//  Created by CC on 16/7/14.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTextAttachment.h"

@implementation CCTextAttachment

- (instancetype)initWithLink:(CCLink *)link
{
    if (self = [super init]) {
        self.link = link;
    }
    return self;
}

+ (instancetype)initAttachmentWihtLink:(CCLink *)link
{
    return [[CCTextAttachment alloc] initWithLink:link];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    if (self.link) {
        UIImage *image = self.link.linkImage;
        imageBounds.size = self.link.linkSize;

        CGRect iRect = self.imageRect;
        iRect.origin.x = imageBounds.origin.x;
        self.imageRect = iRect;


        UIGraphicsBeginImageContextWithOptions(self.link.linkSize, NO, 0.0);
        CGRect imageRect = CGRectMake(0.0, 0.0, self.link.linkSize.width, self.link.linkSize.height);
        [image drawInRect:imageRect];

        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return image;
    } else
        return [super imageForBounds:imageBounds textContainer:textContainer characterIndex:charIndex];
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    if (self.link) {

        // Retrieve the font for the glyph position. Used to offset the image bounds otherwise it
        // will be drawn on the baseline, which is not what we want.
        UIFont *font = [textContainer.layoutManager.textStorage attribute:NSFontAttributeName
                                                                  atIndex:charIndex
                                                           effectiveRange:nil];
        CGFloat baseLineHeight = (font ? font.lineHeight : lineFrag.size.height);

        CGFloat y = font.descender;
        y -= (self.link.linkSize.height - baseLineHeight) / 2;
        lineFrag.size = self.link.linkSize;
        self.imageRect = lineFrag;

        return CGRectMake(0, y, self.link.linkSize.width, self.link.linkSize.height);
    }

    // No drawing block so fallback on the original implementation
    return [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
}


@end
