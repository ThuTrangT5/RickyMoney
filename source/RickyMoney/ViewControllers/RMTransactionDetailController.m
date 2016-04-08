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
#import "UIImage+FontAwesome.h"

#import "RMDataManagement.h"
#import "RMObjects.h"

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
    
    // insert tick image for save button
    CGSize size = CGSizeMake(20, 20);
    UIImage *tick = [UIImage imageWithIcon:@"fa-check" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:size];
    UIImageView *tickView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [tickView setImage:tick];
    [[self.view viewWithTag:10] addSubview:tickView];
    
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

- (void) getUserCurrency {
    [RMParseRequestHandler getCurrentUserInformation:^(PFObject *user) {
        NSString *currency = [NSString stringWithFormat:@"%@ (%@)", [user objectForKey:@"currencyUnit"][@"name"], [user objectForKey:@"currencyUnit"][@"symbol"]];
        _currencyField.text = currency;
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
    
    if (_transactionId == nil) {
        Transaction *newTransaction = [[Transaction alloc] init];
        newTransaction.item = _itemField.text;
        newTransaction.categoryId = _categoryId;
        newTransaction.amount = [_amountField.text floatValue];
        newTransaction.notes = _noteField.text;
        newTransaction.type = (_transactionType == EXPENSE) ? 0 : 1;
        newTransaction.date = _transactionDate;
        
        [[RMDataManagement getSharedInstance] createNewTransaction: newTransaction];
    }
    
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

#pragma mark- RMOptionDelegate

- (void)optionViewsDoneWithSelectedData:(id)selectedData {
    if ([selectedData isKindOfClass:[Category class]] == YES) {
        Category *selectedCategory = (Category*) selectedData;
        self.categoryId = selectedCategory.objectId;
        [self.categoryField setTitle: selectedCategory.enName forState:UIControlStateNormal];
    }
}

#pragma mark- TTDatePickerViewDelegate

- (void)ttDatePickerPickedDate:(NSDate *)date {
    _transactionDate = date;
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = DATE_FORMAT;
    [_dateField setTitle: [dateFormater stringFromDate:date] forState:UIControlStateNormal];
}

@end
