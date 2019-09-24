//
//  DetailViewController.h
//  BankApp
//
//  Created by Vinícius Brito on 24/09/19.
//  Copyright © 2019 Vinícius Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSString *agency;
@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSString *bankAccount;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uID;

@end

NS_ASSUME_NONNULL_END
