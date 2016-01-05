//
//  TTDatePickerViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 10/26/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "TTDatePickerViewController.h"

@interface TTDatePickerViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *titleField;
@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UIView *separator3;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation TTDatePickerViewController

-(instancetype)init {
    if ( self = [super init] ) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        // default value
        _mainColor = [UIColor blackColor];
        _titlePicker = @"Title";
        _confirmButtonTitle = @"Set date";
        _cancelButtonTitle = @"Cancel";
        _datePickerMode = UIDatePickerModeDate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set border
    [_contentView.layer setCornerRadius:10.0f];
    [_contentView.layer setBorderColor:_mainColor.CGColor];
    [_contentView.layer setBorderWidth:2.0f];
    [_contentView.layer setMasksToBounds:YES];
    
    // set main color
    [_titleField setTextColor:_mainColor];
    [_confirmButton setTitleColor:_mainColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:_mainColor forState:UIControlStateNormal];
    [_separator1 setBackgroundColor:_mainColor];
    [_separator2 setBackgroundColor:_mainColor];
    [_separator3 setBackgroundColor:_mainColor];
    
    // set title
    [_titleField setText:_titlePicker];
    [_confirmButton setTitle:_confirmButtonTitle forState:UIControlStateNormal];
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    
    // datepicker
    if (_minDate != nil) {
        [_datePicker setMinimumDate:_minDate];
    }
    if (_maxDate != nil) {
        [_datePicker setMaximumDate:_maxDate];
    }
    if (_date != nil) {
        [_datePicker setDate:_date];
    }
    if (_datePickerMode) {
        [_datePicker setDatePickerMode:_datePickerMode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- DatePicker Actions

- (IBAction)confirmAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(ttDatePickerPickedDate:)]) {
        NSDate *selectedDate = [_datePicker date];
        [_delegate ttDatePickerPickedDate:selectedDate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
