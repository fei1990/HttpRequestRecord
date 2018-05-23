//
//  HttpDebugCell.m
//  TiensClient
//
//  Created by wangfei on 2018/5/8.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "HttpDebugCell.h"
#import "HttpDebugTool.h"

@implementation HttpDebugCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.textColor = [HttpDebugTool shareInstance].mainColor ? [HttpDebugTool shareInstance].mainColor : kDefaultMainColor;
        self.detailTextLabel.textColor = [HttpDebugTool shareInstance].mainColor ? [HttpDebugTool shareInstance].mainColor : kDefaultMainColor;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name value:(NSString *)value {
    self.textLabel.text = name;
    self.detailTextLabel.text = value;
}

@end
