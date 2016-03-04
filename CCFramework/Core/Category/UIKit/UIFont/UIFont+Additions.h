//
//  UIFont+Additions.h
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

#import <UIKit/UIKit.h>

@interface UIFont (Additions)

#pragma mark -
#pragma mark :. DynamicFontControl
+ (UIFont *)preferredFontForTextStyle:(NSString *)style
                         withFontName:(NSString *)fontName
                                scale:(CGFloat)scale;

+ (UIFont *)preferredFontForTextStyle:(NSString *)style
                         withFontName:(NSString *)fontName;

- (UIFont *)adjustFontForTextStyle:(NSString *)style;

- (UIFont *)adjustFontForTextStyle:(NSString *)style
                             scale:(CGFloat)scale;

#pragma mark -
#pragma mark :. CustomLoader

/**
 Get `UIFont` object for the selected font file.
 
 This method calls `+customFontWithURL:size`.
 
 @deprecated
 @see +customFontWithURL:size: method
 @param size Font size
 @param name Font filename without extension
 @param extension Font filename extension (@"ttf" and @"otf" are supported)
 @return `UIFont` object or `nil` on errors
 */
+ (UIFont *)customFontOfSize:(CGFloat)size
                    withName:(NSString *)name
               withExtension:(NSString *)extension;

/**
 Get `UIFont` object for the selected font file (*.ttf or *.otf files).
 
 The first call of this method will register the font using 
 `+registerFontFromURL:` method.
 
 @see +registerFontFromURL: method
 @param fontURL Font file absolute url
 @param size Font size
 @return `UIFont` object or `nil` on errors
 */
+ (UIFont *)customFontWithURL:(NSURL *)fontURL
                         size:(CGFloat)size;

/// @name Explicit registration

/**
 Allow custom fonts registration.
 
 With this method you can load all supported font file: ttf, otf, ttc and otc.
 Font that are already registered, with this library or by system, will not be 
 registered and you will see a warning log.
 
 @param fontURL Font file absolute url
 @return An array of postscript name which represent the file's font(s) or `nil`
 on errors. (With iOS < 7 as target you will see an empty array for collections)
 */
+ (NSArray *)registerFontFromURL:(NSURL *)fontURL;

#pragma mark -
#pragma mark :. TTF

/**
 *  @brief  Obtain a UIFont from a TTF file. If the path to the font is not valid, an exception will be raised,
 *	assuming NS_BLOCK_ASSERTIONS has not been defined. If assertions are disabled, systemFontOfSize is returned.
 *
 *  @param path The path to the TTF file.
 *  @param size The size of the font.
 *
 *  @return A UIFont reference derived from the TrueType Font at the given path with the requested size.
 */

+ (UIFont *)fontWithTTFAtPath:(NSString *)path
                         size:(CGFloat)size;

/**
 *  @brief  Convenience method that calls fontWithTTFAtPath:size: after creating a path from the provided URL.
 *
 *  @param URL  URL to the file (local only).
 *  @param size The size of the font.
 *
 *  @return A UIFont reference derived from the TrueType Font at the given path with the requested size.
 */

+ (UIFont *)fontWithTTFAtURL:(NSURL *)URL
                        size:(CGFloat)size;

@end
