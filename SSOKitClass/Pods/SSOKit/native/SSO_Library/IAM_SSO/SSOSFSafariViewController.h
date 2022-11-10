//
//  SSOSFSafariViewController.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 16/03/17.
//
//

#import <UIKit/UIKit.h>
#include "SSORequestBlocks+Internal.h"
#if !TARGET_OS_WATCH
#import <WebKit/WebKit.h>

@interface SSOSFSafariViewController : UIViewController

@property requestSuccessBlock success;
@property requestFailureBlock failure;
@property ZSSOKitManageAccountsSuccessHandler switchSuccess;
@property (nonatomic,strong) WKWebView *webkitview;

@end

#endif
