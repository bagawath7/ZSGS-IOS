//
//  SSOUserAccountsTableViewController.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 5/10/16.
//  Copyright © 2016 Zoho. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "SSORequestBlocks+Internal.h"

#if !TARGET_OS_WATCH
@interface SSOUserAccountsTableViewController : UIViewController

@property requestSuccessBlock success;
@property requestFailureBlock failure;
@property ZSSOKitManageAccountsSuccessHandler switchSuccess;
@property int count;
@property NSMutableDictionary *userDetailsDictionary;
@property NSString *CurrentUserZUID;
@property BOOL isHavingSSOAccount;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@end
#endif
