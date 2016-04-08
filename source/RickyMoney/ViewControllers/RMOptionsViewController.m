//
//  RMOptionsViewController.m
//  RickyMoney
//
//  Created by Thu Trang on 4/3/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMOptionsViewController.h"
#import "RMParseRequestHandler.h"
#import "RMTransactionController.h"

#import "RMDataManagement.h"
#import "RMObjects.h"

#import <Parse/PFFile.h>
#import <Parse/PFObject.h>

@implementation RMOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    //     self.clearsSelectionOnViewWillAppear = NO;
    
    if (self.option == OPTION_CURRENCY) {
        self.title = @"Currency";
        [self getCurrencyUnit];
    } else {
        self.option = OPTION_CATEGORY;
        self.title = @"Category";
        [self getCategory];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Data

- (void) getCurrencyUnit {
    _optionData = [[RMDataManagement getSharedInstance] getAllCurrency];
    [self.collectionView reloadData];
}

- (void) getCategory {
    _optionData = [[RMDataManagement getSharedInstance] getAllCategory];
    [self.collectionView reloadData];
}

#pragma mark- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = (self.option == OPTION_CURRENCY) ? (collectionView.frame.size.width / 2.0) : (collectionView.frame.size.width / 3.0);
    float height = (self.option == OPTION_CURRENCY) ? (width * 0.7) : (width / 0.8);
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _optionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = (self.option == OPTION_CURRENCY) ? @"currencyCell" : @"categoryCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier forIndexPath:indexPath];
    
    if (self.option == OPTION_CURRENCY) {
        Currency *currency = [self.optionData objectAtIndex:indexPath.row];
        
        ((UIImageView*)[cell viewWithTag:1]).image = [UIImage imageWithContentsOfFile:currency.image];
        [(UILabel*)[cell viewWithTag:2] setText: currency.symbol];
        [(UILabel*)[cell viewWithTag:3] setText: currency.name];
        
        cell.layer.borderColor = RM_COLOR.CGColor;
        cell.layer.borderWidth = 0.5f;
        
    } else {
        Category *category = [_optionData objectAtIndex:indexPath.row];
        
        UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
        icon.image = [UIImage imageWithContentsOfFile: category.icon];
        
        UILabel *categoryName = (UILabel*) [cell viewWithTag:2];
        categoryName.text = category.enName;
    }
    
    return cell;
}

#pragma mark- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedData = _optionData[indexPath.row];
    
    if (self.delegate != nil) {
        [self.delegate optionViewsDoneWithSelectedData:selectedData];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        RMTransactionController *transactionsVC = (RMTransactionController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"TransactionsVC"];
        transactionsVC.categoryId = selectedData.objectId;
        [self.navigationController pushViewController: transactionsVC animated: YES];
    }
    
}

@end
