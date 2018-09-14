//
//  HttpURLVC.m
//  TiensClient
//
//  Created by wangfei on 2018/5/8.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "HttpURLVC.h"
#import "HttpDebugCell.h"
#import "HttpDebugTool.h"
#import "HttpDetailVc.h"

static  NSString *const cellIdentifier = @"cellIdentifier";
@interface HttpURLVC ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HttpURLVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请求链接";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:[HttpDebugTool shareInstance] action:NSSelectorFromString(@"closeHttpDebugVc:")];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clearHttpRequest)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
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

- (void)clearHttpRequest {
    [[HttpDebugTool shareInstance].dataHandle clear];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HttpDetailVc *detailVc = [[HttpDetailVc alloc]init];
    HttpModel *model = [HttpDebugTool shareInstance].dataHandle.httpDataArr[indexPath.row];
    detailVc.httpModel = model;
    [self.navigationController pushViewController:detailVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HttpDebugTool shareInstance].dataHandle.httpDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HttpDebugCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[HttpDebugCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    HttpModel *model = [HttpDebugTool shareInstance].dataHandle.httpDataArr[indexPath.row];
    
    [cell setName:model.host value:model.path];
    
    return cell;
    
}

@end
