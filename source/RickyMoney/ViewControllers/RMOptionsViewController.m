//
//  RMOptionsViewController.m
//  RickyMoney
//
//  Created by Thu Trang on 4/3/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMOptionsViewController.h"
#import "RMParseRequestHandler.h"
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
    } else if (self.option == OPTION_CATEGORY) {
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
    [RMParseRequestHandler getAllCurrencyUnitsWithSuccessBlock:^(NSArray * objects) {
        _optionData = objects;
        [self.collectionView reloadData];
    }];
}

- (void) getCategory {
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [RMParseRequestHandler getDataByQuery:query withSuccessBlock:^(NSArray * objects) {
        _optionData = objects;
        [self.collectionView reloadData];
    }];
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
    
    PFObject *cellData = [self.optionData objectAtIndex:indexPath.row];
    
    if (self.option == OPTION_CURRENCY) {
        // image
        PFFile *imageFile = [cellData objectForKey:@"image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
                [icon setImage:[UIImage imageWithData:data]];
            }
        }];
        
        [(UILabel*)[cell viewWithTag:2] setText:cellData[@"symbol"]];
        [(UILabel*)[cell viewWithTag:3] setText:cellData[@"name"]];
        
        cell.layer.borderColor = RM_COLOR.CGColor;
        cell.layer.borderWidth = 0.5f;
        
    } else {
        // icon
        PFFile *imageFile = [cellData objectForKey:@"icon"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
                [icon setImage:[UIImage imageWithData:data]];
            }
        }];
        // name
        UILabel *categoryName = (UILabel*) [cell viewWithTag:2];
        [categoryName setText:[cellData valueForKey:@"ENName"]];
    }
    
    return cell;
}

#pragma mark- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedData = _optionData[indexPath.row];
    if (self.delegate != nil) {
        [self.delegate optionViewsDoneWithSelectedData:selectedData];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
