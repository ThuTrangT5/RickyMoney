//
//  RMSettingViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPasscodeViewController.h"
#import "RMOptionsViewController.h"
#import "CZPicker.h"

@interface RMSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RMPasscodeDelegate, CZPickerViewDelegate, CZPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
