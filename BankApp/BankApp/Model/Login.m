//
//  Login.m
//  BankApp
//
//  Created by Vinícius Brito on 24/09/19.
//  Copyright © 2019 Vinícius Brito. All rights reserved.
//

#import "Login.h"

@implementation Login

- (id)initWithUser:(NSString *)user AndPassword:(NSString *)password {
    
    self = [super init];
    
    if (self) {
        self.user = user;
        self.password = password;
    }
    
    return self;
}

@end
