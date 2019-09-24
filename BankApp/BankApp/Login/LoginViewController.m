//
//  LoginViewController.m
//  BankApp
//
//  Created by Vinícius Brito on 23/09/19.
//  Copyright © 2019 Vinícius Brito. All rights reserved.
//

#import "LoginViewController.h"
#import "Login.h"
#import <AFNetworking.h>
#import "MBProgressHUD.h"
#import "DetailViewController.h"

@interface LoginViewController ()

// UI
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

// Data
@property (strong, nonatomic) NSString *agency;
@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSString *bankAccount;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uID;

@end

@implementation LoginViewController

// Navigation
static NSString *mainStoryboard = @"Main";
static NSString *moveToDetails = @"MoveToDetails";
static NSString *detailID = @"DetailStoryboardID";

// API
static NSString *urlAPI = @"https://bank-app-test.herokuapp.com/api/login";

// Messages
static NSString *noUser = @"Sem usuário!";
static NSString *noUserMessage = @"O campo User não pode ser vazio.";
static NSString *noPassword = @"Sem senha!";
static NSString *noPasswordMessage = @"O campo Password não pode ser vazio.";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self roundedButton:_loginButton];
    [self checkPersistence];
}

# pragma mark - Request Methods

- (NSDictionary *)params {
    NSDictionary *params = @{@"user": _userTextField.text,
                             @"password": _passwordTextField.text};
    return params;
}

- (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return manager;
}

- (void)requestAPI {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[self manager] POST:urlAPI parameters:[self params] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self persistWithModel];
        NSDictionary *responseDict = [responseObject valueForKey:@"userAccount"];
        [self getPropertiesForDetailController:responseDict];
        [self performSegueWithIdentifier:moveToDetails sender:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // (Error: %@", error.description);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Algo deu errado :("
                                                                       message:@"Tente novamente em alguns instantes."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       //
                                                   }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

# pragma mark - Utility Methods

- (UIButton *)roundedButton:(UIButton *)btn {
    btn.layer.cornerRadius = 5.0f;
    return btn;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (UIAlertController *)titleForAlert:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   if ([self->_userTextField.text isEqualToString:@""]) {
                                                       [self->_userTextField becomeFirstResponder];
                                                   }
                                                   if ([self->_passwordTextField.text isEqualToString:@""]) {
                                                       [self->_passwordTextField becomeFirstResponder];
                                                   }
                                               }];
    [alert addAction:ok];
    return alert;
}

- (BOOL)isValidPassword:(NSString*)password
{
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.{6,})(?=.*[a-z])(?=.*[A-Z]).*$" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}

- (void)persistWithModel {
    Login *data = [[Login alloc] initWithUser:self->_userTextField.text AndPassword:self->_passwordTextField.text];
    [self persistLoginData:data];
}

- (void)persistLoginData:(Login *)loginData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[loginData valueForKey:@"user"] forKey:@"user"];
    [defaults setObject:[loginData valueForKey:@"password"] forKey:@"password"];
    [defaults synchronize];
}

- (void)checkPersistence {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user = [defaults valueForKey:@"user"];
    NSString *password = [defaults valueForKey:@"password"];
    
    if (user != nil) {
        _userTextField.text = user;
    }
    if (password != nil) {
        _passwordTextField.text = password;
    }
}

- (void)getPropertiesForDetailController:(NSDictionary *)responseDict {
    self->_agency = [responseDict valueForKey:@"agency"];
    self->_balance = [responseDict valueForKey:@"balance"];
    self->_bankAccount = [responseDict valueForKey:@"bankAccount"];
    self->_name = [responseDict valueForKey:@"name"];
    self->_uID = [responseDict valueForKey:@"userId"];
}

# pragma mark - IBActions

- (IBAction)login:(id)sender {
    
    // Check for empty fields
    if ([_userTextField.text isEqualToString:@""] || _userTextField.text.length <= 0) {
        [self presentViewController:[self titleForAlert:noUser andMessage:noUserMessage] animated:YES completion:nil];
    } else if ([_passwordTextField.text isEqualToString:@""] || _passwordTextField.text.length <= 0) {
        [self presentViewController:[self titleForAlert:noPassword andMessage:noPasswordMessage] animated:YES completion:nil];
    } else {
        if(![self isValidPassword:[_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erro de validação!"
                                                                           message:@"O campo Password deve conter ao menos uma letra maiúscula."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self->_passwordTextField becomeFirstResponder];
                                                       }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // string contains capital letter
            NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
            NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                                   characterSetWithCharactersInString:specialCharacterString];
            
            if ([_passwordTextField.text.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
                // string contains special characters
                NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                
                if ([_passwordTextField.text rangeOfCharacterFromSet:numbers].location != NSNotFound) {
                    // string contains numbers
                    // All validation was good, so make the request to the API !
                    
                    [self requestAPI];
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erro de validação!"
                                                                                   message:@"O campo Password deve conter ao menos um caracter alfanumérico."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   [self->_passwordTextField becomeFirstResponder];
                                                               }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erro de validação!"
                                                                               message:@"O campo Password deve conter ao menos um caracter especial."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [self->_passwordTextField becomeFirstResponder];
                                                           }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:moveToDetails]) {
        DetailViewController *detailVC = (DetailViewController *)segue.destinationViewController;
        detailVC.agency = _agency;
        detailVC.balance = _balance;
        detailVC.bankAccount = _bankAccount;
        detailVC.name = _name;
        detailVC.uID = _uID;
    }
}

@end
