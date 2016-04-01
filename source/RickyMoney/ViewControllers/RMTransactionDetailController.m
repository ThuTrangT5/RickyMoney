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

#define DATE_FORMAT @"MMM dd, yyyy"

@implementation RMTransactionDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI border
    NSArray *controls = [[NSArray alloc] initWithObjects:_itemField, _amountField.superview, _categoryField, _dateField, _noteField, nil];
    for (UIView *control in controls) {
        control.layer.cornerRadius = 10;
        control.layer.borderWidth = 0.5f;
        control.layer.borderColor = RM_COLOR.CGColor;
    }
    
    // tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
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
        NSString *notes = [object valueForKey:@"notes"];
        _transactionType = (int) [object[@"type"] integerValue];
        _transactionDate = [object valueForKey:@"transactionDate"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMAT;
        NSString *date = [formatter stringFromDate:_transactionDate];
        
        [_itemField setText:item];
        [_amountField setText:amount];
        [_categoryField setTitle:categoryName forState:UIControlStateNormal];
        [_dateField setTitle:date forState:UIControlStateNormal];
        [_noteField setText:notes];
    }];
}

#pragma mark- Actions

- (void) dismissKeyboard {
    [self.view endEditing:YES];
    
    [UIView beginAnimations:@"shiftView" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    self.view.bounds = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
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
    [self dismissKeyboard];
    
    TTDatePickerView *datepicker = [[TTDatePickerView alloc] init];
    datepicker.mainColor = RM_COLOR;
    datepicker.confirmButtonTitle = @"Select";
    datepicker.titlePicker = @"Transaction Date";
    datepicker.delegate = self;
    
    [datepicker show];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:@"shiftView" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    self.view.bounds = CGRectMake(self.view.frame.origin.x, 120, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
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
    transaction[@"notes"] = _noteField.text;
    transaction[@"type"] = [NSNumber numberWithInt:_transactionType];
    
    if (_transactionId != nil) {
        transaction.objectId = _transactionId;
    }
    
    [transaction saveEventually:^(BOOL success, NSError *err){
        NSLog(@"Save stransaction [%@] with error = %@", success? @"OK" : @"FAILED", err.description);
        if (success) {
            if (_transactionId != nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTransaction object:transaction];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kInsertNewTransaction object:transaction];
            }
            
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

#pragma mark- TTDatePickerViewDelegate

- (void)ttDatePickerPickedDate:(NSDate *)date {
    _transactionDate = date;
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = DATE_FORMAT;
    [_dateField setTitle: [dateFormater stringFromDate:date] forState:UIControlStateNormal];
}

@end
