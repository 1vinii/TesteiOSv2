//
//  DetailTableCell.m
//  BankApp
//
//  Created by Vinícius Brito on 24/09/19.
//  Copyright © 2019 Vinícius Brito. All rights reserved.
//

#import "DetailTableCell.h"

@implementation DetailTableCell
@synthesize titleLabel = _titleLabel, descLabel = _descLabel, dateLabel = _dateLabel, valueLabel = _valueLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
