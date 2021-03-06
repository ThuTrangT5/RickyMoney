//
//  RMTransactionDetailController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMOptionsViewController.h"
#import "TTDatePickerView.h"

@interface RMTransactionDetailController : UIViewController <RMOptionsDelegate, TTDatePickerViewDelegate,  UITextViewDelegate> {
    BOOL isLoadData;
}

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSDate *transactionDate;
@property (nonatomic) int transactionType; // type == 0 => expense

@property (weak, nonatomic) IBOutlet UITextField *itemField;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UILabel *currencyField;
@property (weak, nonatomic) IBOutlet UIButton *categoryField;
@property (weak, nonatomic) IBOutlet UIButton *dateField;
@property (weak, nonatomic) IBOutlet UITextView *noteField;

- (IBAction)ontouchSaveTransaction:(id)sender;
- (IBAction)ontouchSelectDate:(UIButton *)sender;

@end
