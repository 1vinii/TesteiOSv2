//
//  Login.h
//  BankApp
//
//  Created by Vinícius Brito on 24/09/19.
//  Copyright © 2019 Vinícius Brito. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Login : NSObject

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;

- (id)initWithUser:(NSString *)user AndPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
