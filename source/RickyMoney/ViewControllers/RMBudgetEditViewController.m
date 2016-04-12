//
//  RMBudgetEditViewController.m
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMBudgetEditViewController.h"
#import "RMDataManagement.h"

@implementation RMBudgetEditViewController {
    NSString *currency;
    UIToolbar *doneToolbar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _budgetData = [[NSMutableArray alloc] init];
    _budgetUpdatedData = [[NSMutableDictionary alloc] init];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done"
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(hideNumberPad)];
    doneButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    doneToolbar.items = [[NSArray alloc] initWithObjects:flexibleItem, doneButton, nil];
    [doneToolbar sizeToFit];
    
    [self getUserCurrency];
    [self getBudgets];
}

#pragma mark - Data

- (void) getUserCurrency {
    currency = [[RMDataManagement getSharedInstance] getCurrentUserCurrencySymbol];
}

- (void) getBudgets {
    [_budgetData removeAllObjects];
    NSArray *results = [[RMDataManagement getSharedInstance] getAllBudgetsForEdit];
    if (results != nil && results.count > 0) {
        [_budgetData addObjectsFromArray:results];
    } else {
        results = [[RMDataManagement getSharedInstance] getAllCategory];
        if (results != nil && results.count > 0) {
            [_budgetData addObjectsFromArray:results];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _budgetData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    id cellData = [_budgetData objectAtIndex:indexPath.row];
    
    NSString *catName = @"";
    NSString *catImg = @"";
    float catBudget = 0.0f;
    
    if ([cellData isKindOfClass:[Budget class]] == YES) {
        Budget *budget = (Budget*)cellData;
        catName = budget.categoryName;
        catImg = budget.categoryIcon;
        catBudget = budget.budget;
        
    } else if ([cellData isKindOfClass:[Category class]] == YES) {
        Category *cat = (Category*) cellData;
        catName = cat.enName;
        catImg = cat.icon;
    }
    
    UITextField *budgetField = (UITextField*) [cell viewWithTag:3];
    
    NSString *imageFile = [[NSBundle mainBundle] pathForResource:catImg ofType:@"png"];
    [((UIImageView*)[cell viewWithTag:1]) setImage:[UIImage imageWithContentsOfFile:imageFile]];
    [((UILabel*) [cell viewWithTag:2]) setText:catName];
    [((UILabel*) [cell viewWithTag:4]) setText:currency];
    
    budgetField.text = [NSString stringWithFormat:@"%.2f", catBudget];
    budgetField.delegate = self;
    budgetField.inputAccessoryView = doneToolbar;
    
    return cell;
}

#pragma mark- TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *idp;
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    idp = [self.tableView indexPathForCell: cell];
    
    NSString *catId = @"";
    id cellData = [_budgetData objectAtIndex:idp.row];
    if ([cellData isKindOfClass:[Budget class]] == YES) {
        Budget *budget = (Budget*)cellData;
        catId = budget.categoryId;
        
    } else if ([cellData isKindOfClass:[Category class]] == YES) {
        Category *cat = (Category*) cellData;
        catId = cat.objectId;
    }
    
    [_budgetUpdatedData setValue:textField.text forKey:catId];
    
    // update text format
    textField.text = [NSString stringWithFormat:@"%.2f", [textField.text floatValue]];
    
    textField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    textField.textColor = RM_COLOR;
    [UIView animateWithDuration:0.5
                     animations:^{
                         textField.transform = CGAffineTransformMakeScale(1.3, 1.3);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              textField.transform = CGAffineTransformIdentity;
                                          }
                                          completion:^(BOOL finished) {
                                              textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
                                              textField.textColor = [UIColor lightGrayColor];
                                          }];
                     }];
}

#pragma mark- Actions

- (void) hideNumberPad {
    [self.view endEditing:YES];
}

- (IBAction)ontouchSave:(id)sender {
    
    [self.view endEditing:YES];
    
    for (NSString *catId in _budgetUpdatedData.allKeys) {
        float budget = [[_budgetUpdatedData valueForKey:catId] floatValue];
        
        [[RMDataManagement getSharedInstance] createNewBudget:budget forCategory:catId];
    }
}
@end
