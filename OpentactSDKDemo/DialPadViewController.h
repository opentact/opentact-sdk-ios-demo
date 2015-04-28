//
//  DialViewController.h
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/6.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialPadViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
- (IBAction)numberBtnClicked:(id)sender;
- (IBAction)delBtnClicked:(id)sender;

@end
