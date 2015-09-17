//
//  CCDropzoneViewController.m
//  CC
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

#import "CCDropzoneViewController.h"
#import "Config.h"

@interface CCDropzoneViewController (){
    UIView *MinimizedView,*MinimizedMenuView;
    UIButton *Aircraft,*Hotels,*Car,*add;
    
    //悬浮窗
    long direction;
    BOOL MoveEnabled,MoveEnable,Moving,touchYES;
    CGPoint beginpoint,selfBeginCenter;
    CGFloat w,h;
}

@end

@implementation CCDropzoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MoveEnable = YES;
    touchYES = YES;
}

-(void)InitControl{
    w = 0.125 * winsize.width;
    h = 0.125 * winsize.width;
    
    MinimizedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    MinimizedView.tag = 99998;
    [self.view addSubview:MinimizedView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MinimizedViewTap:)];
    singleTap.delaysTouchesBegan = YES;
    singleTap.numberOfTapsRequired = 1;
    [MinimizedView addGestureRecognizer:singleTap];
    
    UIImageView *MinimizedViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    MinimizedViewImageView.image = [UIImage imageNamed:@"floating_window"];
    [MinimizedView addSubview:MinimizedViewImageView];
    
    MinimizedMenuView = [[UIView alloc] initWithFrame:CGRectMake(20, (winsize.height - 264) / 2, winsize.width - 40, 200)];
    MinimizedMenuView.hidden = YES;
    MinimizedMenuView.backgroundColor = [UIColor whiteColor];
    MinimizedMenuView.layer.cornerRadius = 5;
    MinimizedMenuView.layer.masksToBounds = YES;
    [self.view addSubview:MinimizedMenuView];
    
}

-(void)MinimizedViewTap:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateEnded)
        [self MinimizedView];
}

-(void)MinimizedView{
    MinimizedView.hidden = NO;
    MinimizedMenuView.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    CGRect frame = self.view.window.frame;
    frame.size.height = 0.125 * winsize.width;
    frame.size.width = 0.125 * winsize.width;
    if (touchYES) {
        frame.size.height = winsize.height;
        frame.size.width = winsize.width;
        MinimizedMenuView.hidden = NO;
        MinimizedView.hidden = YES;
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    }
    h = frame.size.height;
    w = frame.size.width;
    self.view.window.frame = frame;
    touchYES = !touchYES;
    [self NewRect];
}

#pragma mark - 悬浮窗拖动方法
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (touchYES) {
        UITouch *touch = [touches anyObject];
        MoveEnabled = NO;
        if (!MoveEnable) {
            return;
        }
        beginpoint = [touch locationInView:self.view];
        selfBeginCenter = self.view.center;
    }else{
        if (!CGRectContainsPoint(MinimizedMenuView.frame, [[touches anyObject] locationInView:self.view]))
            [self MinimizedView];
    }
}

//拖动判断
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (touchYES) {
        MoveEnabled = YES;
        if (!MoveEnable)
            return;
        Moving = YES;
        
        UITapGestureRecognizer *ges = [self.view.gestureRecognizers lastObject];
        ges.enabled = NO;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view.window];
        self.view.center = CGPointMake(selfBeginCenter.x + (point.x - beginpoint.x), selfBeginCenter.y + (point.y - beginpoint.y));
        
        CGPoint previousPoint = [touch previousLocationInView:self.view.window];
        direction = NSNotFound;
        int velocity = [self velocityByPoint:point andPoint:previousPoint];
        if (abs(velocity) > 15) {
            int velocityX = point.x - previousPoint.x;
            int velocityY = point.y - previousPoint.y;
            if (abs(velocityX)  >  abs(velocityY)) {
                if (velocity > 0) {
                    direction = 1;
                }else{
                    direction = 3;
                }
            }else{
                if (velocity > 0) {
                    direction = 2;
                }else{
                    direction = 0;
                }
            }
        }
    }
}

//拖动结束判断
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (touchYES) {
        if (!MoveEnable)
            return;
        
        UITapGestureRecognizer *ges = [self.view.gestureRecognizers lastObject];
        ges.enabled = YES;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view.window];
        self.view.window.center = CGPointMake(self.view.window.center.x + (point.x - beginpoint.x), self.view.window.center.y + (point.y - beginpoint.y));
        self.view.frame = CGRectMake(0, 0, self.view.window.frame.size.width, self.view.window.frame.size.height);
        
        [self NewRect];
    }
}

-(void)NewRect{
    long directions = INT16_MAX;
    if (direction != NSNotFound)
        directions = direction;
    else
        directions = [self directByPoint:self.view.window.center];
    
    CGRect newRect;
    switch (directions) {
        case 0:
        {
            float x = self.view.window.frame.origin.x;
            newRect = CGRectMake(x + w > winsize.width ? winsize.width - w : x < 0 ? 0 : x,
                                 0,
                                 self.view.window.frame.size.width,
                                 self.view.window.frame.size.height);
        }
            break;
        case 1:
        {
            float x = [[UIScreen mainScreen] bounds].size.width - self.view.window.frame.size.width;
            float y = self.view.window.frame.origin.y < 0 ? 0 : self.view.window.frame.origin.y;
            newRect = CGRectMake(x + w > winsize.width ? winsize.width - w : x < 0 ? 0 : x,
                                 y + h > winsize.height ? winsize.height - h : y,
                                 self.view.window.frame.size.width,
                                 self.view.window.frame.size.height);
        }
            break;
        case 2:
        {
            float y = [[UIScreen mainScreen] bounds].size.height - self.view.window.frame.size.height;
            float x = self.view.window.frame.origin.x;
            x = x + w > winsize.width ? winsize.width - w : x - w < 0 ? 0 : x < 0 ? 0 : x;
            y = y + h > winsize.height ? winsize.height - h : y;
            newRect = CGRectMake(x,
                                 y,
                                 self.view.window.frame.size.width,
                                 self.view.window.frame.size.height);
        }
            break;
        case 3:
        {
            float y = self.view.window.frame.origin.y < 0 ? 0 : self.view.window.frame.origin.y;
            newRect = CGRectMake(0,
                                 y + h > winsize.height ? winsize.height - h : y,
                                 self.view.window.frame.size.width,
                                 self.view.window.frame.size.height);
        }
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.window.frame = newRect;
    } completion:^(BOOL finished) {
        
    }];
}

//外界因素取消touch事件，如进入电话
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(Moving){
        Moving = NO;
        UITapGestureRecognizer *ges = [self.view.gestureRecognizers lastObject];
        ges.enabled = YES;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view.window];
        self.view.window.center = CGPointMake(self.view.window.center.x + (point.x - beginpoint.x), self.view.window.center.y + (point.y - beginpoint.y));
        self.view.frame = CGRectMake(0, 0, self.view.window.frame.size.width, self.view.window.frame.size.height);
    }
}

-(int)directByPoint:(CGPoint)point{
    int dir = INT_MAX;
    int min = INT_MAX;
    if(fabs(point.x - 0) < min){
        min = fabs(point.x - 0);
        dir = 3;
    }
    
    if (fabs([[UIScreen mainScreen] bounds].size.width - point.x) < min) {
        min = fabs([[UIScreen mainScreen] bounds].size.width - point.x);
        dir = 1;
    }
    
    if (fabs([[UIScreen mainScreen] bounds].size.height - point.y) < min) {
        min = fabs([[UIScreen mainScreen] bounds].size.width - point.x);
        dir = 2;
    }
    
    return dir;
}

-(int)velocityByPoint:(CGPoint)point1 andPoint:(CGPoint)point2{
    int velocityX = point1.x - point2.x;
    int velocityY = point1.y - point2.y;
    
    if (abs(velocityX) > abs(velocityY))
        return velocityX;
    else
        return velocityY;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
