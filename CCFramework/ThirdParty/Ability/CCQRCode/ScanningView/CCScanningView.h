//
//  ScanningView.h
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

/**
 *  @author C C, 15-08-18
 *
 *  @brief  二维码扫描
 *
 *  @since <#1.0#>
 */
typedef NS_ENUM(NSInteger, CCScanningStyle) {
    /** 扫描二维码 **/
    CCScanningStyleQRCode = 0,
    /** 扫描杂志封面 **/
    CCScanningStyleBook,
    /** 扫描街景 **/
    CCScanningStyleStreet,
    /** 扫描翻译 **/
    CCScanningStyleWord,
};

@interface CCScanningView : UIView

@property (nonatomic, assign, readonly) CCScanningStyle scanningStyle;

- (void)transformScanningTypeWithStyle:(CCScanningStyle)style;

@end
