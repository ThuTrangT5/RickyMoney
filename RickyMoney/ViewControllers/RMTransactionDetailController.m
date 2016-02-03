//
//  RMTransactionDetailController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMTransactionDetailController.h"
#import <Parse/Parse.h>
#import "RMParseRequestHandler.h"

@implementation RMTransactionDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _noteField.layer.cornerRadius = 10;
    _noteField.layer.borderWidth = 1;
    _noteField.layer.borderColor = RM_COLOR.CGColor;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isLoadData == false) {
        
        if (_transactionId == nil || _transactionId.length == 0) {
            [self ttDatePickerPickedDate:[NSDate new]];
            
        } else {
            [self getTransactionDetail];
        }
        isLoadData = true;
    }
}

- (void) getTransactionDetail {
    [RMParseRequestHandler getObjectById:_transactionId inClass:@"Transaction" includeFields:@[@"category"] withSuccessBlock:^(PFObject * object) {
        
        PFObject *category = [object valueForKey:@"category"];
        _categoryId = [category valueForKey:@"objectId"];
        NSString *categoryName = [category valueForKey:@"ENName"];
        
        NSString *item = [object valueForKey:@"itemName"];
        NSString *amount = [NSString stringWithFormat:@"%@", [object valueForKey:@"amount"]];
        BOOL repeat = [[object valueForKey:@"repeat"] boolValue];
        NSString *notes = [object valueForKey:@"notes"];
        _transactionType = (int) [object[@"type"] integerValue];
        _transactionDate = [object valueForKey:@"transactionDate"];
        
        NSString *date = [NSString stringWithFormat:@"%@", _transactionDate];
        date = [date substringToIndex:19];
        
        
        [_itemField setText:item];
        [_amountField setText:amount];
        [_categoryField setTitle:categoryName forState:UIControlStateNormal];
        [_dateField setTitle:date forState:UIControlStateNormal];
        [_repeateField setOn:repeat animated:YES];
        [_noteField setText:notes];
        
        _repeatTransaction = repeat;
        
    }];
}

#pragma mark- Actions

- (IBAction)onchangeRepeatValue:(UISwitch *)sender {
    _repeatTransaction = [sender isOn];
}

- (IBAction)ontouchSaveTransaction:(id)sender {
    [_itemField resignFirstResponder];
    [_amountField resignFirstResponder];
    
    // validate
    BOOL isValid = YES;
    
    if (_itemField.text.length == 0) {
        isValid = NO;
    }
    if (_amountField.text.length == 0) {
        isValid = NO;
    }
    if (_categoryId == nil || _categoryId.length == 0) {
        isValid = NO;
    }
    
    if (isValid) {
        [self saveTransaction];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Something not right. Please check again!"
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

- (IBAction)ontouchSelectDate:(UIButton *)sender {
    TTDatePickerViewController *datepickerVC = [TTDatePickerViewController new];
    datepickerVC.mainColor = RM_COLOR;
    datepickerVC.confirmButtonTitle = @"Select";
    datepickerVC.titlePicker = @"Transaction Date";
    datepickerVC.delegate = self;
    [self presentViewController:datepickerVC animated:YES completion:nil];
    
}

#pragma mark- Save transaction

- (void) saveTransaction {
    
    PFObject *pointer = [PFObject objectWithoutDataWithClassName:@"Category" objectId:_categoryId];
    
    PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
    transaction[@"userId"] = [[PFUser currentUser] objectId];
    transaction[@"itemName"] = _itemField.text;
    transaction[@"category"] = pointer;
    transaction[@"amount"] = [NSNumber numberWithInt:[_amountField.text intValue]];
    transaction[@"transactionDate"] = _transactionDate;
    transaction[@"repeat"] = _repeatTransaction ? @YES : @NO;
    transaction[@"notes"] = _noteField.text;
    transaction[@"type"] = [NSNumber numberWithInt:_transactionType];
    
    if (_transactionId != nil) {
        transaction.objectId = _transactionId;
    }
    
    [transaction saveEventually:^(BOOL success, NSError *err){
        NSLog(@"Save stransaction [%@] with error = %@", success? @"OK" : @"FAILED", err.description);
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInsertNewTransaction object:transaction];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            
        }
    }];
}

#pragma mark- Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectCategorySegue"]) {
        RMOptionsViewController *optionVC = (RMOptionsViewController*)[segue destinationViewController];
        optionVC.option = OPTION_CATEGORY;
        optionVC.delegate = self;
    }
}

#pragma mark-
- (void)optionView:(OptionTypes)option DoneWithSelectedData:(NSDictionary *)selectedData {
    self.categoryId = [selectedData valueForKey:@"objectId"];
    [self.categoryField setTitle:[selectedData valueForKey:@"categoryName"] forState:UIControlStateNormal];
}

#pragma mark- TTDatePickerViewControllerDelegate

- (void)ttDatePickerPickedDate:(NSDate *)date {
    _transactionDate = date;
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = @"MMMM dd, yyyy";
    [_dateField setTitle: [dateFormater stringFromDate:date] forState:UIControlStateNormal];
}

@end
