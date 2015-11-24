//
//  AFNetworkingViewController.m
//  SSL pinning iOS
//
//  Created by Adis on 12/06/15.
//  Copyright (c) 2015 Infinum Ltd. All rights reserved.
//

#import "AFNetworkingViewController.h"

#import <AFNetworking/AFNetworking.h>

@interface AFNetworkingViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *urlField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UITextView *dataTextView;

@end

@implementation AFNetworkingViewController

#pragma mark - Networking

- (IBAction)fetchData:(id)sender
{
    self.dataTextView.text = @"";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    manager.securityPolicy = policy;

    // optional
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"github.com" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = @[localCertificate];
    
    [self.activityIndicator startAnimating];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:self.urlField.text parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.activityIndicator stopAnimating];
        NSLog(@"Response: %@", responseObject);
        
        self.dataTextView.text = operation.responseString;
        self.dataTextView.textColor = [UIColor darkTextColor];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.activityIndicator stopAnimating];
        NSLog(@"Error: %@", error);
        
        self.dataTextView.text = error.localizedDescription;
        self.dataTextView.textColor = [UIColor redColor];
    }];
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.urlField resignFirstResponder];
    return YES;
}

@end
