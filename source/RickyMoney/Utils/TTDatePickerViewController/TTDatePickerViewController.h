//
//  TTDatePickerViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 10/26/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Implement this protocol to take results from TTDatePickerViewController
 */
@protocol TTDatePickerViewControllerDelegate <NSObject>
/**
 *  This method is called when user touch confrim button.
 *
 *  @param date selected date and time
 */
- (void)ttDatePickerPickedDate:(NSDate *)date;

@end

@interface TTDatePickerViewController : UIViewController

/**
 *  Register your delegate here
 */
@property (nonatomic, weak) id<TTDatePickerViewControllerDelegate> delegate;

/**
 *  Color of interface elements
 */
@property (nonatomic, strong) UIColor *mainColor;
/**
 *  Selected date. 
 * This is the selected date Picker display at the firstime
 * Warning! Don't read selected date from this variable. Use NSDatePickerViewControllerDelegate protocol instead.
 */
@property (nonatomic, strong) NSDate *date;
/**
 *  Minimum avaiable date on picker
 */
@property (nonatomic, strong) NSDate *minDate;
/**
 *  Maximum avaiable date on picker
 */
@property (nonatomic, strong) NSDate *maxDate;
/*
 * DatePicker mode
 */
@property (nonatomic) UIDatePickerMode datePickerMode;
/*
 * Title for picker
 */
@property (nonatomic, strong) NSString *titlePicker;
/**
 *  Title of picker confirm button
 */
@property (nonatomic, strong) NSString *confirmButtonTitle;
/**
 *  Back button title
 */
@property (nonatomic, strong) NSString *cancelButtonTitle;

@end
