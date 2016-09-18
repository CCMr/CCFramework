//
//  CCAlbumCell.m
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

#import "CCAlbumCell.h"
#import "CCAlbumModel.h"
#import "CCPhotoManager.h"

@implementation CCAlbumCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)configCellWithItem:(CCAlbumModel *_Nonnull)item
{
    
//    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:item.name attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor blackColor]}];
//    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)", item.count] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
//    [nameString appendAttributedString:countString];
//    self.textLabel.attributedText = nameString;
    self.textLabel.text = item.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%zi",item.count];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    __weak typeof(*&self) wSelf = self;
    [[CCPhotoManager sharedManager] getThumbnailWithAsset:[item.fetchResult lastObject] size:kCCThumbnailSize completionBlock:^(UIImage *image) {
        __weak typeof(*&self) self = wSelf;
        self.imageView.image = image;
        
        CGSize itemSize = CGSizeMake(50, 50);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [self.imageView.image drawInRect:imageRect];
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }];
}

@end
