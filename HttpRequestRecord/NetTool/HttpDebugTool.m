//
//  HttpDebugTool.m
//  TiensClient
//
//  Created by wangfei on 2018/5/7.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "HttpDebugTool.h"
#import "UIViewController+Utils.h"

#define kDebugWinWidth 60
#define kDebugWinHeight 25
#define KB    (1024)
#define MB    (KB * 1024)
#define GB    (MB * 1024)

@interface HttpDebugTool()

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, assign) BOOL isDebugVcPresented;

@property (nonatomic, strong) HttpDebugWindow *debugWin;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation HttpDebugTool

- (instancetype)init {
    if (self = [super init]) {
        self.dataHandle = [[HttpDataHandle alloc]init];
    }
    return self;
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static HttpDebugTool *debugTool = nil;
    dispatch_once(&onceToken, ^{
        debugTool = [[[self class]alloc]init];
    });
    return debugTool;
}

#pragma mark - getter
- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setTitle:@"Debug" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn setBackgroundColor:[UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.5]];
        [_btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_btn addTarget:self action:@selector(closeHttpDebugVc:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (HttpDebugWindow *)debugWin {
    if (!_debugWin) {
        _debugWin = [[HttpDebugWindow alloc]initWithFrame:CGRectMake(0, 100, kDebugWinWidth, kDebugWinHeight)];
        _debugWin.windowLevel = UIWindowLevelStatusBar+1;
        _debugWin.hidden = NO;
    }
    return _debugWin;
}

#pragma mark - private method
- (void)closeHttpDebugVc:(id)sender {
    
    UIViewController *currentVc = [UIViewController currentViewController];
    
    if (!self.isDebugVcPresented) {
        HttpURLVC *vc = [[HttpURLVC alloc]init];
        UINavigationController *na = [[UINavigationController alloc]initWithRootViewController:vc];
        [na.navigationBar setTintColor:self.mainColor ? self.mainColor : kDefaultMainColor];
        [na.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:self.mainColor ? self.mainColor : kDefaultMainColor}];
        [currentVc presentViewController:na animated:YES completion:^{
            self.isDebugVcPresented = YES;
        }];
    }else {
        [currentVc dismissViewControllerAnimated:YES completion:^{
            self.isDebugVcPresented = NO;
        }];
    }
    
}

- (NSString* )number2String:(int64_t)n
{
    if ( n < KB )
    {
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < MB )
    {
        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)KB];
    }
    else if ( n < GB )
    {
        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)MB];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)GB];
    }
}

#pragma mark - public method
- (void)debugToolEnabled {
    [self.btn setFrame:CGRectMake(0, 0, kDebugWinWidth, kDebugWinHeight)];
    
    self.btn.layer.masksToBounds = YES;
    self.btn.layer.cornerRadius = kDebugWinHeight/2;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.debugWin addSubview:self.btn];
    });
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 3 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        unsigned long long used = [MemoryHelper bytesOfUsedMemory];
        NSString* text = [self number2String:used];
        [self.btn setTitle:[NSString stringWithFormat:@"%@",text] forState:UIControlStateNormal];
    });
    dispatch_resume(_timer);
    
}

@end

@interface HttpDebugWindow()

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation HttpDebugWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint translatedPoint = [recognizer translationInView:self];
    CGFloat x = recognizer.view.center.x + translatedPoint.x;
    CGFloat y = recognizer.view.center.y + translatedPoint.y;
    
    recognizer.view.center = CGPointMake(x, y);
    
    if (CGRectGetMinX(recognizer.view.frame) < 0) {
        [recognizer.view setFrame:CGRectMake(0, CGRectGetMinY(recognizer.view.frame), CGRectGetWidth(recognizer.view.frame), CGRectGetHeight(recognizer.view.frame))];
    }
    if (CGRectGetMaxX(recognizer.view.frame) > CGRectGetWidth([UIScreen mainScreen].bounds)) {
        [recognizer.view setFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(recognizer.view.frame), CGRectGetMinY(recognizer.view.frame), CGRectGetWidth(recognizer.view.frame), CGRectGetHeight(recognizer.view.frame))];
    }
    if (CGRectGetMinY(recognizer.view.frame) < 0) {
        [recognizer.view setFrame:CGRectMake(CGRectGetMinX(recognizer.view.frame), 0, CGRectGetWidth(recognizer.view.frame), CGRectGetHeight(recognizer.view.frame))];
    }
    if (CGRectGetMaxY(recognizer.view.frame) > CGRectGetHeight([UIScreen mainScreen].bounds)) {
        [recognizer.view setFrame:CGRectMake(CGRectGetMinX(recognizer.view.frame), CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(recognizer.view.frame), CGRectGetWidth(recognizer.view.frame), CGRectGetHeight(recognizer.view.frame))];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            if (x < CGRectGetWidth([UIScreen mainScreen].bounds) / 2) {
                [recognizer.view setFrame:CGRectMake(0, CGRectGetMinY(recognizer.view.frame), CGRectGetWidth(recognizer.view.frame), CGRectGetHeight(recognizer.view.frame))];
            }else {
                [recognizer.view setFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(recognizer.view.frame), CGRectGetMinY(recognizer.view.frame), CGRectGetWidth(recognizer.view.frame), CGRectGetHeight(recognizer.view.frame))];
            }
        }];
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];

}

@end
