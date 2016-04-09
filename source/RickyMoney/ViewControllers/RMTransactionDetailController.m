//
//  RMTransactionDetailController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMTransactionDetailController.h"
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
        
        [self getUserCurrency];
        
        isLoadData = true;
    }
}

- (void) getTransactionDetail {
    Transaction *transaction = [[RMDataManagement getSharedInstance] getTransactionDetail:_transactionId];
    if (transaction != nil) {
        _categoryId = transaction.categoryId;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMAT;
        NSString *mdy = [formatter stringFromDate: transaction.date];
        
        [_itemField setText:transaction.item];
        [_amountField setText: [NSString stringWithFormat: @"%.2f", transaction.amount]];
        [_categoryField setTitle:transaction.categoryName forState:UIControlStateNormal];
        [_dateField setTitle:mdy forState:UIControlStateNormal];
        [_noteField setText:transaction.notes];
    }
}

- (void) getUserCurrency {
    _currencyField.text = [[RMDataManagement getSharedInstance] getCurrentUserCurrencySymbol];
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
    
    Transaction *trans = [[Transaction alloc] init];
    trans.item = _itemField.text;
    trans.categoryId = _categoryId;
    trans.amount = [_amountField.text floatValue];
    trans.notes = _noteField.text;
    trans.type = (_transactionType == EXPENSE) ? 0 : 1;
    trans.date = _transactionDate;
    
    if (_transactionId == nil) {
        _transactionId = [[RMDataManagement getSharedInstance] createNewTransaction: trans];
        if (_transactionId != nil) {
            trans.objectId = _transactionId;
            [[NSNotificationCenter defaultCenter] postNotificationName:kInsertNewTransaction object:trans];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        trans.objectId = _transactionId;
        
        if ([[RMDataManagement getSharedInstance] updateTransaction:trans] == YES) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTransaction object:trans];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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
