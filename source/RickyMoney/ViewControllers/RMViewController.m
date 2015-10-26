//
//  RMViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 10/26/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "RMViewController.h"
#import "HSDatePickerViewController.h"

@interface RMViewController ()

@end

@implementation RMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)showPickerDate:(id)sender {
//    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
////    hsdpvc.delegate = self;
//    [self presentViewController:hsdpvc animated:YES completion:nil];
    
    UIViewController *hsdpvc = [HSDatePickerViewController new];
    [hsdpvc.view setBackgroundColor:[UIColor yellowColor]];
      [self presentViewController:hsdpvc animated:YES completion:nil];
}

@end
