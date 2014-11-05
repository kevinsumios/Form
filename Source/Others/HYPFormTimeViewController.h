//
//  HYPFormTimeViewController.h
//  RemaDrifts
//
//  Created by Elvis Nunez on 1/22/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

@import Foundation;
@import UIKit;

@protocol HYPFormTimeViewControllerDelegate;

@interface HYPFormTimeViewController : UIViewController

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, weak) id <HYPFormTimeViewControllerDelegate> delegate;

- (instancetype)initWithDate:(NSDate *)date;

@end

@protocol HYPFormTimeViewControllerDelegate <NSObject>

- (void)timeController:(HYPFormTimeViewController *)timeController didChangedDate:(NSDate *)date;

@end
