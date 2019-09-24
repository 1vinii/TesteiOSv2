//
//  DetailViewController.m
//  BankApp
//
//  Created by Vinícius Brito on 24/09/19.
//  Copyright © 2019 Vinícius Brito. All rights reserved.
//

#import "DetailViewController.h"
#import <AFNetworking.h>
#import "MBProgressHUD.h"
#import "DetailTableCell.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>
//UI
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *agencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankAccountLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableView *DetailTableView;

// Data
@property (strong, nonatomic) NSMutableArray *statementList;

@end

@implementation DetailViewController
@synthesize agency = _agency, balance = _balance, bankAccount = _bankAccount, name = _name, uID = _uID;

static NSString *urlAPI = @"https://bank-app-test.herokuapp.com/api/statements/";
static NSString *detailCellIdentifier = @"DetailTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fillFieldsWithPropertiesFromPreviousController];
    [self loadDataWithuID:_uID];
}

# pragma mark - IBActions

- (IBAction)logout:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Request Methods

- (void)loadDataWithuID:(NSString *)uID {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlWithuID = [NSString stringWithFormat:@"%@%@", urlAPI, uID];
    [[self manager] GET:urlWithuID parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        self->_statementList = [json objectForKey:@"statementList"];
        [self->_DetailTableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Algo deu errado :("
                                                                       message:@"Não foi possível carregar os dados neste momento."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Tentar novamente"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self loadDataWithuID:self->_uID];
                                                   }];
        [alert addAction:tryAgain];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@"charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    return manager;
}

# pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _statementList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailTableCell *cell = (DetailTableCell *)[tableView dequeueReusableCellWithIdentifier:detailCellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DetailTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.titleLabel.text = [[_statementList valueForKey:@"title"] objectAtIndex:indexPath.row];
    cell.descLabel.text = [[_statementList valueForKey:@"desc"] objectAtIndex:indexPath.row];
    cell.dateLabel.text = [[_statementList valueForKey:@"date"] objectAtIndex:indexPath.row];
    cell.valueLabel.text = [NSString stringWithFormat:@"R$%@", [[_statementList valueForKey:@"value"] objectAtIndex:indexPath.row]];
    
    return cell;
}

# pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Recentes";
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView * headerview = (UITableViewHeaderFooterView *)view;
    headerview.contentView.backgroundColor = [UIColor whiteColor];
    headerview.textLabel.textColor = [UIColor darkGrayColor];
}

# pragma mark - Utility Methods

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)fillFieldsWithPropertiesFromPreviousController {
    _nameLabel.text = _name;
    _agencyLabel.text = [NSString stringWithFormat:@"%@ /", _bankAccount];
    _bankAccountLabel.text = _agency;
    _balanceLabel.text = [NSString stringWithFormat:@"R$%@", _balance];
}

@end
