//
//  CCFramework.h>
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

#import <CCFramework/AccelerationAnimation.h>
#import <CCFramework/BaseAppDelegate.h>
#import <CCFramework/BaseEntity.h>
#import <CCFramework/BaseNavigationController.h>
#import <CCFramework/BaseSearchTableViewController.h>
#import <CCFramework/BaseTabBarController.h>
#import <CCFramework/BaseTableViewCell.h>
#import <CCFramework/BaseTableViewController.h>
#import <CCFramework/BaseTableViewHeaderFooterView.h>
#import <CCFramework/BaseViewController.h>
#import <CCFramework/BaseViewModel.h>
#import <CCFramework/BUILabel.h>
#import <CCFramework/CALayer+Transition.h>
#import <CCFramework/CalendarCollectionViewCell.h>
#import <CCFramework/CalendarDay.h>
#import <CCFramework/CalendarFlowLayout.h>
#import <CCFramework/CalendarHeaderView.h>
#import <CCFramework/CalendarLogic.h>
#import <CCFramework/CalendarViewController.h>
#import <CCFramework/CCActionSheet.h>
#import <CCFramework/CCActionSheetViewController.h>
#import <CCFramework/CCAnimatedImage.h>
#import <CCFramework/CCAnimatedImageView.h>
#import <CCFramework/CCAnnotation.h>
#import <CCFramework/CCAudioPlayerHelper.h>
#import <CCFramework/CCAutoTextView.h>
#import <CCFramework/CCBase64.h>
#import <CCFramework/CCBackgroundView.h>
#import <CCFramework/CCBadgeView.h>
#import <CCFramework/CCBubblePhotoImageView.h>
#import <CCFramework/CCCacheManager.h>
#import <CCFramework/CCCameraViewController.h>
#import <CCFramework/CCCaptureHelper.h>
#import <CCFramework/CCConfigurationHelper.h>
#import <CCFramework/CCCycleScroll.h>
#import <CCFramework/CCDatePicker.h>
#import <CCFramework/CCDisplayLocationViewController.h>
#import <CCFramework/CCDisplayMediaViewController.h>
#import <CCFramework/CCDropzone.h>
#import <CCFramework/CCDropzoneViewController.h>
#import <CCFramework/CCEmotion.h>
#import <CCFramework/CCEmotionCollectionViewCell.h>
#import <CCFramework/CCEmotionCollectionViewFlowLayout.h>
#import <CCFramework/CCEmotionManager.h>
#import <CCFramework/CCEmotionManagerView.h>
#import <CCFramework/CCEmotionSectionBar.h>
#import <CCFramework/CCFileAttribute.h>
#import <CCFramework/CCFoundationCommon.h>
#import <CCFramework/CCFramework.h>
#import <CCFramework/CCHTTPManager.h>
#import <CCFramework/CCHTTPRequest.h>
#import <CCFramework/CCIntroductionViewController.h>
#import <CCFramework/CCLabel.h>
#import <CCFramework/CCLanguage.h>
#import <CCFramework/CCLineChartView.h>
#import <CCFramework/CCLoadLogoView.h>
#import <CCFramework/CCLocationHelper.h>
#import <CCFramework/CCLocationManager.h>
#import <CCFramework/CCMessage.h>
#import <CCFramework/CCMessageAvatarFactory.h>
#import <CCFramework/CCMessageBubbleFactory.h>
#import <CCFramework/CCMessageBubbleHelper.h>
#import <CCFramework/CCMessageBubbleView.h>
#import <CCFramework/CCMessageInputView.h>
#import <CCFramework/CCMessageModel.h>
#import <CCFramework/CCMessageTableView.h>
#import <CCFramework/CCMessageTableViewCell.h>
#import <CCFramework/CCMessageTableViewController.h>
#import <CCFramework/CCMessageTextView.h>
#import <CCFramework/CCMessageVideoConverPhotoFactory.h>
#import <CCFramework/CCMessageVoiceFactory.h>
#import <CCFramework/CCNSManagedObject.h>
#import <CCFramework/CCNumericKeypadView.h>
#import <CCFramework/CCPagesContainer.h>
#import <CCFramework/CCPhoto.h>
#import <CCFramework/CCPhotoBrowser.h>
#import <CCFramework/CCPhotographyHelper.h>
#import <CCFramework/CCPhotoLoadingView.h>
#import <CCFramework/CCPhotoProgressView.h>
#import <CCFramework/CCPhotoToolbar.h>
#import <CCFramework/CCPhotoView.h>
#import <CCFramework/CCPickerAssetsViewController.h>
#import <CCFramework/CCPickerCollectionView.h>
#import <CCFramework/CCPickerCollectionViewCell.h>
#import <CCFramework/CCPickerDatas.h>
#import <CCFramework/CCPickerGroup.h>
#import <CCFramework/CCPickerGroupViewController.h>
#import <CCFramework/CCPickerViewController.h>
#import <CCFramework/CCPieChart.h>
#import <CCFramework/CCPopMenu.h>
#import <CCFramework/CCPopMenuItem.h>
#import <CCFramework/CCPopMenuItemView.h>
#import <CCFramework/CCPopMenuView.h>
#import <CCFramework/CCQRCodeViewController.h>
#import <CCFramework/CCRefresh.h>
#import <CCFramework/CCRefreshBaseView.h>
#import <CCFramework/CCRefreshFooterView.h>
#import <CCFramework/CCRefreshHeaderView.h>
#import <CCFramework/CCRourRotation.h>
#import <CCFramework/CCScanningView.h>
#import <CCFramework/CCSecurityStrategy.h>
#import <CCFramework/CCShareMenuItem.h>
#import <CCFramework/CCShareMenuView.h>
#import <CCFramework/CCSideMenu.h>
#import <CCFramework/CCSideMenuCell.h>
#import <CCFramework/CCSideMenuItem.h>
#import <CCFramework/CCSignatureView.h>
#import <CCFramework/CCSlideShadowAnimation.h>
#import <CCFramework/CCTableViewCell.h>
#import <CCFramework/CCTextViewPlaceholder.h>
#import <CCFramework/CCThemeManager.h>
#import <CCFramework/CCTimePicker.h>
#import <CCFramework/CCUncaughtExceptionHandler.h>
#import <CCFramework/CCUserDefaults.h>
#import <CCFramework/CCUserDefaultsCrash.h>
#import <CCFramework/CCVideoOutputSampleBufferFactory.h>
#import <CCFramework/CCVoiceCommonHelper.h>
#import <CCFramework/CCVoiceRecordHelper.h>
#import <CCFramework/CCVoiceRecordHUD.h>
#import <CCFramework/CCWaterfallsFlow.h>
#import <CCFramework/CCWebViewController.h>
#import <CCFramework/CCWebViewProgress.h>
#import <CCFramework/CCWebViewProgressView.h>
#import <CCFramework/CCRadarScanViewController.h>
#import <CCFramework/CCRadarView.h>
#import <CCFramework/CCRadarPointView.h>
#import <CCFramework/ColumnarChart.h>
#import <CCFramework/Config.h>
#import <CCFramework/ContactPersonEntity.h>
#import <CCFramework/ContactRead.h>
#import <CCFramework/CoreDataManager.h>
#import <CCFramework/CustomIOS7AlertView.h>
#import <CCFramework/EnumConfig.h>
#import <CCFramework/Friend.h>
#import <CCFramework/FriendGroup.h>
#import <CCFramework/MBProgressHUD.h>
#import <CCFramework/MBProgressHUD+Add.h>
#import <CCFramework/MKAnnotationView+WebCache.h>
#import <CCFramework/NavMainViewController.h>
#import <CCFramework/NSArray+BNSArray.h>
#import <CCFramework/NSData+SRB64Additions.h>
#import <CCFramework/NSDate+BNSDate.h>
#import <CCFramework/NSData+Additions.h>
#import <CCFramework/NSData+ImageContentType.h>
#import <CCFramework/NSMutableArray+BNSMutableArray.h>
#import <CCFramework/NSObject+SRJSON.h>
#import <CCFramework/NSString+BNSString.h>
#import <CCFramework/SignalRManager.h>
#import <CCFramework/SmoothViewController.h>
#import <CCFramework/ResourcesPhotos.h>
#import <CCFramework/UILabel+Addition.h>
#import <CCFramework/UIAlertView+Additional.h>
#import <CCFramework/UIActionSheet+BUIActionSheet.h>
#import <CCFramework/UIButton+BUIButton.h>
#import <CCFramework/UIButton+CCButtonTitlePosition.h>
#import <CCFramework/UIBarButtonItem+Addition.h>
#import <CCFramework/UIButton+WebCache.h>
#import <CCFramework/UIColor+BUIColor.h>
#import <CCFramework/UIControl+BUIControl.h>
#import <CCFramework/UIImage+Additions.h>
#import <CCFramework/UIImage+Alpha.h>
#import <CCFramework/UIImage+BUIImage.h>
#import <CCFramework/UIImage+CCRounded.h>
#import <CCFramework/UIImage+Data.h>
#import <CCFramework/UIImage+GIF.h>
#import <CCFramework/UIImageView+HighlightedWebCache.h>
#import <CCFramework/UIImage+MultiFormat.h>
#import <CCFramework/UIImage+Operations.h>
#import <CCFramework/UIImage+Resize.h>
#import <CCFramework/UIImage+RoundedCorner.h>
#import <CCFramework/UIImage+Utility.h>
#import <CCFramework/UIImage+WebP.h>
#import <CCFramework/UIImageView+WebCache.h>
#import <CCFramework/UIScrollView+CCkeyboardControl.h>
#import <CCFramework/UITableView+Additions.h>
#import <CCFramework/UITabBarController+Additional.h>
#import <CCFramework/UIView+BUIView.h>
#import <CCFramework/UIView+CCBadgeView.h>
#import <CCFramework/UIView+CCRemoteImage.h>
#import <CCFramework/UIView+WebCacheOperation.h>
#import <CCFramework/UIWindow+Additions.h>
#import <CCFramework/UIWindow+BUIWindow.h>
#import <CCFramework/QRCode.h>