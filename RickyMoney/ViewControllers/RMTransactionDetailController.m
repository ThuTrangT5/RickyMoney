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
    
    if (_transactionId == nil || _transactionId.length == 0) {
        _transactionDate = [NSDate new];
        
    } else {
        [self getTransactionDetail];
    }
    
}

- (void) getTransactionDetail {
    [RMParseRequestHandler getObjectById:_transactionId inClass:@"Transaction" withSuccessBlock:^(PFObject * __nullable object, NSError * __nullable error) {
        
        NSString *item = [object valueForKey:@"itemName"];
        NSString *amount = [NSString stringWithFormat:@"%@", [object valueForKey:@"amount"]];
        NSString *categoryId = [object valueForKey:@"categoryId"];
        BOOL repeat = [object valueForKey:@"repeat"];
        NSString *date = [NSString stringWithFormat:@"%@", [object valueForKey:@"transactionDate"]];
        date = [date substringToIndex:19];
        
        [RMParseRequestHandler getObjectById:categoryId inClass:@"Category" withSuccessBlock:^(PFObject * __nullable object, NSError * __nullable error) {
            NSString *category = [object valueForKey:@"ENName"];
            
            [_itemField setText:item];
            [_amountField setText:amount];
            [_categoryField setTitle:category forState:UIControlStateNormal];
            [_dateField setTitle:date forState:UIControlStateNormal];
            [_repeateField setSelected:repeat];
            
            _categoryId = categoryId;
            _repeatTransaction = repeat;
        }];
        
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
    //    if (_datePicker == nil ) {
    //        _datePicker = [[HSDatePickerViewController alloc] init];
    //        _datePicker.delegate = self;
    //        _datePicker.mainColor = RM_COLOR;
    //        _datePicker.confirmButtonTitle = @"OK";
    //        _datePicker.backButtonTitle = @"Cancel";
    //    }
    //
    //    _datePicker.date = _transactionDate;
    //
    //    [self presentViewController:_datePicker animated:YES completion:nil];
    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
    hsdpvc.delegate = self;
    if (self.transactionDate) {
        hsdpvc.date = self.transactionDate;
    }
    [self presentViewController:hsdpvc animated:YES completion:nil];
    
}

#pragma mark- Save transaction

- (void) saveTransaction {
    
    PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
    transaction[@"userId"] = [[PFUser currentUser] objectId];
    transaction[@"itemName"] = _itemField.text;
    transaction[@"categoryId"] = _categoryId;
    transaction[@"amount"] = [NSNumber numberWithInt:[_amountField.text intValue]];
    transaction[@"transactionDate"] = _transactionDate;
    transaction[@"repeat"] = _repeatTransaction ? @YES : @NO;
    transaction[@"notes"] = _noteField.text;
    
    [transaction saveEventually:^(BOOL success, NSError *err){
        NSLog(@"Save stransaction [%@] with error = %@", success? @"OK" : @"FAILED", err.description);
    }];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark- HSDatePickerViewControllerDelegate

- (void)hsDatePickerPickedDate:(NSDate *)date {
    _transactionDate = date;
    NSString *dateStr = [NSString stringWithFormat:@"%@", date];
    [_dateField setTitle:dateStr forState:UIControlStateNormal];
}

@end
