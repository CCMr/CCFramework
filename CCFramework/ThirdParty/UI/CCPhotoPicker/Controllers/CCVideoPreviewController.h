//
//  CCVideoPreviewController.h
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
//  使用AVPlayer 播放选择的视频

#import <UIKit/UIKit.h>

@class CCAssetModel;
@interface CCVideoPreviewController : UIViewController

/** 是否可以选择视频 默认视频,照片不能同时选择(如果已经选择照片了,则不能选择视频) */
@property (nonatomic, assign) BOOL selectedVideoEnable;
/** 资源model */
@property (nonatomic, strong) CCAssetModel *asset;

/** 点击底部bottomBar 确认按钮后回调 */
@property (nonatomic, copy)   void(^didFinishPickingVideo)(UIImage *coverImage, CCAssetModel *asset);


@end
