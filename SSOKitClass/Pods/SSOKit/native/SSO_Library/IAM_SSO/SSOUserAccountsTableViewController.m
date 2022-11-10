//
//  SSOUserAccountsTableViewController.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 5/10/16.
//  Copyright © 2016 Zoho. All rights reserved.
//
#if !TARGET_OS_WATCH
#import "SSOUserAccountsTableViewController.h"
#include "ZIAMUtil.h"
#include "ZIAMUtilConstants.h"
#include "SSONetworkManager.h"
#include "SSOSFSafariViewController.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"

@interface SSOUserAccountsTableViewController ()
{
    UIBarButtonItem *closebarButtonItem;
    UIBarButtonItem *managebarButtonItem;
    UIBarButtonItem *cancelbarButtonItem;
    UIBarButtonItem *managebarButtonItemLeftTitle;
    UIBarButtonItem *closerightbarButtonItem;
    UIBarButtonItem *titleLeftbarButtonItem;
    UILabel* lbNavTitle;
    
    NSString *sendData;
    NSData *postData;
    NSString *postLength;
    NSData *responseData;
    NSMutableURLRequest *request;
    NSMutableURLRequest *oauth_request;
    NSDictionary *ResponseDictionary;
    NSDictionary *ResponseProfileInfoDictionary;
    int rows;
    
    UITableViewCell *AddCell;
    UITableViewCell *CurrentUserCell;
    BOOL ManageClicked;
    
    UILabel *loadingText;
    UIView *loadingviewFrame;
    UIView *blockingView;
#if !SSO_APP__EXTENSION_API_ONLY
    UIActivityIndicatorView *loadingActivityView;
#endif
}
@end

@implementation SSOUserAccountsTableViewController
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        [self.view setBackgroundColor:[UIColor colorNamed:@"System Background Color"]];
    }
    [ZIAMUtil sharedUtil]->ButtonClick = NO;
    lbNavTitle= [[UILabel alloc] initWithFrame:CGRectMake(0,0,90,40)];
    lbNavTitle.textAlignment = NSTextAlignmentCenter;
    lbNavTitle.textColor = [UIColor whiteColor];
    lbNavTitle.text = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.manage" Comment:@"Manage"];
    lbNavTitle.font = [UIFont fontWithName:@"SanFranciscoDisplay-Bold" size:14];
    //self.navigationItem.titleView = lbNavTitle;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //navigation bar buttons
    if(_count!=0){
        managebarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.manage" Comment:@"Manage"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleManage)];
        
        self.navigationItem.rightBarButtonItem = managebarButtonItem;
        
    }
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage;
//    closeImage = [UIImage imageNamed:@"ssokit_close"];
//    if(!closeImage){
        closeImage = [UIImage imageNamed:@"ssokit_close" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
    //}
    [button setImage:closeImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toggleClose)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 50, 20)];
    [label setFont:[UIFont fontWithName:@"SanFranciscoDisplay-Bold" size:20]];
    [label setText:[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.select" Comment:@"Select"]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    // navigation bar appearance
    UIColor *barTintColor = [UIColor colorWithRed:65.0f/255.0 green:131.0f/255.0 blue:215.0f/255.0 alpha:1.0 ];
    if (@available(iOS 12.0, *)) {
        if(self.view.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            barTintColor = [UIColor colorWithRed:19.0f/255.0 green:19.0f/255.0 blue:20.0f/255.0 alpha:1.0 ];
        }
    }
   
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = barTintColor;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = self.navigationController.navigationBar.standardAppearance;
    } else {
        self.navigationController.navigationBar.barTintColor = barTintColor;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    //blocking view
    blockingView = [[UIView alloc] initWithFrame:self.view.bounds];
    blockingView.userInteractionEnabled = NO;
    if (@available(iOS 11.0, *)) {
        blockingView.backgroundColor = [UIColor colorNamed:@"System Background Color"];
    }
    blockingView.hidden = YES;
    
    [self.view addSubview:blockingView];
    
    loadingviewFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    loadingviewFrame.center = CGPointMake(self.view.center.x,self.view.center.y);
    loadingviewFrame.layer.cornerRadius = 10;
    loadingviewFrame.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    loadingviewFrame.hidden = YES;
    
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:90];
    
    
    
    [self.view addSubview:loadingviewFrame];
    loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
    
    
    [self.view addConstraint:centerX];
    [self.view addConstraint:centerY];
    [loadingviewFrame addConstraint:width];
    [loadingviewFrame addConstraint:height];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
#if !SSO_APP__EXTENSION_API_ONLY
    loadingActivityView = [[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingActivityView.frame = loadingviewFrame.bounds;
    loadingActivityView.hidden = NO;
    [loadingviewFrame addSubview:loadingActivityView];
#endif
    loadingText= [[UILabel alloc]initWithFrame:loadingviewFrame.frame];
    loadingText.hidden = NO;
    loadingText.text =  [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.loading" Comment:@"Loading..."];
    loadingText.textColor = [UIColor whiteColor];
    loadingText.backgroundColor = [UIColor clearColor];
    loadingText.textAlignment = NSTextAlignmentCenter;
    loadingText.font = [UIFont fontWithName:@"Helvetica" size:16];
    loadingText.center = CGPointMake(loadingviewFrame.frame.size.width/2, (loadingviewFrame.frame.size.height/2)+30);
    [loadingviewFrame addSubview:loadingText];
    [self.view addSubview:loadingviewFrame];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

-(void)showLoading{
    if ([ZIAMUtil sharedUtil]->showProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->showProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
#if !SSO_APP__EXTENSION_API_ONLY
            self->blockingView.hidden = NO;
            self.navigationController.navigationBarHidden = YES;
            self.tableView.hidden = YES;
            [self->loadingActivityView startAnimating];
#endif
            self->loadingviewFrame.hidden = NO;
        });
    }
}

-(void)hideLoading{
    if ([ZIAMUtil sharedUtil]->endProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->endProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
#if !SSO_APP__EXTENSION_API_ONLY
            self->blockingView.hidden = YES;
            self.navigationController.navigationBarHidden = NO;
            self.tableView.hidden = NO;
            [self->loadingActivityView stopAnimating];
#endif
            self->loadingviewFrame.hidden = YES;
        });
    }
}

-(void)toggleClose{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self dismissViewControllerAnimated:YES completion:^{
        NSError *returnError;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Account Chooser Dismissed" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAccountChooserDismissedError userInfo:userInfo];
        self->_failure(returnError);
        return;
    }];
    });
}

-(void)toggleManage{
    dispatch_async(dispatch_get_main_queue(), ^{
    if(self.tableView.editing){
        [self toggleManageDismiss];
    }
    
        self->ManageClicked = YES;
    
        self->AddCell.hidden = YES;
        if(self->CurrentUserCell){
            UIImageView *selectedImageView = (UIImageView *)[self->CurrentUserCell.contentView viewWithTag:3];
        selectedImageView.hidden = YES;
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.navigationItem.titleView = nil;
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
        self->closerightbarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.close" Comment:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleManageDismiss)];
        self->managebarButtonItemLeftTitle = [[UIBarButtonItem alloc] initWithTitle:[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.manage" Comment:@"Manage"] style:UIBarButtonItemStylePlain target:self action:nil];
        self.navigationItem.leftBarButtonItem = self->managebarButtonItemLeftTitle;
        self.navigationItem.rightBarButtonItem = self->closerightbarButtonItem;
    });
}

-(void)toggleManageDismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->ManageClicked = NO;
        self->AddCell.hidden = NO;
        if(self->CurrentUserCell){
            UIImageView *selectedImageView = (UIImageView *)[self->CurrentUserCell.contentView viewWithTag:3];
        selectedImageView.hidden = NO;
    }
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
        if(self->_count != 0){
            self.navigationItem.rightBarButtonItem = self->managebarButtonItem;
        
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage;
//    closeImage = [UIImage imageNamed:@"ssokit_close"];
//    if(!closeImage){
        closeImage = [UIImage imageNamed:@"ssokit_close" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
    //}
    [button setImage:closeImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toggleClose)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 50, 20)];
    [label setFont:[UIFont fontWithName:@"SanFranciscoDisplay-Bold" size:20]];
    [label setText:[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.select" Comment:@"Select"]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    });
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _count+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 64;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.row < _count) && (_count!=0 )){
        DLog(@"User Account: %ld",(long)indexPath.row);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"useraccountcell" forIndexPath:indexPath];
        NSString *ZUID;
        UIImageView *profilePhotoImageView = (UIImageView *)[cell.contentView viewWithTag:4];
        UIImageView *selectedImageView = (UIImageView *)[cell.contentView viewWithTag:3];
        selectedImageView.image = [UIImage imageNamed:@"ssokit_selected" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        UILabel *displayNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *emailidLabel = (UILabel *)[cell.contentView viewWithTag:2];
        if(_isHavingSSOAccount){
            
            
            if(indexPath.row == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    CAGradientLayer *gradient = [CAGradientLayer layer];
                    profilePhotoImageView.clipsToBounds = true;
                    gradient.frame = profilePhotoImageView.bounds;
                    
                    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.32 green:0.93 blue:0.78 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0] CGColor], nil];
                    
                    gradient.startPoint = CGPointMake(0.0, 0.0);
                    
                    gradient.endPoint = CGPointMake(1, 1);
                    
                    CAShapeLayer *shapeLayer =[[CAShapeLayer alloc] init];
                    
                    shapeLayer.lineWidth = 2; // higher number higher border width
                    
                    shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake((profilePhotoImageView.frame.size.width/2),(profilePhotoImageView.frame.size.width/2)) radius:(profilePhotoImageView.frame.size.width/2) startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
                    
                    //shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:cell.profilePhotoImageView.frame cornerRadius:22].CGPath;
                    
                    
                    shapeLayer.fillColor = nil;
                    
                    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
                    
                    gradient.mask = shapeLayer;
                    
                    [profilePhotoImageView.layer addSublayer:gradient];
                    
                    
                    //cell.profilePhotoImageView.layer.borderWidth = 1;
                    // cell.profilePhotoImageView.layer.borderColor = [UIColor colorWithRed:1.00 green:0.16 blue:0.41 alpha:1.0].CGColor;
                   
                    NSString *SSO_Zuid =[[ZIAMUtil sharedUtil] getSSOZUIDFromSharedKeychain];
                    NSMutableDictionary *SSOUserDetailsDictionary  = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:[[ZIAMUtil sharedUtil] getSSOUserDetailsDataFromSharedKeychain]];
                    
                    NSArray *userdetailsArray = [SSOUserDetailsDictionary objectForKey:SSO_Zuid];
                    
                    displayNameLabel.text = [userdetailsArray objectAtIndex:0];
                    emailidLabel.text = [userdetailsArray objectAtIndex:1];
                    
                    //Temp fix for App Store OneAuth UserDetails...
                    NSData *profileImageData = [userdetailsArray objectAtIndex:2];
                    if(![profileImageData isEqual:[NSNull null]] && [[userdetailsArray objectAtIndex:2] isKindOfClass:[NSData class]]){
                        profilePhotoImageView.image = [UIImage imageWithData:profileImageData];
                    }else if([[userdetailsArray objectAtIndex:2] isKindOfClass:[UIImage class]]){
                        profilePhotoImageView.image = [userdetailsArray objectAtIndex:2];
                    }else{
                        UIImage *avatarImage;
//                        avatarImage = [UIImage imageNamed:@"ssokit_avatar"];
//                        if(!avatarImage){
                            avatarImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
                       // }
                        profilePhotoImageView.image = avatarImage;
                    }
                    [profilePhotoImageView setNeedsLayout];
                    [profilePhotoImageView layoutIfNeeded];
                    profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.width/2;
                    profilePhotoImageView.layer.masksToBounds = YES;
                    if([SSO_Zuid isEqualToString:self->_CurrentUserZUID]){
                        selectedImageView.hidden = NO;
                        self->CurrentUserCell = cell;
                    }else{
                        selectedImageView.hidden = YES;
                    }
                });
                
            }else{
                ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:(int)indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *userdetailsArray = [self->_userDetailsDictionary objectForKey:ZUID];
                
                    displayNameLabel.text = [userdetailsArray objectAtIndex:0];
                    emailidLabel.text = [userdetailsArray objectAtIndex:1];
                    NSData *profileImageData = [userdetailsArray objectAtIndex:2];
                    if(![profileImageData isEqual:[NSNull null]]){
                        profilePhotoImageView.image = [UIImage imageWithData:profileImageData];
                    }else{
                        UIImage *avatarImage;
//                        avatarImage = [UIImage imageNamed:@"ssokit_avatar"];
//                        if(!avatarImage){
                            avatarImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
                        //}
                        profilePhotoImageView.image = avatarImage;
                    }
                    [profilePhotoImageView setNeedsLayout];
                    [profilePhotoImageView layoutIfNeeded];
                    profilePhotoImageView.layer.cornerRadius = 22;
                    profilePhotoImageView.layer.masksToBounds = YES;
                    if([ZUID isEqualToString:self->_CurrentUserZUID]){
                        selectedImageView.hidden = NO;
                        self->CurrentUserCell = cell;
                    }else{
                        selectedImageView.hidden = YES;
                    }
                });
            }
            
        }else{
            ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:(int)indexPath.row+1];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *userdetailsArray = [self->_userDetailsDictionary objectForKey:ZUID];
            
                displayNameLabel.text = [userdetailsArray objectAtIndex:0];
                emailidLabel.text = [userdetailsArray objectAtIndex:1];
                NSData *profileImageData = [userdetailsArray objectAtIndex:2];
                if(![profileImageData isEqual:[NSNull null]]){
                        profilePhotoImageView.image = [UIImage imageWithData:profileImageData];
                }else{
                    UIImage *avatarImage;
//                    avatarImage = [UIImage imageNamed:@"ssokit_avatar"];
//                    if(!avatarImage){
                        avatarImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
                    //}
                    profilePhotoImageView.image = avatarImage;
                }
                [profilePhotoImageView setNeedsLayout];
                [profilePhotoImageView layoutIfNeeded];
                profilePhotoImageView.layer.cornerRadius = 22;
                profilePhotoImageView.layer.masksToBounds = YES;
                if([ZUID isEqualToString:self->_CurrentUserZUID]){
                    selectedImageView.hidden = NO;
                    self->CurrentUserCell = cell;
                }else{
                    selectedImageView.hidden = YES;
                }
            });
        }
        
       return cell;       
    }else{
        DLog(@"Add Account: %ld",(long)indexPath.row);
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addaccountcell" forIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *addAccountLabel = (UILabel *)[cell.contentView viewWithTag:5];
        addAccountLabel.text = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.addaccount" Comment:@"Add Account"];
        UIImageView *addAccountImageView = (UIImageView *)[cell.contentView viewWithTag:3];
        addAccountImageView.image = [UIImage imageNamed:@"ssokit_add" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
            self->AddCell=cell;
        });
        return cell;
    }

}

-(void)dismissWithSuccessHavingAccessToken:(NSString *)token{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self->_success(token);
        }];
    });
}

-(void)dismissWithSuccessHavingAccessToken:(NSString *)token andSwitch:(BOOL)switched{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self->_switchSuccess(token,switched,[[ZIAMUtil sharedUtil]getCurrentUser]);
        }];
    });
}

-(void)dismissWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self->_failure(error);
        }];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _count){
        NSString *ZUID;
        BOOL isSSOFetch = NO;
        if(_isHavingSSOAccount){
            if(indexPath.row == 0){
                ZUID =[[ZIAMUtil sharedUtil] getSSOZUIDFromSharedKeychain];
                if(!ZUID){
                    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
                    [userInfo setValue:@"No user found" forKey:NSLocalizedDescriptionKey];
                    NSError *error = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONoUsersFound userInfo:userInfo];
                    [self dismissWithError:error];
                    return;
                }
                isSSOFetch = YES;
                if([[ZIAMUtil sharedUtil]->Service isEqualToString:kDevelopment_BundleID] || [[ZIAMUtil sharedUtil]->Service isEqualToString:kMDM_BundleID]){
                    [[ZIAMUtil sharedUtil] setisAppUsingSSOAccount];
                }else if([[ZIAMUtil sharedUtil]->Service isEqualToString:kDevelopment_MyZoho_BundleID] || [[ZIAMUtil sharedUtil]->Service isEqualToString:kMDM_MyZoho_BundleID]){
                    [[ZIAMUtil sharedUtil] setisAppUsingMyZohoSSOAccount];
                }
                
            }else{
                [[ZIAMUtil sharedUtil] removeisAppUsingSSOAccount];
                ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:(int)indexPath.row];
            }
        }else{
            [[ZIAMUtil sharedUtil] removeisAppUsingSSOAccount];
            ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:(int)indexPath.row+1];
        }
        
        if([ZUID isEqualToString:_CurrentUserZUID]){
            [self showLoading];
            if(isSSOFetch){
                [[ZIAMUtil sharedUtil]getSSOForceFetchOAuthTokenWithSuccess:^(NSString *token) {
                    [self hideLoading];
                    if(self->_success){
                        [self dismissWithSuccessHavingAccessToken:token];
                    }else if(self->_switchSuccess){
                        [self dismissWithSuccessHavingAccessToken:token andSwitch:NO];
                    }
                } andFailure:^(NSError *error) {
                    [self hideLoading];
                    if ([[error localizedDescription] isEqualToString:@"invalid_mobile_code"]) {
                        [self showLoginScreen];
                    } else {
                        [self dismissWithError:error];
                    }
                }];
            }else{
                [[ZIAMUtil sharedUtil]getForceFetchOAuthTokenForZUID:ZUID success:^(NSString *token) {
                    [self hideLoading];
                    if(self->_success){
                        [self dismissWithSuccessHavingAccessToken:token];
                    }else if(self->_switchSuccess){
                        [self dismissWithSuccessHavingAccessToken:token andSwitch:NO];
                    }
                } andFailure:^(NSError *error) {
                    [self hideLoading];
                    [self dismissWithError:error];
                }];
            }
            
        }else{
            [self showLoading];
            if(isSSOFetch){
                [[ZIAMUtil sharedUtil]getSSOForceFetchOAuthTokenWithSuccess:^(NSString *token) {
                    [self hideLoading];
                    [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:ZUID];
                    if(self->_success){
                        [self dismissWithSuccessHavingAccessToken:token];
                    }else if(self->_switchSuccess){
                        [self dismissWithSuccessHavingAccessToken:token andSwitch:YES];
                    }
                } andFailure:^(NSError *error) {
                    [self hideLoading];
                    if ([[error localizedDescription] isEqualToString:@"invalid_mobile_code"]) {
                        [self showLoginScreen];
                    } else {
                        [self dismissWithError:error];
                    }
                }];
            }else{
                [[ZIAMUtil sharedUtil]getForceFetchOAuthTokenForZUID:ZUID success:^(NSString *token) {
                    [self hideLoading];
                    [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:ZUID];
                    if(self->_success){
                        [self dismissWithSuccessHavingAccessToken:token];
                    }else if(self->_switchSuccess){
                        [self dismissWithSuccessHavingAccessToken:token andSwitch:YES];
                    }
                } andFailure:^(NSError *error) {
                    [self hideLoading];
                    [self dismissWithError:error];
                }];
            }
            
        }
    }else{
        [self showLoginScreen];
    }
}

-(void) showLoginScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[ZIAMUtil sharedUtil] checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:self->_success andFailure:self->_failure switchSuccess:self->_switchSuccess];
        }];
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if(indexPath.row < _count){
                return YES;
    }else{
        return NO;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_isHavingSSOAccount && indexPath.row == 0){
        if([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthMDMURLScheme] ){
            return [NSString stringWithFormat:@"%@ OneAuth",[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.open" Comment:@"Open"]];
        }else if ([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoMDMURLScheme] ){
            return [NSString stringWithFormat:@"%@ MyZoho",[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.open" Comment:@"Open"]];
        }else{
            return [NSString stringWithFormat:@"%@ App",[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.open" Comment:@"Open"]];
        }
        
    }else{
        return [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.remove" Comment:@"Remove"];
    }
    
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if(_isHavingSSOAccount && indexPath.row == 0){
            //Open OneAuth
            if([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthMDMURLScheme] ){
                [[ZIAMUtil sharedUtil] isOneAuthInstalled:^(BOOL isValid) {
                    if(isValid){
                        #if !SSO_APP__EXTENSION_API_ONLY
                        [ZIAMUtil sharedUtil]->setFailureBlock = self->_failure;
                        [ZIAMUtil sharedUtil]->setSuccessBlock = self->_success;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?purpose=signout&scheme=%@&appname=%@",[ZIAMUtil sharedUtil]->IAMURLScheme,[ZIAMUtil sharedUtil]->UrlScheme,[ZIAMUtil sharedUtil]->AppName]]];
                        });
                        #endif
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }else{
                        #if !SSO_APP__EXTENSION_API_ONLY
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/zoho-oneauth/id1142928979?mt=8"]];
                        });
                        #endif
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }
                }];
            }else if([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoMDMURLScheme] ){
                [[ZIAMUtil sharedUtil] isMyZohoInstalled:^(BOOL isValid) {
                    if(isValid){
                        #if !SSO_APP__EXTENSION_API_ONLY
                        [ZIAMUtil sharedUtil]->setFailureBlock = self->_failure;
                        [ZIAMUtil sharedUtil]->setSuccessBlock = self->_success;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?purpose=signout&scheme=%@&appname=%@",[ZIAMUtil sharedUtil]->IAMURLScheme,[ZIAMUtil sharedUtil]->UrlScheme,[ZIAMUtil sharedUtil]->AppName]]];
                        });
                        #endif
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }else{
                        #if !SSO_APP__EXTENSION_API_ONLY
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //To Do: Add MyZoho AppStore URL
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
                        });
                        #endif
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }
                }];
            }
           
            
        }else{
            //add code here for when you hit delete
            NSString *ZUID;
            if(_isHavingSSOAccount){
               ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:(int)indexPath.row];

            }else{
                ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:(int)indexPath.row+1];
            }
            [self revokeRefreshToken:[[ZIAMUtil sharedUtil] getRefreshTokenFromKeychainForZUID:ZUID] forZUID:ZUID forRowAtIndexPath:indexPath];
        }
    }
}

-(void)revokeRefreshToken:(NSString *)refreshToken forZUID:(NSString *)zuid forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *cellblockingView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    // background view that blocks the taps from the user when network is not available
    cellblockingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    cellblockingView.hidden = YES;
    
    #if !SSO_APP__EXTENSION_API_ONLY
    UIActivityIndicatorView *cellactivityView = [[UIActivityIndicatorView alloc]
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    cellactivityView.color = [UIColor whiteColor];
    
    
    //cellactivityView.center = CGPointMake(cell.contentView.frame.size.width+20,cell.contentView.center.y);
    cellactivityView.center = CGPointMake(cell.contentView.center.x,cell.contentView.center.y);
    [cellblockingView addSubview:cellactivityView];
    #endif
    
    UILabel *errormsgLabel = [[UILabel alloc]initWithFrame:cell.contentView.frame];
    errormsgLabel.textAlignment = NSTextAlignmentCenter;
    errormsgLabel.textColor = [UIColor whiteColor];
    errormsgLabel.font = [UIFont fontWithName:@"SanFranciscoDisplay-Regular" size:18];
    
    
    
    
    
    [cellblockingView addSubview:errormsgLabel];
    [cell.contentView addSubview:cellblockingView];
    
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[[ZIAMUtil sharedUtil] getAccountsURLFromKeychainForZUID:zuid],kSSORevoke_URL];
    
    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",refreshToken] forKey:@"token"];
    
    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:[[ZIAMUtil sharedUtil] getUserAgentString] forKey:@"User-Agent"];
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    #if !SSO_APP__EXTENSION_API_ONLY
        [cellactivityView startAnimating];
    #endif
    cellblockingView.hidden = NO;
    });
    
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                         parameters: paramsAndHeaders
                                       successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               #if !SSO_APP__EXTENSION_API_ONLY
                                                    [cellactivityView stopAnimating];
                                               #endif
                                               cellblockingView.hidden = YES;
                                            });
                                           
                                           //Request success
                                           
                                           [self->_userDetailsDictionary removeObjectForKey:zuid];
                                           
                                           NSData *userDetailsdictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:self->_userDetailsDictionary];
                                           [[ZIAMUtil sharedUtil] setUserDetailsDataInKeychain:userDetailsdictionaryRep];
                                           
                                           
                                           int i;
                                           int deletedIndex = (int)indexPath.row;
                                           if(!self->_isHavingSSOAccount){
                                               deletedIndex = deletedIndex+1;
                                           }
                                           for (i=deletedIndex; i<=[self->_userDetailsDictionary count]; i++) {
                                               NSString *ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:i+1];
                                               [[ZIAMUtil sharedUtil] setZUIDInKeyChain:ZUID atIndex:i];
                                           }
                                           
                                           [[ZIAMUtil sharedUtil] removeZUIDFromKeyChainatIndex:(int)[self->_userDetailsDictionary count]+1];
                                           
                                           if([zuid isEqualToString:self->_CurrentUserZUID]){
                                               
                                               [[ZIAMUtil sharedUtil] removeCurrentUserZUIDFromKeychain];
                                               NSString *U0_ZUID;
                                               if(!self->_isHavingSSOAccount){
                                                   U0_ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:1];
                                               }else{
                                                   U0_ZUID = [[ZIAMUtil sharedUtil] getSSOZUIDFromSharedKeychain];
                                               }
                                               
                                               if(U0_ZUID!= nil){
                                                   [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:U0_ZUID];
                                               }else{
                                                   int errorCode = k_SSONoUsersFound;
                                                   NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                   [userInfo setValue:@"No Users Found" forKey:NSLocalizedDescriptionKey];
                                                   NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorCode userInfo:userInfo];
                                                   [self dismissViewControllerAnimated:YES completion:^{
                                                       self->_failure(returnError);
                                                   }];
                                                   return;
                                               }
                                               
                                           }
                                           if(self->ManageClicked){
                                               [self toggleManageDismiss ];
                                           }
                                           
                                           self->_count = self->_count-1;
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self->tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                                               [self.tableView reloadData];
                                           });
                                        

                                       } failureBlock:^(SSOInternalError errorType, id errorInfo) {
                                           //Request failed
                                           cellblockingView.hidden = NO;
                                           if(errorType == SSO_ERR_CONNECTION_FAILED || errorType == SSO_ERR_NOTHING_WAS_RECEIVED){
                                               NSError *error = (NSError *)errorInfo;
                                               errormsgLabel.text = error.localizedDescription ;
                                           }else{
                                               errormsgLabel.text = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.somethingwentwrong" Comment:@"Something went wrong"];
                                           }
                                           
                                           double delayInSeconds = 5.0;
                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                               #if !SSO_APP__EXTENSION_API_ONLY
                                                [cellactivityView stopAnimating];
                                               #endif
                                               cellblockingView.hidden = YES;
                                           });
                                           DLog(@"Revoke refresh token error:%ld",(long)errorType);
                                       }];
    
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
#endif
