//
//  UIFont+Additions.m
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
//

#import "UIFont+Additions.h"
#import <CoreText/CoreText.h>

@implementation UIFont (Additions)

#pragma mark -
#pragma mark :. DynamicFontControl

+ (UIFont *)preferredFontForTextStyle:(NSString *)style
                         withFontName:(NSString *)fontName
{
    return [UIFont preferredFontForTextStyle:style withFontName:fontName scale:1.0f];
}

+ (UIFont *)preferredFontForTextStyle:(NSString *)style
                         withFontName:(NSString *)fontName
                                scale:(CGFloat)scale
{
    UIFont *font = nil;
    if ([[UIFont class] resolveClassMethod:@selector(preferredFontForTextStyle:)]) {
        font = [UIFont preferredFontForTextStyle:fontName];
    } else {
        font = [UIFont fontWithName:fontName size:14 * scale];
    }
    
    return [font adjustFontForTextStyle:style];
}

- (UIFont *)adjustFontForTextStyle:(NSString *)style
{
    return [self adjustFontForTextStyle:style scale:1.0f];
}

- (UIFont *)adjustFontForTextStyle:(NSString *)style
                             scale:(CGFloat)scale
{
    UIFontDescriptor *fontDescriptor = nil;
    if ([[UIFont class] resolveClassMethod:@selector(preferredFontForTextStyle:)]) {
        fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];
    } else {
        fontDescriptor = self.fontDescriptor;
    }
    
    float dynamicSize = [fontDescriptor pointSize] * scale + 3;
    return [UIFont fontWithName:self.fontName size:dynamicSize];
}

#pragma mark -
#pragma mark :. CustomLoader

// Feature and deployment target check
#if !__has_feature(objc_arc)
#error This file must be compiled with ARC.
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40100
#error This file must be compiled with Deployment Target greater or equal to 4.1
#endif

// Activate Xcode only logging
#ifdef DEBUG
#define UIFontWDCustomLoaderDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define UIFontWDCustomLoaderDLog(...)
#endif

static CGFloat const kSizePlaceholder = 1.0f;
static NSMutableDictionary *appRegisteredCustomFonts = nil;

/**
 Check features for full font collections support
 
 @return YES if all features are supported
 */
+ (BOOL)deviceHasFullSupportForFontCollections
{
    
    return (&CTFontManagerCreateFontDescriptorsFromURL != NULL); // 10.6 or 7.0
}

/**
 Inner method for font(s) registration from a file
 
 @param fontURL A font URL
 
 @return Registration result
 */
+ (BOOL)registerFromURL:(NSURL *)fontURL
{
    
    CFErrorRef error;
    BOOL registrationResult = YES;
    
    registrationResult = CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error);
    
    if (!registrationResult) {
        UIFontWDCustomLoaderDLog(@"Error with font registration: %@", error);
        CFRelease(error);
        return NO;
    }
    
    return YES;
}

/**
 Inner method for font registration from a graphic font.
 
 @param fontRef A CGFontRef
 
 @return Registration result
 */
+ (BOOL)registerFromCGFont:(CGFontRef)fontRef
{
    
    CFErrorRef error;
    BOOL registrationResult = YES;
    
    registrationResult = CTFontManagerRegisterGraphicsFont(fontRef, &error);
    
    if (!registrationResult) {
        UIFontWDCustomLoaderDLog(@"Error with font registration: %@", error);
        CFRelease(error);
        return NO;
    }
    
    return YES;
}

+ (NSArray *)registerFontFromURL:(NSURL *)fontURL
{
    // Dictionary creation
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appRegisteredCustomFonts = [NSMutableDictionary new];
    });
    
    // Result
    NSArray *fontPSNames = nil;
    
    
    // Critical section
    @synchronized(appRegisteredCustomFonts)
    {
        
        // Check if this library knows this url
        fontPSNames = [[appRegisteredCustomFonts objectForKey:fontURL] copy];
        
        if (fontPSNames == nil) {
            
            // Check features
            if ([UIFont deviceHasFullSupportForFontCollections]) {
                
                // Retrieve font descriptors from ttf, otf, ttc and otc files
                NSArray *fontDescriptors = (__bridge_transfer NSArray *)(CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fontURL));
                
                // Check errors
                if (fontDescriptors) {
                    
                    // Check how many fonts are already registered (or have the
                    // same name of another font)
                    NSMutableArray *verifiedFontPSNames = [NSMutableArray new];
                    
                    for (NSDictionary *fontDescriptor in fontDescriptors) {
                        NSString *fontPSName = [fontDescriptor objectForKey:@"NSFontNameAttribute"];
                        
                        if (fontPSName) {
                            if ([UIFont fontWithName:fontPSName size:kSizePlaceholder]) {
                                UIFontWDCustomLoaderDLog(@"Warning with font registration: Font '%@' already registered", fontPSName);
                            }
                            [verifiedFontPSNames addObject:fontPSName];
                        }
                    }
                    
                    fontPSNames = [NSArray arrayWithArray:verifiedFontPSNames];
                    
                    // At least one
                    if ([fontPSNames count] > 0) {
                        
                        // If registration went ok
                        if ([UIFont registerFromURL:fontURL]) {
                            // Add url to this library
                            [appRegisteredCustomFonts setObject:fontPSNames
                                                         forKey:fontURL];
                            
                        } else {
                            fontPSNames = nil;
                        }
                        
                    } else { // [fontPSNames count] <= 0
                        UIFontWDCustomLoaderDLog(@"Warning with font registration: All fonts in '%@' are already registered", fontURL);
                    }
                    
                } else { // CTFontManagerCreateFontDescriptorsFromURL fail
                    UIFontWDCustomLoaderDLog(@"Error with font registration: File '%@' is not a Font", fontURL);
                    fontPSNames = nil;
                }
            } else { // [UIFont deviceHasFullSupportForFontCollections] fail
                
                // Read data
                NSError *error;
                NSData *fontData = [NSData dataWithContentsOfURL:fontURL
                                                         options:NSDataReadingUncached
                                                           error:&error];
                
                // Check data creation
                if (fontData) {
                    
                    // Load font
                    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
                    CGFontRef loadedFont = CGFontCreateWithDataProvider(fontDataProvider);
                    
                    // Check font
                    if (loadedFont != NULL) {
                        
                        // Prior to iOS7 is not easy to retrieve names from font collections
                        // But is possible to register collections
                        NSSet *singleFontValidExtensions = [NSSet setWithArray:@[ @"ttf", @"otf" ]];
                        
                        if ([singleFontValidExtensions containsObject:[fontURL pathExtension]]) {
                            // Read name
                            fontPSNames = @[ (__bridge_transfer NSString *)(CGFontCopyPostScriptName(loadedFont)) ];
                            
                            // Check if registration is required
                            if ([UIFont fontWithName:fontPSNames[0] size:kSizePlaceholder] == nil) {
                                
                                // If registration went ok
                                if ([UIFont registerFromCGFont:loadedFont]) {
                                    // Add url to this library
                                    [appRegisteredCustomFonts setObject:fontPSNames
                                                                 forKey:fontURL];
                                    
                                } else {
                                    fontPSNames = nil;
                                }
                            } else {
                                UIFontWDCustomLoaderDLog(@"Warning with font registration: All fonts in '%@' are already registered", fontURL);
                            }
                            
                        } else {
                            // Is a collection
                            
                            //TODO find a way to read names
                            fontPSNames = @[];
                            
                            // Revert to url registration which allow collections
                            // If registration went ok
                            if ([UIFont registerFromURL:fontURL]) {
                                // Add url to this library
                                [appRegisteredCustomFonts setObject:fontPSNames
                                                             forKey:fontURL];
                                
                            } else {
                                fontPSNames = nil;
                            }
                        }
                        
                    } else { // CGFontCreateWithDataProvider fail
                        UIFontWDCustomLoaderDLog(@"Error with font registration: File '%@' is not a Font", fontURL);
                        fontPSNames = nil;
                    }
                    
                    // Release
                    CGFontRelease(loadedFont);
                    CGDataProviderRelease(fontDataProvider);
                } else {
                    UIFontWDCustomLoaderDLog(@"Error with font registration: URL '%@' cannot be read with error: %@", fontURL, error);
                    fontPSNames = nil;
                }
            }
        }
    }
    
    return fontPSNames;
}

+ (UIFont *)customFontWithURL:(NSURL *)fontURL size:(CGFloat)size
{
    
    // Only single font with this method
    NSSet *singleFontValidExtensions = [NSSet setWithArray:@[ @"ttf", @"otf" ]];
    
    if (![singleFontValidExtensions containsObject:[fontURL pathExtension]]) {
        UIFontWDCustomLoaderDLog(@"Only ttf or otf files are supported by this method");
        return nil;
    }
    
    NSArray *fontPSNames = [UIFont registerFontFromURL:fontURL];
    
    if (fontPSNames == nil) {
        UIFontWDCustomLoaderDLog(@"Invalid Font URL: %@", fontURL);
        return nil;
    }
    if ([fontPSNames count] != 1) {
        UIFontWDCustomLoaderDLog(@"Font collections not supported by this method");
        return nil;
    }
    return [UIFont fontWithName:fontPSNames[0] size:size];
}

+ (UIFont *)customFontOfSize:(CGFloat)size withName:(NSString *)name withExtension:(NSString *)extension
{
    // Get url for font resource
    NSURL *fontURL = [[[NSBundle mainBundle] URLForResource:name withExtension:extension] absoluteURL];
    
    return [UIFont customFontWithURL:fontURL size:size];
}

#pragma mark -
#pragma mark :. TTF

+ (UIFont *)fontWithTTFAtURL:(NSURL *)URL size:(CGFloat)size
{
    BOOL isLocalFile = [URL isFileURL];
    NSAssert(isLocalFile, @"TTF files may only be loaded from local file paths. Remote files must first be cached locally, this category does not handle such cases natively.\n\nIf, however, the provided URL is indeed a reference to a local file.\n\n1. Ensure it was created via a method such as [NSURL fileURLWithPath:] and NOT [NSURL URLWithString:].\n\n2. Ensure the URL returns YES to isFileURL.");
    if (!isLocalFile) {
        return [UIFont systemFontOfSize:size];
    }
    return [UIFont fontWithTTFAtPath:URL.path size:size];
}

+ (UIFont *)fontWithTTFAtPath:(NSString *)path size:(CGFloat)size
{
    BOOL foundFile = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSAssert(foundFile, @"The font at: \"%@\" was not found.", path);
    if (!foundFile) {
        return [UIFont systemFontOfSize:size];
    }
    
    CFURLRef fontURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)path, kCFURLPOSIXPathStyle, false);
    ;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithURL(fontURL);
    CFRelease(fontURL);
    CGFontRef graphicsFont = CGFontCreateWithDataProvider(dataProvider);
    CFRelease(dataProvider);
    CTFontRef smallFont = CTFontCreateWithGraphicsFont(graphicsFont, size, NULL, NULL);
    CFRelease(graphicsFont);
    
    UIFont *returnFont = (__bridge UIFont *)smallFont;
    CFRelease(smallFont);
    
    return returnFont;
}

@end
