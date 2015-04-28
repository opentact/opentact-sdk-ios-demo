//
//  FriendTableViewCell.h
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/6.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *sipStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imStatus;

@end
