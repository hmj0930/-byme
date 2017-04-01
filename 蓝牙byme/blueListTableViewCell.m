//
//  blueListTableViewCell.m
//  蓝牙byme
//
//  Created by MJ on 2017/3/30.
//  Copyright © 2017年 韩明静. All rights reserved.
//

#import "blueListTableViewCell.h"

@implementation blueListTableViewCell

-(UILabel *)titleLabel{
    
    if (_titleLabel==nil) {
        _titleLabel=[UILabel new];
        _titleLabel.text=@"123";
    }
    return _titleLabel;
}

-(UILabel *)subTitleLabel{
    
    if (_subTitleLabel==nil) {
        _subTitleLabel=[UILabel new];
    }
    return _subTitleLabel;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.titleLabel.frame=CGRectMake(15, 5, [UIScreen mainScreen].bounds.size.width, 25);
        self.subTitleLabel.frame=CGRectMake(15, 30, [UIScreen mainScreen].bounds.size.width, 20);
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.backgroundColor=[UIColor redColor];
        
    }
    return self;
}


@end
