//
//  RMHomeViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LMDropdownView/LMDropdownView.h>
#import "VBPieChart.h"

@interface RMHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *menuItems;

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) LMDropdownView *dropdownView;

@property (strong, nonatomic) VBPieChart *chartView;

- (IBAction)ontouchMenu:(id)sender;
@end
