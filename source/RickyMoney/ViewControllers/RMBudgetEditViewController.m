//
//  RMBudgetEditViewController.m
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMBudgetEditViewController.h"
#import "RMDataManagement.h"

@implementation RMBudgetEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _budgetData = [[NSMutableArray alloc] init];
    [self getBudgets];
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
    
    if ([cellData isKindOfClass:[Budget class]] == YES) {
        Budget *budget = (Budget*)cellData;
        cell.textLabel.text = budget.categoryName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", budget.budget];
        
    } else if ([cellData isKindOfClass:[Category class]] == YES) {
        Category *cat = (Category*) cellData;
        cell.textLabel.text = cat.enName;
        cell.detailTextLabel.text = @"0";
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)ontouchSave:(id)sender {
    
    for (id object in _budgetData) {
        NSString *catId;
        float budget;
        
        if ([object isKindOfClass:[Budget class]] == YES) {
            catId = [(Budget *) object categoryId];
            
        } else if ([object isKindOfClass:[Category class]] == YES) {
            catId = [(Category*) object objectId];
        }
        
        budget = 250.0;
        
        [[RMDataManagement getSharedInstance] createNewBudget:budget forCategory:catId ];
    }
    
}
@end
