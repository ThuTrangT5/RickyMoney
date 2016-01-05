//
//  RMTransactionDetailController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMOptionsViewController.h"
#import "TTDatePickerViewController.h"

@interface RMTransactionDetailController : UIViewController <RMOptionsDelegate, TTDatePickerViewControllerDelegate> {
    BOOL isLoadData;
}

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *categoryId;
@property (nonatomic) BOOL repeatTransaction;
@property (strong, nonatomic) NSDate *transactionDate;
@property (nonatomic) int transactionType; // type == 0 => expense

@property (weak, nonatomic) IBOutlet UITextField *itemField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UIButton *categoryField;
@property (weak, nonatomic) IBOutlet UISwitch *repeateField;
@property (weak, nonatomic) IBOutlet UIButton *dateField;
@property (weak, nonatomic) IBOutlet UITextView *noteField;

- (IBAction)onchangeRepeatValue:(UISwitch *)sender;
- (IBAction)ontouchSaveTransaction:(id)sender;
- (IBAction)ontouchSelectDate:(UIButton *)sender;

@end
