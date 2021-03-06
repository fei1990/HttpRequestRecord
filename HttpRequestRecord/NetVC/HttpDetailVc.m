//
//  HttpDetailVc.m
//  TiensClient
//
//  Created by wangfei on 2018/5/8.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "HttpDetailVc.h"
#import "HttpDebugCell.h"
#import "HttpContentVc.h"

#define detailNames @[@"Request Url",@"Request Method",@"Status Code",@"Mime Type",@"Request Header Fields",@"Request Body",@"Response Header Fields",@"Response Body"]

static  NSString *const cellIdentifier = @"cellIdentifier";

@interface HttpDetailVc ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HttpDetailVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请求详情";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = (id<UITableViewDelegate>)self;
        _tableView.dataSource = (id<UITableViewDataSource>)self;
        _tableView.rowHeight = 60;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HttpContentVc *contentVc = [[HttpContentVc alloc]init];
    if (indexPath.row == 0) {
        contentVc.httpContent = self.httpModel.absoluteUrl;
        contentVc.title = @"接口地址";
    }else if (indexPath.row == 4 || indexPath.row == 6) {
        if (indexPath.row == 4) {
            contentVc.httpContent = [[HttpDebugTool shareInstance].dataHandle parseDicToString:self.httpModel.requestHeaderFields];
            contentVc.title = @"请求头";
        }else {
            contentVc.httpContent = [[HttpDebugTool shareInstance].dataHandle parseDicToString:self.httpModel.responseHeaderFields];
            contentVc.title = @"响应头";
        }
    }else if (indexPath.row == 5 || indexPath.row == 7) {
        if (indexPath.row == 5) {
            NSData *reqeustBody = nil;
            if ([HttpDebugTool shareInstance].delegate && [[HttpDebugTool shareInstance].delegate respondsToSelector:@selector(decriptData:)]) {
                reqeustBody = [[HttpDebugTool shareInstance].delegate decriptData:self.httpModel.requestBody];
            }else {
                reqeustBody = self.httpModel.requestBody;
            }
            contentVc.httpContent = [[HttpDebugTool shareInstance].dataHandle parseDataToString:reqeustBody];
            contentVc.title = @"请求体";
        }else {
            contentVc.httpContent = [[HttpDebugTool shareInstance].dataHandle parseDataToString:self.httpModel.responseBody];
            contentVc.title = @"响应体";
        }
    }else {
        return;
    }
    [self.navigationController pushViewController:contentVc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return detailNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HttpDebugCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[HttpDebugCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *name = detailNames[indexPath.row];
    NSString *value = @"";
    
    if (indexPath.row == 0) {
        value = _httpModel.absoluteUrl;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 1) {
        value = _httpModel.method;
    }
    if (indexPath.row == 2) {
        value = _httpModel.statusCode;
    }
    if (indexPath.row == 3) {
        value = _httpModel.MIMEType;
    }
    if (indexPath.row == 4) {   //请求头
        value = @"show request header fields";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 5) {   //请求体
        value = @"show request body";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 6) {
        value = @"show response header fields";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 7) {
        NSUInteger length = _httpModel.responseBody.length;
        if (length < 1024) {
            value = [NSString stringWithFormat:@"(%zdB) show response body", length];
        }else {
            value = [NSString stringWithFormat:@"(%.2fKB) show response body", 1.0 * length / 1024];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setName:name value:value];

    return cell;
}

@end
