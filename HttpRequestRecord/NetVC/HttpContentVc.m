//
//  HttpContentVc.m
//  TiensClient
//
//  Created by wangfei on 2018/5/8.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "HttpContentVc.h"
#import "TLToastManager.h"

@interface HttpContentVc ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation HttpContentVc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"复制" style:UIBarButtonItemStylePlain target:self action:@selector(copyContent)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.textView];
    self.textView.text = self.httpContent;
    
    [self.textView setContentOffset:CGPointZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:self.view.frame];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView.editable = NO;
//        if (@available(iOS 11, *)) {
//            _textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }else {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
    }
    return _textView;;
}

- (void)copyContent {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.httpContent;
    [TLToastManager showTextTo:self.view withText:@"复制成功" dismissAfterr:1.5];
}

@end
