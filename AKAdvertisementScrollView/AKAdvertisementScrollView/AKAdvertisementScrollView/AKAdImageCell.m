//
//  AKAdImageCell.m
//  AKAdScrollView
//
//  Created by Aston K Mac on 15/9/10.
//  Copyright (c) 2015年 UYAC. All rights reserved.
//

#import "AKAdImageCell.h"

@implementation AKAdImageCell

- (void)awakeFromNib {
    // Initialization code
    self.adImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
