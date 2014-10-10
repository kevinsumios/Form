//
//  AppDelegate.m

//
//  Created by Elvis Nunez on 03/10/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "AppDelegate.h"

#import "HYPFormsCollectionViewController.h"
#import "HYPFormBackgroundView.h"
#import "HYPFormsLayout.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSDictionary *dictionary = @{ @"address" : @"Burger Park",
                                  @"bank_account_number" : @"11111111111",
                                  @"city" : @"Telemark",
                                  @"email_address" : @"christoffer@hyper.no",
                                  @"end_date" : @"2017-10-31T23:00:00+00:00",
                                  @"first_name" : @"Chris",
                                  @"hours_per_week" : @37,
                                  @"last_name" : @"Winterkvist",
                                  @"phone_number" : @"41399880",
                                  @"postal_code" : @"6414",
                                  @"social_security_number" : @"28118240000",
                                  @"start_date" : @"2014-10-31T23:00:00+00:00",
                                  @"worker_id" : @"120000"
                                  };

    HYPFormsCollectionViewController *controllers = [[HYPFormsCollectionViewController alloc] initWithDictionary:dictionary];

    self.window.rootViewController = controllers;

    [self.window makeKeyAndVisible];

    return YES;
}

@end