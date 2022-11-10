//
//  SSOSFSafariLoginViewController.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 16/03/17.
//
//

#if !TARGET_OS_WATCH
#import "SSOSFSafariViewController.h"

#if !TARGET_OS_WATCH && !TARGET_OS_UIKITFORMAC
#import <SafariServices/SafariServices.h>
#import <QuartzCore/QuartzCore.h>
#endif
#if !SSOKit_DoNotUseXcode11
#import "AuthenticationServices/AuthenticationServices.h"
#endif
#include "SSOKeyPairUtil.h"
#include "NSData+Base64.h"
#include "SSO_NSData+AES.h"
#include "ZIAMUtil.h"
#include "ZIAMUtilConstants.h"
#import "SSONetworkManager.h"
#include "ZSSOProfileData+Internal.h"
#include "ZSSOUser+Internal.h"
#include "ZIAMUtilConstants.h"
#include "ZIAMHelpers.h"
#include "ZIAMKeyChainUtil.h"
#include "SSOKeyChainWrapper.h"

#if TARGET_OS_WATCH && !TARGET_OS_UIKITFORMAC
@import WatchKit;
#endif

#if TARGET_OS_UIKITFORMAC || SSOKit_DoNotUseXcode11
@interface SSOSFSafariViewController ()<UINavigationControllerDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate>
#else
@interface SSOSFSafariViewController ()<SFSafariViewControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate,ASWebAuthenticationPresentationContextProviding>
#endif
{
    BOOL DoneButtonClicked;
    
    NSString*                   gt_hash;
    
    NSString*                   gt_sec;
    NSString*                   code;
    
    NSString* refresh_token;
    NSString* access_token;
    NSString* expires_in;
    
    NSString *dcl_prefix;
    NSData *Bas64DCL_Meta_Data;
    
    NSString *accountsServer;
    NSString *location;
    
    NSString *contactBaseURL;
#if !TARGET_OS_UIKITFORMAC
    SFSafariViewController *safariVC API_AVAILABLE(ios(9.0));
    SFAuthenticationSession *sfAuthsession API_AVAILABLE(ios(11.0));
#endif
    NSDictionary* profileInfoDict;
    NSString *transformedContactsURL;
    
    BOOL isSFSafariDisplayed;
    
    BOOL isNotificationReceived;
    
    BOOL zohodc;
    BOOL isChineseLocale;
    UILabel *loadingText;
    UIView *loadingviewFrame;
    UINavigationController *navigationController;
#if !SSO_APP__EXTENSION_API_ONLY
    UIActivityIndicatorView *loadingActivityView;
    
#endif
    ASWebAuthenticationSession *asWebAuthsession API_AVAILABLE(ios(12.0));
    NSString *mdmToken;
    
}
@property (nonatomic, retain) UIPopoverController *popupObject;
@end

@implementation SSOSFSafariViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DoneButtonClicked = NO;
    isNotificationReceived = NO;
    zohodc = YES;
    isChineseLocale = [[ZIAMUtil sharedUtil] isChineseLocale];
    loadingviewFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    loadingviewFrame.center = CGPointMake(self.view.center.x,self.view.center.y);
    
    //LoadingView Constraints
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
    
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"sfsafariredirection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(oauthpost:)
                                                 name:@"sfsafariredirection" object:nil];
    
    
    // Do any additional setup after loading the view.
  
    loadingviewFrame.layer.cornerRadius = 10;
    loadingviewFrame.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    loadingviewFrame.hidden = YES;
    
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
    loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
    
    
    [self.view addConstraint:centerX];
    [self.view addConstraint:centerY];
    [loadingviewFrame addConstraint:width];
    [loadingviewFrame addConstraint:height];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

}

-(WKWebView*) webkitview{
    if(_webkitview == nil )
    {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *controller = [[WKUserContentController alloc] init];
        config.userContentController = controller;
        _webkitview = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
        _webkitview.navigationDelegate = self;
    }
    return _webkitview;
}

-(void)checkAndUpdateDeviceDetails:(NSDictionary *)newDetails{
    if([SSOKeyChainWrapper valueForKey:kSSODeviceDetails_KEY]){
        NSMutableDictionary *oldDetails = [[NSMutableDictionary alloc]init];
        oldDetails = [SSOKeyChainWrapper valueForKey:kSSODeviceDetails_KEY];
        if(![oldDetails isEqualToDictionary:newDetails]){
            [self updateNewDeviceDetailsInServer];
        }

    }

}

-(void)updateNewDeviceDetailsInServer{
    // <AccountsUrl>/oauth/device/modify?deviceDetails=URLENCODED(JSON(deviceId, deviceName, deviceModel))
//    NSString *urlString;
//    NSString *accountsbaseURL = [ZIAMUtil sharedUtil]->BaseUrl;
//    NSMutableDictionary *appVerifyJson = [[NSMutableDictionary alloc]init];
//    [appVerifyJson setValue:[[UIDevice currentDevice] name] forKey:@"deviceName"];
//    [appVerifyJson setValue:[[ZIAMUtil sharedUtil]deviceName ] forKey:@"deviceModel"];
//
//    if([SSOKeyChainWrapper stringForKey:kSSODeviceID_KEY]){
//        [appVerifyJson setValue:[SSOKeyChainWrapper stringForKey:kSSODeviceID_KEY] forKey:@"deviceId"];
//
//    }
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:appVerifyJson options:NSJSONWritingPrettyPrinted error:&error];
//    urlString = [NSString stringWithFormat:@"%@%@?deviceDetails=%@",accountsbaseURL,kSSOUpdateDeviceDetails_URL,[NSString stringWithUTF8String:[jsonData bytes]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!DoneButtonClicked && !isSFSafariDisplayed){
        [self displaySafari];
    }else{
        [self dismissReturningError];
    }
}

-(void)dismissReturningError{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->DoneButtonClicked){
            [self dismissViewControllerAnimated:NO completion:^{
                if([ZIAMUtil sharedUtil]->ScopeEnhancementUrl){
                    //Return Failure callback for ScopeEnhancement...
                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"Scope Enhancement Dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementDismissedError userInfo:userInfo];
                    
                    self->_failure(returnError);
                    return;
                }else if([ZIAMUtil sharedUtil]->UnconfirmedUserURL){
                    //Return Failure callback for UnconfirmedUser...
                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"User Email Confirmation Dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUserConfirmationDismissedError userInfo:userInfo];
                    
                    self->_failure(returnError);
                    return;
                }else if([ZIAMUtil sharedUtil]->OneAuthTokenActivationURL){
                    //Return Failure callback for InactiveRerfeshToken...
                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"Inactive RefreshToken Activation Dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenActivationDismissedError userInfo:userInfo];
                    
                    self->_failure(returnError);
                    return;
                }else if([ZIAMUtil sharedUtil]->deviceVerificationURL){
                    //Return Failure callback for TokenActivation...
                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"Device verification dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_DeviceVerificationDismissedError userInfo:userInfo];
                    
                    [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock(returnError);
                    [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock = nil;
                    return;
                }else if([ZIAMUtil sharedUtil]->AddSecondaryEmailURL){
                    //Return Failure callback for AddSecondaryEmailURL...
                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"Add Secondary Email Dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAddSecondaryEmailDismissedError userInfo:userInfo];
                    
                    [ZIAMUtil sharedUtil]->finalAddEmailIDBlock(returnError);
                    [ZIAMUtil sharedUtil]->finalAddEmailIDBlock = nil;
                    return;
                }else if([ZIAMUtil sharedUtil]->CloseAccountURL){
                    //Return Failure callback for Close Account URL...

                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"Close account Dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOCloseAccountDismissedError userInfo:userInfo];
                    
                    self.failure(returnError);

                    return;
                }else{
                    //Return Failure callback for Safari Dimiss...
                    [self removeCustomStates];
                    NSError *returnError;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:@"Safari Dismissed" forKey:NSLocalizedDescriptionKey];
                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOSFSafariDismissedError userInfo:userInfo];
                    
                    self->_failure(returnError);
                    return;
                }
            }];
            
            
        }
    });
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

-(NSString*)getURLString:(NSString*)accountsbaseURL {
    NSString *urlString;

    NSString *managedMDMDefaultDC = [[ZIAMUtil sharedUtil] getMDMDefaultDC];
    if(managedMDMDefaultDC){
        managedMDMDefaultDC = [managedMDMDefaultDC lowercaseString];
        NSArray *zohoDCArray = @[@"us", @"in", @"eu", @"au", @"cn"];
        int defaultDCInt = (int)[zohoDCArray indexOfObject:managedMDMDefaultDC];
        switch (defaultDCInt) {
            case 0:
                accountsbaseURL = kZoho_Base_URL;
                break;
            case 1:
                accountsbaseURL = kZoho_IN_Base_URL;
                break;
            case 2:
                accountsbaseURL = kZoho_EU_Base_URL;
                break;
            case 3:
                accountsbaseURL = kZoho_AU_Base_URL;
                break;
            case 4:
                accountsbaseURL = kZoho_CN_Base_URL;
                break;
                
            default:
                break;
        }
    }
    
    if([ZIAMUtil sharedUtil]->ScopeEnhancementUrl){
        urlString = [ZIAMUtil sharedUtil]->ScopeEnhancementUrl;
    }else if([ZIAMUtil sharedUtil]->UnconfirmedUserURL){
        urlString = [ZIAMUtil sharedUtil]->UnconfirmedUserURL;
    }else if([ZIAMUtil sharedUtil]->OneAuthTokenActivationURL){
        urlString = [ZIAMUtil sharedUtil]->OneAuthTokenActivationURL;
    }else if([ZIAMUtil sharedUtil]->deviceVerificationURL){
        urlString = [ZIAMUtil sharedUtil]->deviceVerificationURL;
    }else if([ZIAMUtil sharedUtil]->AddSecondaryEmailURL){
        urlString = [ZIAMUtil sharedUtil]->AddSecondaryEmailURL;
    }else if([ZIAMUtil sharedUtil]->CloseAccountURL){
        urlString = [ZIAMUtil sharedUtil]->CloseAccountURL;

    } else {
        // app verify JSON required cases
        
        SSOKeyPairUtil *keygen= [[SSOKeyPairUtil alloc] init];
        [keygen setIdentifierForPublicKey:@"com.zoho.publicKey"
                               privateKey:@"com.zoho.privateKey"
                          serverPublicKey:@"com.zoho.serverPublicKey"];
        [keygen generateKeyPairRSA];
        
        //PublicKey to be Stored in IAM Server!
        NSString* oauthpub = [keygen getPublicKeyAsBase64ForJavaServer];
        oauthpub = [[ZIAMUtil sharedUtil] getEncodedStringForString:oauthpub];
        
        long long timePassed_ms = ([[NSDate date] timeIntervalSince1970] * 1000);
        
        
        /// DLog(@"%@ %@ %ld",uaString,appName,millis);
        
        mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        NSMutableDictionary *appVerifyJson = [[NSMutableDictionary alloc]init];

        #if !TARGET_OS_WATCH
        [appVerifyJson setValue:[[UIDevice currentDevice] name] forKey:@"deviceName"];
        #else
        [appVerifyJson setValue:[[WKInterfaceDevice currentDevice] systemName] forKey:@"deviceName"];
        #endif


        [appVerifyJson setValue:[[ZIAMUtil sharedUtil]deviceName ] forKey:@"deviceModel"];
        [appVerifyJson setValue:[NSString stringWithFormat:@"%lld",timePassed_ms] forKey:@"timestamp"];
        [appVerifyJson setValue:[[NSBundle mainBundle] bundleIdentifier] forKey:@"packageName"];



        if(mdmToken){
            [appVerifyJson setValue:mdmToken forKey:@"mdm_token"];

        }
        if([[ZIAMUtil sharedUtil] getDeviceIDFromKeychain]){

            [appVerifyJson setValue:[[ZIAMUtil sharedUtil] getDeviceIDFromKeychain] forKey:@"deviceId"];

        }
        
        //[self checkAndUpdateDeviceDetails:appVerifyJson];

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:appVerifyJson options:NSJSONWritingPrettyPrinted error:&error];
            //NSData *data = [rt_cook_string dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedData = [jsonData AES128EncryptedDataWithKey:kSSOSHARED_SECRET];
        //NSData *encryptedData = [data AES128EncryptedDataWithKey:kSSOSHARED_SECRET];
        NSString* encryptedDataString = [encryptedData base64EncodedStringWithOptions:0];
        encryptedDataString = [[ZIAMUtil sharedUtil] getEncodedStringForString:encryptedDataString];
        NSString* defaultMobileAuthURL = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&state=Test&response_type=code&access_type=offline&newmobilepage=true&ss_id=%@&app_verify=%@", kSSOMobileAuth_URL,[ZIAMUtil sharedUtil]->ClientID,[ZIAMUtil sharedUtil]->UrlScheme,oauthpub,encryptedDataString];
        
        if([ZIAMUtil sharedUtil]->SignUpUrl || [ZIAMUtil sharedUtil]->showSignUp){
            
            // Signup
            NSString *serviceUrl = [NSString stringWithFormat:@"%@%@&forcelogout=true",accountsbaseURL,defaultMobileAuthURL];
            
            if(![ZIAMUtil sharedUtil].donotSendScopesParam){
                serviceUrl = [serviceUrl stringByAppendingFormat:@"&scope=%@", [ZIAMUtil sharedUtil]->Scopes];
            }
            NSString *encoded_serviceUrl=[[ZIAMUtil sharedUtil] getEncodedStringForString:serviceUrl];
            
            NSString *signupUrl;
            if([ZIAMUtil sharedUtil]->SignUpUrl){
                if((!zohodc || !isSFSafariDisplayed) && isChineseLocale && [ZIAMUtil sharedUtil].isAppSupportingChinaSetup){
                    signupUrl = [ZIAMUtil sharedUtil]->CNSignUpURL;
                }else{
                    signupUrl = [ZIAMUtil sharedUtil]->SignUpUrl;
                }
            }else{
                if([ZIAMUtil sharedUtil]->UrlParams){
                    signupUrl = [NSString stringWithFormat:@"%@%@%@",accountsbaseURL,kSSOAccountsSignUpForCustomParams_URL,[ZIAMUtil sharedUtil]->UrlParams];
                }else{
                    signupUrl = [NSString stringWithFormat:@"%@%@",accountsbaseURL,kSSOAccountsSignUp_URL];
                }
            }
            urlString  = [NSString stringWithFormat:@"%@&serviceurl=%@&IAM_CID=%@",signupUrl,encoded_serviceUrl,[ZIAMUtil sharedUtil]->ClientID];


        } else if([ZIAMUtil sharedUtil]->NativeSignInTok) {
            
            // SIWA
            NSString *NativeSignInTokBaseURL;
            if([ZIAMUtil sharedUtil].siwaBaseURL){
                NativeSignInTokBaseURL = [ZIAMUtil sharedUtil].siwaBaseURL;
            }else{
                NativeSignInTokBaseURL = accountsbaseURL;
            }
            urlString = [NSString stringWithFormat:@"%@%@&scope=%@&fs_token=%@",NativeSignInTokBaseURL,defaultMobileAuthURL,[ZIAMUtil sharedUtil]->Scopes,[ZIAMUtil sharedUtil]->NativeSignInTok];
        } else {
            
            // default login URL
            urlString = [NSString stringWithFormat:@"%@%@",accountsbaseURL,defaultMobileAuthURL];
            // add scopes
            if(![ZIAMUtil sharedUtil].donotSendScopesParam){
                urlString = [urlString stringByAppendingFormat:@"&scope=%@", [ZIAMUtil sharedUtil]->Scopes];
            }
            // add dark mode
            if (@available(iOS 12.0, *)) {
                if(self.view.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                    urlString = [NSString stringWithFormat:@"%@&darkmode=true",urlString];
                }
            }
            //add custom params
            if([ZIAMUtil sharedUtil]->UrlParams){
                urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&%@",[ZIAMUtil sharedUtil]->UrlParams]];
            }
            //signin google
            if([ZIAMUtil sharedUtil]->showGoogleSignIn){
                urlString = [urlString stringByAppendingString:@"&signOps=2"];
            }
        }
        
        
    }
    return urlString;
}

- (void)displaySafari {
    NSString *accountsbaseURL = [ZIAMUtil sharedUtil]->BaseUrl;
    contactBaseURL = [ZIAMUtil sharedUtil]->ContactsUrl;
    if([ZIAMUtil sharedUtil].donotfetchphoto){
        contactBaseURL = nil;
    }
    if(((!zohodc || !isSFSafariDisplayed) && isChineseLocale && [ZIAMUtil sharedUtil].isAppSupportingChinaSetup)){
        
        zohodc = NO;
        accountsbaseURL = kZoho_CN_Base_URL;
        contactBaseURL = kCONTACTS_Zoho_CN_PROFILE_PHOTO;
    }
    isSFSafariDisplayed = YES;
    NSString *urlString = [self getURLString:accountsbaseURL];

    //Managed MDM LoginID and ReadOnly params
    NSString *loginID =[[ZIAMUtil sharedUtil] getManagedMDMLoginID];
    if(loginID){
        loginID = [[ZIAMUtil sharedUtil] getEncodedStringForString:loginID];
        NSString *loginIDParam =[NSString stringWithFormat:@"&login_id=%@",loginID];
        urlString = [urlString stringByAppendingString:loginIDParam];
        if([[ZIAMUtil sharedUtil] isMangedMDMRestrictedLogin]){
            urlString = [urlString stringByAppendingString:@"&u_readonly=true"];
        }
    }
    
    if([ZIAMUtil sharedUtil].shouldUseWKWebview || mdmToken){
#if !TARGET_OS_UIKITFORMAC
            NSURL * url =  [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:mdmToken forHTTPHeaderField:@"X-MDM-Token"];
            [self.view addSubview:self.webkitview];
            [self.webkitview loadRequest:request];
            [self addCloseButtonOnWKWebview];
#endif
        }else if([ZIAMUtil sharedUtil].shoulduseSFAuthenticationSession){
#if !TARGET_OS_UIKITFORMAC
        if (@available(iOS 11.0, *)) {
            sfAuthsession = [[SFAuthenticationSession alloc]
                                                initWithURL:[NSURL URLWithString:urlString]
                                                callbackURLScheme:nil
                                                completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
                if(error == nil){
                    [[ZIAMUtil sharedUtil] handleURL:callbackURL sourceApplication:@"com.apple.SafariViewService" annotation:nil];
                }else{
                    [self dismissReturningError:error];
                }
            }];
            [sfAuthsession start];
        }
#endif
    }else if([ZIAMUtil sharedUtil].shoulduseASWebAuthenticationSession){
#if !SSOKit_DoNotUseXcode11
        NSString *redirectURL = [[ZIAMUtil sharedUtil]->UrlScheme stringByReplacingOccurrencesOfString:@"://" withString:@""];

        if (@available(iOS 12.0, *)) {
            asWebAuthsession = [[ASWebAuthenticationSession alloc]
                                                   initWithURL:[NSURL URLWithString:urlString]
                                                   callbackURLScheme:redirectURL
                                                   completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
                if(error == nil){
                    [[ZIAMUtil sharedUtil] handleURL:callbackURL sourceApplication:@"com.apple.SafariViewService" annotation:nil];
                }else{
                    if([error code] == ASWebAuthenticationSessionErrorCodeCanceledLogin){
                        NSError *returnError;
                        
                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                        [userInfo setValue:@"Safari Dismissed" forKey:NSLocalizedDescriptionKey];
                        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOSFSafariDismissedError userInfo:userInfo];
                        error = returnError;
                    }
                    
                    [self dismissReturningError:error];
                }
            }];
            if (@available(iOS 13.0, *)) {
                asWebAuthsession.presentationContextProvider = self;
            }
            [asWebAuthsession start];
        }
#endif
    }else{
        
        if (@available(iOS 9.0, *)) {
#if !TARGET_OS_UIKITFORMAC
            if ([SFSafariViewController class] != nil) {
                safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:urlString] entersReaderIfAvailable:NO];
                
                safariVC.delegate = self;
                //SFSafari Customisation
                if (@available(iOS 11.0, *)) {
                    if([ZIAMUtil sharedUtil].dismissButtonStyle)
                        safariVC.dismissButtonStyle = [ZIAMUtil sharedUtil].dismissButtonStyle;
                }
                if([ZIAMUtil sharedUtil].preferredBarTintColor)
                    if (@available(iOS 10.0, *)) {
                        safariVC.preferredBarTintColor = [ZIAMUtil sharedUtil].preferredBarTintColor;
                    }
                
                if([ZIAMUtil sharedUtil].preferredControlTintColor)
                    if (@available(iOS 10.0, *)) {
                        safariVC.preferredControlTintColor = [ZIAMUtil sharedUtil].preferredControlTintColor;
                    }
                
                safariVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                navigationController = [[UINavigationController alloc]initWithRootViewController:safariVC];
                navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [navigationController setNavigationBarHidden:YES animated:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [ZIAMUtil sharedUtil].shouldPresentInFormSheet) {
                        self->navigationController.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+12);
                        UIPopoverController* popOverController = [[UIPopoverController alloc] initWithContentViewController:self->navigationController];
                        [popOverController setDelegate:self];
                        CGRect rect = self.view.bounds;
                        [popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
                        self.popupObject = popOverController;
                        UIView *modalView = [[UIView alloc]initWithFrame:rect];
                        self->loadingviewFrame.center = CGPointMake(modalView.center.x,modalView.center.y);
                    }else{
                        [[[ZIAMUtil sharedUtil] topViewController] presentViewController:self->navigationController animated:YES completion:nil];
                    }
                    
                });

            }else{
#if !SSO_APP__EXTENSION_API_ONLY
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                });
#endif
            }
#endif


        } else {
            // Fallback on earlier versions
#if !SSO_APP__EXTENSION_API_ONLY
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            });
#endif
        }
    }
}
#if !SSOKit_DoNotUseXcode11
- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session API_AVAILABLE(ios(12.0)){
    return self.view.window;
}
#endif

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    DoneButtonClicked = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.popupObject = nil;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self dismissReturningError];
        }
    });
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.webkitview == webView) {
        DLog(@"Webivew Loaded...");
    }
}

#pragma mark WebPolicyDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.webkitview == webView) {
        NSString* url = [[navigationAction.request URL] description];
        //DLog(@"navigating to %@", url);
        NSString *scheme = [[navigationAction.request URL] scheme];
        if ([[ZIAMUtil sharedUtil]->UrlScheme rangeOfString:scheme].length != 0)
        {
            NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
            NSArray *urlComponents = [[[navigationAction.request URL] query] componentsSeparatedByString:@"&"];
            for (NSString *keyValuePair in urlComponents)
            {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
                //DLog(@"Key : %@------- Value:%@",key,value);
                [queryStringDictionary setObject:value forKey:key];
            }
            [self oauthposthavingQueryString:queryStringDictionary];
            decisionHandler(WKNavigationActionPolicyCancel);
        }else{
            // Cookie is present so allow the request
            if (([navigationAction.request.allHTTPHeaderFields objectForKey:@"X-MDM-Token"] != nil)) {
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
            }else{
                // Take the existing request and cancel it, then make a copy of it with the cookie in it and load that instead
                //    // https://bugs.webkit.org/show_bug.cgi?id=140191
                NSURL* url = navigationAction.request.URL;
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:mdmToken forHTTPHeaderField:@"X-MDM-Token"];
                [webView loadRequest:request];
                decisionHandler(WKNavigationActionPolicyCancel);
            }
        }
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#if !TARGET_OS_UIKITFORMAC
#pragma mark - SFSafariViewController delegate methods
-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully API_AVAILABLE(ios(9.0)){
    // Load finished
    DLog(@"Sign In WebView Loaded");
    if([ZIAMUtil sharedUtil].shouldShowFeedbackOption)
        [self addFeedbackButtonOnSFSafariViewController:controller];
    if(isChineseLocale && [ZIAMUtil sharedUtil].isAppSupportingChinaSetup && ![ZIAMUtil sharedUtil]->NativeSignInTok)
        [self addDCChooserOnSFSafariViewController:controller];
}

- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL {
    DLog(@"safariViewController initialLoadDidRedirectToURL");

}

-(void)addCloseButtonOnWKWebview{
    CGRect contentViewBound = _webkitview.bounds;
    
    //UIImage *closeImage = [UIImage imageNamed:@"ssokit_webviewclose" inBundle:[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SSOKitBundle" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
    UIImage *closeImage = [UIImage imageNamed:@"ssokit_webviewclose" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:closeImage];
    CGRect imageViewFrame = CGRectMake(contentViewBound.size.width - (closeImage.size.width+10), 35, closeImage.size.width, closeImage.size.height);
    imageView.frame = imageViewFrame;
    [_webkitview addSubview:imageView];
    UIGestureRecognizer *tapfeedback = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedclose:)];
    [imageView addGestureRecognizer:tapfeedback];
    
    imageView.userInteractionEnabled = YES;
}

- (void)tappedclose:(UIGestureRecognizer *)gestureRecognizer {
    NSError *returnError;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:@"WKWebView Closed" forKey:NSLocalizedDescriptionKey];
    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOSFSafariDismissedError userInfo:userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[ZIAMUtil sharedUtil] topViewController] dismissViewControllerAnimated:YES completion:^{
            [self dismissReturningError:returnError];
        }];
    });
    
}

-(void)addFeedbackButtonOnSFSafariViewController:(SFSafariViewController *)controller API_AVAILABLE(ios(9.0)){
    CGRect contentViewBound = controller.view.bounds;
    //UIImage *feedbackImage = [UIImage imageNamed:@"ssokit_feedback"];
    //if(!feedbackImage){
    UIImage *feedbackImage = [UIImage imageNamed:@"ssokit_feedback" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
    //UIImage *feedbackImage = [UIImage imageNamed:@"ssokit_feedback" inBundle:[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SSOKitBundle" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
    //}
    UIImageView *imageView = [[UIImageView alloc] initWithImage:feedbackImage];
    CGRect imageViewFrame = CGRectMake(contentViewBound.size.width - feedbackImage.size.width, 95, feedbackImage.size.width, feedbackImage.size.height);
    imageView.frame = imageViewFrame;
    [controller.view addSubview:imageView];
    UIGestureRecognizer *tapfeedback = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedfeedback:)];
    [imageView addGestureRecognizer:tapfeedback];
    
    imageView.userInteractionEnabled = YES;
}

#endif
- (void)tappedfeedback:(UIGestureRecognizer *)gestureRecognizer {
    NSError *returnError;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:@"Feedback tapped" forKey:NSLocalizedDescriptionKey];
    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOSFSafariFeedbackTapped userInfo:userInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[ZIAMUtil sharedUtil] topViewController] dismissViewControllerAnimated:YES completion:^{
            [self dismissReturningError:returnError];
        }];
    });
    
}

#if !TARGET_OS_UIKITFORMAC
-(void)addDCChooserOnSFSafariViewController:(SFSafariViewController *)controller API_AVAILABLE(ios(9.0)){
    CGRect contentViewBound = controller.view.bounds;
    UIImage *dcImage;
    if(self->zohodc){
//        dcImage = [UIImage imageNamed:@"ssokit_dc_cn"];
//        if(!dcImage){
            dcImage = [UIImage imageNamed:@"ssokit_dc_cn" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        //}
    }else{
//        dcImage = [UIImage imageNamed:@"ssokit_dc_com"];
//        if(!dcImage){
            dcImage = [UIImage imageNamed:@"ssokit_dc_com" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        //}
    }
    
    UIImageView *dcimageView = [[UIImageView alloc] initWithImage:dcImage];
    CGRect imageViewFrame = CGRectMake(contentViewBound.size.width - dcImage.size.width, 95 + dcImage.size.height + 16, dcImage.size.width, dcImage.size.height);
    dcimageView.frame = imageViewFrame;
    [controller.view addSubview:dcimageView];
    UIGestureRecognizer *tapfeedback = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappeddcchooser:)];
    [dcimageView addGestureRecognizer:tapfeedback];
    
    dcimageView.userInteractionEnabled = YES;
}
#endif

- (void)tappeddcchooser:(UIGestureRecognizer *)gestureRecognizer {
    
    //    NSString *zohoTitle =  @"Zoho";
    //    NSString *zohoChinaTitle = @"Zoho China";
    //
    //    NSString *cancelTitle = @"Cancel";
    //
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose your data center" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDestructive handler:nil];
    //    UIAlertAction *zoho = [UIAlertAction actionWithTitle:zohoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    if(!self->zohodc){
        self->zohodc = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[ZIAMUtil sharedUtil] topViewController] dismissViewControllerAnimated:YES completion:^{
                [self displaySafari];
            }];
        });
    }
    //}];
    
    
    //    UIAlertAction *zohochina = [UIAlertAction actionWithTitle:zohoChinaTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    else if(self->zohodc){
        self->zohodc = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[ZIAMUtil sharedUtil] topViewController] dismissViewControllerAnimated:YES completion:^{
                [self displaySafari];
            }];
        });
        
    }
    //    }];
    //    if(zohodc){
    //        [zoho setValue:@true forKey:@"checked"];
    //    }else{
    //        [zohochina setValue:@true forKey:@"checked"];
    //    }
    //     [alertController addAction:zohochina];
    //    [alertController addAction:zoho];
    //    [alertController addAction:cancel];
    //
    //
    //    [[alertController popoverPresentationController] setSourceView:gestureRecognizer.view];
    //    [[[ZIAMUtil sharedUtil] topViewController] presentViewController:alertController animated:YES completion:nil];
}

#if !TARGET_OS_UIKITFORMAC

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller API_AVAILABLE(ios(9.0)){
    // Done button pressed
    DoneButtonClicked = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller dismissViewControllerAnimated:YES completion:nil];
        //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //Scope enhancement done button dismiss viewdidAppear not called for people iOS app, temp fixup...
        [self dismissReturningError];
        //}
    });

}

#endif
-(void)showLoadingIndicator{
    if ([ZIAMUtil sharedUtil]->showProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->showProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
#if !SSO_APP__EXTENSION_API_ONLY
            [self->loadingActivityView startAnimating];
#endif
            self->loadingviewFrame.hidden = NO;
        });
    }
}

-(void)hideLoadingIndicator{
    if ([ZIAMUtil sharedUtil]->endProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->endProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
#if !SSO_APP__EXTENSION_API_ONLY
            [self->loadingActivityView stopAnimating];
#endif
            self->loadingviewFrame.hidden = YES;
        });
    }
    
}

- (void)oauthpost:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"sfsafariredirection" object:nil];
    #if !TARGET_OS_UIKITFORMAC

        if (@available(iOS 9.0, *)) {
            if ([SFSafariViewController class] != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->safariVC dismissViewControllerAnimated:YES completion:nil];
                });
                
            }
        }
    #endif
    NSMutableDictionary *queryStringDictionary;
    queryStringDictionary = [note object];
    [self oauthposthavingQueryString:queryStringDictionary];
}

- (void)oauthposthavingQueryString:(NSMutableDictionary *)queryStringDictionary {

    [self removeCustomStates];

    [self showLoadingIndicator];
    
    if([queryStringDictionary objectForKey:@"error"]){
        DLog(@"OAuth Redirection ERROR");
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:[queryStringDictionary objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOAuthServerError userInfo:userInfo];
        [self dismissReturningError:returnError];
        return;

    }
    
    if([queryStringDictionary objectForKey:@"scope_enhanced"]){
        [self handleScopeEnhancementRedirection:queryStringDictionary];
        return;
        
    } else if([queryStringDictionary objectForKey:@"user_confirmed"]){
        [self handleUnconfirmedUserRedirection:queryStringDictionary];
        return;

    } else if([queryStringDictionary objectForKey:@"usecase"]){
        
        NSString *useCase = [queryStringDictionary objectForKey:@"usecase"];
        if ([useCase isEqualToString:@"add_secondary_email"]) {
            [self handleSecondaryEmailRedirection:queryStringDictionary];
            return;
        } else if ([useCase isEqualToString:@"close_account"]) {
            [self handleCloseAccountRedirection:queryStringDictionary];
            return;
        }

    } else if([queryStringDictionary objectForKey:@"activate_token"]){
        [self handleActivateTokenRedirection:queryStringDictionary];
        return;

    } else if([queryStringDictionary objectForKey:@"device_verified"]){
        [self handleDeviceVerificationRedirection:queryStringDictionary];
        return;

    }
    
    if([queryStringDictionary objectForKey:@"teamParams"]){
        NSString *jsonStr = [queryStringDictionary objectForKey:@"teamParams"];
        NSError *jsonError;
        NSData *objectData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        [ZIAMUtil sharedUtil]->setjsonDictTeamParams = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                       options:NSJSONReadingMutableContainers
                                                                                         error:&jsonError];
    }
    
    DLog(@"OAuth Redirection Success");
    
    DLog(@"Bingo");
    
    gt_hash  =   [queryStringDictionary objectForKey:@"gt_hash"];
    DLog(@"gt_hash-------> %@",gt_hash);
    
    //Get the KeyPair!
    SSOKeyPairUtil *keygen= [[SSOKeyPairUtil alloc] init];
    [keygen setIdentifierForPublicKey:@"com.zoho.publicKey"
                           privateKey:@"com.zoho.privateKey"
                      serverPublicKey:@"com.zoho.serverPublicKey"];

    NSString*  encrypted_gt_sec   =   [queryStringDictionary objectForKey:@"gt_sec"];



    NSData *granttokenData = [NSData dataFromBase64String:encrypted_gt_sec];

    //Decrypt using private key
    gt_sec= [keygen decryptUsingPrivateKeyWithData:granttokenData];


    //Store this in app keychain
    [ZIAMUtil sharedUtil]->setClientSecret = gt_sec;
    DLog(@"gt_sec :::: %@",gt_sec);
    
    
    //Per User Per App
    dcl_prefix =   [queryStringDictionary objectForKey:@"location"];
    DLog(@"DCL PFX-------> %@",dcl_prefix);
    
    
    
    
    code = [queryStringDictionary objectForKey:@"code"];
    DLog(@"code = %@", code);
    
    
    SSOBuildType currentMode = [ZIAMUtil sharedUtil]->MODE;
    if ((currentMode == Local_SSO_Development) || (currentMode == Local_SSO_Mdm)) {
#if defined(SSO_LOCAL_MDM) || defined(DEBUG)
        accountsServer = kLocalZoho_Base_URL;
#else
        accountsServer = [queryStringDictionary objectForKey:@"accounts-server"];
#endif
    } else {
        accountsServer = [queryStringDictionary objectForKey:@"accounts-server"];
    }
    
    location = [queryStringDictionary objectForKey:@"location"];
    
    [ZIAMUtil sharedUtil]->setAccountsServerURL= accountsServer;
    [ZIAMUtil sharedUtil]->setLocation= location;
    
    
    //URL Encode the client secret to post to server
    NSString *encoded_gt_sec=[[ZIAMUtil sharedUtil] getEncodedStringForString:gt_sec];
    
    
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",accountsServer,kSSOFetchToken_URL];
    
    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
    [paramsAndHeaders setValue:@"authorization_code" forKey:@"grant_type"];
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",[ZIAMUtil sharedUtil]->ClientID] forKey:@"client_id"];
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",encoded_gt_sec] forKey:@"client_secret"];
    //set service url here
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",[ZIAMUtil sharedUtil]->UrlScheme] forKey:@"redirect_uri"];
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",gt_hash] forKey:@"rt_hash"];
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",code] forKey:@"code"];

    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:[[ZIAMUtil sharedUtil] getUserAgentString] forKey:@"User-Agent"];
    //NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
        //Request success
        //Header for DCL Handling
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            NSDictionary *dictionary = [httpResponse allHeaderFields];
            if([dictionary objectForKey:@"X-Location-Meta"]){
                NSString *base64EncodedString = [dictionary objectForKey:@"X-Location-Meta"];
                self->Bas64DCL_Meta_Data = [NSData dataFromBase64String:base64EncodedString];
                [ZIAMUtil sharedUtil]->setBas64DCL_Meta_Data=self->Bas64DCL_Meta_Data;


            }
        }


        //Store the RefreshToken in keychain
        self->refresh_token = [jsonDict objectForKey:@"refresh_token"];

        DLog(@"refreshToken: %@",refresh_token);
        NSString *deviceID = [jsonDict valueForKey:@"deviceId"];
        if(deviceID){
            [[ZIAMUtil sharedUtil]setDeviceIDtoKeychain:deviceID];
        }


        //Give the Access token when asked!
        self->access_token = [jsonDict objectForKey:@"access_token"];
        self->expires_in = [jsonDict objectForKey:@"expires_in"];

        DLog(@"AccessToken: %@ Expires in : %@",access_token,expires_in);

        DLog(@"LoginWebview--->>Login Success");

        [ZIAMUtil sharedUtil]->setAccessToken= self->access_token;
        [ZIAMUtil sharedUtil]->setExpiresIn= self->expires_in;
        [ZIAMUtil sharedUtil]->setRefreshToken= self->refresh_token;
        [[ZIAMUtil sharedUtil] fetchUserInfoHavingContactsURL:self->contactBaseURL WithBlock:^(NSError *error) {
            if(error == nil){
                [self hideLoadingIndicator];

                if(self->_success){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:NO completion:^{
                            if([[ZIAMUtil sharedUtil]checkIfUnauthorisedManagedMDMAccount]){
                                [[ZIAMUtil sharedUtil] revokeAccessTokenWithSuccess:^{
                                    NSError *returnError;

                                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                    [userInfo setValue:@"UnAuthorised Managed MDM Account" forKey:NSLocalizedDescriptionKey];
                                    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUnAuthorisedManagedMDMAccount userInfo:userInfo];

                                    self->_failure(returnError);
                                } andFailure:^(NSError *error) {
                                    self->_failure(error);
                                }];
                            }else{
                                self->_success(self->access_token);
                            }
                        }];
                    });
                }else if(self->_switchSuccess){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:NO completion:^{
                            self->_switchSuccess(self->access_token,YES,[[ZIAMUtil sharedUtil]getCurrentUser]);
                        }];
                    });
                }
            }else{
                [self dismissReturningError:error];
            }
        }];


        //[self fetchUserInfo];
    } failureBlock:^(SSOInternalError errorType, NSError* error) {
        //Request failed
        //Skip sending error callback for duplicate request!!!
        if(![[error.userInfo valueForKey:@"error"] isEqualToString:@"duplicate_request"]){
            [self handleLoginError:errorType error:error];
        }
    }];
}

-(void)handleScopeEnhancementRedirection:(NSDictionary*)queryStringDictionary {
    NSString *scopeEnhanced = [queryStringDictionary objectForKey:@"scope_enhanced"];
    NSString *status = [queryStringDictionary objectForKey:@"status"];
    if([scopeEnhanced isEqualToString:@"true"] && [status isEqualToString:@"success"]){
        //Scope Enhancement Done successfully...
        DLog(@"Scope Enahcnement Done Success...");
        [[ZIAMUtil sharedUtil] getForceFetchOAuthTokenForZUID:[ZIAMUtil sharedUtil]->User_ZUID success:[ZIAMUtil sharedUtil]->finalScopeEnhancementSuccessBlock andFailure:[ZIAMUtil sharedUtil]->finalScopeEnhancementFailureBlock];
        [ZIAMUtil sharedUtil]->User_ZUID = nil;
        [self hideLoadingIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
        return;
        
    }else{
        //Scope Enhancement Failed...
        DLog(@"Scope Enahcnement Failed...");
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Scope Enhancement failued" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementServerError userInfo:userInfo];
        [self dismissReturningError:returnError];
        return;
        
    }
}

-(void)handleUnconfirmedUserRedirection:(NSDictionary*)queryStringDictionary {
    NSString *userConfirmed = [queryStringDictionary objectForKey:@"user_confirmed"];
    NSString *status = [queryStringDictionary objectForKey:@"status"];
    if([userConfirmed isEqualToString:@"true"] && [status isEqualToString:@"success"]){
        //User Email Confirmation Done successfully...
        DLog(@"User Email Confirmation Done Success...");
        [[ZIAMUtil sharedUtil] getForceFetchOAuthTokenForZUID:[ZIAMUtil sharedUtil]->User_ZUID success:_success andFailure:_failure];
        [ZIAMUtil sharedUtil]->User_ZUID = nil;
        [self hideLoadingIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
        return;
        
    }else{
        //User Email Confirmation Failed...
        DLog(@"User Email Confirmation Failed...");
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"User Email Confirmation failed" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUserConfirmationServerError userInfo:userInfo];
        [self dismissReturningError:returnError];
        return;
        
    }
}
-(void)handleSecondaryEmailRedirection:(NSDictionary*)queryStringDictionary {
    NSString *status = [queryStringDictionary objectForKey:@"status"];
    if([status isEqualToString:@"success"]){
        if([ZIAMUtil sharedUtil]->finalAddEmailIDBlock){
            [ZIAMUtil sharedUtil]->finalAddEmailIDBlock(nil);
            [ZIAMUtil sharedUtil]->finalAddEmailIDBlock = nil;
            [self hideLoadingIndicator];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
            });
            return;
        }
    }else{
        //AddSecondaryEmail Failed...
        DLog(@"AddSecondaryEmail Failed...");
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"AddSecondaryEmail Failed" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAddSecondaryEmailServerError userInfo:userInfo];
        [self dismissReturningError:returnError];
        return;
    }
}
-(void)handleCloseAccountRedirection:(NSDictionary*)queryStringDictionary {
    NSString *status = [queryStringDictionary objectForKey:@"status"];
    if([status isEqualToString:@"success"]){
        if(self.failure){
            self.failure(nil);
            [self hideLoadingIndicator];
            //clear oauth details
            if ([[ZIAMUtil sharedUtil] getIsSignedInUsingSSOAccountForZUID:[ZIAMUtil sharedUtil]->User_ZUID]) {
                [[ZIAMUtil sharedUtil] clearDataForDeletingSSOAccountHavingZUID:[ZIAMUtil sharedUtil]->User_ZUID];
            } else {
                [[ZIAMUtil sharedUtil] clearDataForLogoutHavingZUID:[ZIAMUtil sharedUtil]->User_ZUID];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
            });
            [ZIAMUtil sharedUtil]->User_ZUID = nil;
            return;
        }
    }else{
        //AddSecondaryEmail Failed...
        DLog(@"AddSecondaryEmail Failed...");
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Close account Failed" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOCloseAccountServerError userInfo:userInfo];
        [self dismissReturningError:returnError];
        return;
    }
}
-(void)handleDeviceVerificationRedirection:(NSDictionary*)queryStringDictionary {
    NSString *activateRefreshToken = [queryStringDictionary objectForKey:@"device_verified"];
    NSString *status = [queryStringDictionary objectForKey:@"status"];
    if([activateRefreshToken isEqualToString:@"true"] && [status isEqualToString:@"success"]){
        DLog(@"Device verified");
        
        if([ZIAMUtil sharedUtil]->finalDeviceVerificationBlock){
            [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock(nil);
            [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock = nil;
        }
        
        
    }else{
        if([ZIAMUtil sharedUtil]->finalDeviceVerificationBlock){
            NSError *returnError;
            
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Activation Failed" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_DeviceVerificationDismissedError userInfo:userInfo];
            [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock(returnError);
            [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock = nil;
        }
    }
    [self hideLoadingIndicator];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
    return;
}

-(void)handleActivateTokenRedirection:(NSDictionary*)queryStringDictionary {
    NSString *activateRefreshToken = [queryStringDictionary objectForKey:@"activate_token"];
    NSString *status = [queryStringDictionary objectForKey:@"status"];
    if([activateRefreshToken isEqualToString:@"true"] && [status isEqualToString:@"success"]){
        
        DLog(@"Inactive SSO Refresh Token Activated...");

        [[ZIAMUtil sharedUtil] getSSOForceFetchOAuthTokenWithSuccess:^(NSString *token) {
            
            [self hideLoadingIndicator];

            if(self->_success){
                self->_success(token);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:nil];
                });
            }
            [ZIAMUtil sharedUtil]->User_ZUID = nil;
        } andFailure:^(NSError *error) {
            
            [self hideLoadingIndicator];

            if(self->_failure){
                self->_failure(error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:nil];
                });
            }
            [ZIAMUtil sharedUtil]->User_ZUID = nil;
        }];
        
        
    } else {
        
        [self hideLoadingIndicator];

        if(self->_failure){
            
            NSError *returnError;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Activation Failed" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenActivationServerError userInfo:userInfo];
            self->_failure(returnError);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
            });
            return;
        }else{
            //Inactive Refresh Token Activation Failed...
            DLog(@"Inactive SSO Refresh Token Activation Failed...");
            NSError *returnError;
            
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Inactive Refresh Token Activation Failed" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenActivationServerError userInfo:userInfo];
            [self dismissReturningError:returnError];
            return;
        }
        
    }
}
-(void)handleLoginError:(SSOInternalError)type error:(NSError*)error {
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"RefreshToken Fetch Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORefreshTokenFetchNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"RefreshToken fetch Error: %@", [error.userInfo valueForKey:@"error"]);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORefreshTokenFetchError userInfo:[[ZIAMUtil sharedUtil] getUserInfoFromError:error]];
        
        
    } else if (type == SSO_ERR_NOTHING_WAS_RECEIVED) {
        //Nothing was received
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"RefreshToken Fetch Nothing was Received." forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORefreshTokenFetchNothingReceived userInfo:userInfo];
        
        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    [self dismissReturningError:returnError];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"sfsafariredirection" object:nil];

}

-(void)dismissReturningError:(NSError *)error{
    [self removeCustomStates];
    [self hideLoadingIndicator];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:^{
            self->_failure(error);
        }];
    });
}

-(void)removeCustomStates{
    [ZIAMUtil sharedUtil]->ButtonClick = NO;
    [ZIAMUtil sharedUtil]->showGoogleSignIn = NO;
    [ZIAMUtil sharedUtil]->UrlParams = nil;
    [ZIAMUtil sharedUtil]->ScopeEnhancementUrl = nil;
    [ZIAMUtil sharedUtil]->SignUpUrl = nil;
    [ZIAMUtil sharedUtil]->showSignUp = NO;
    [ZIAMUtil sharedUtil].donotfetchphoto = NO;
    [ZIAMUtil sharedUtil]->UnconfirmedUserURL = nil;
    [ZIAMUtil sharedUtil]->NativeSignInTok = nil;
    [ZIAMUtil sharedUtil]->OneAuthTokenActivationURL = nil;
    [ZIAMUtil sharedUtil]->deviceVerificationURL = nil;
    [ZIAMUtil sharedUtil]->AddSecondaryEmailURL = nil;
    [ZIAMUtil sharedUtil]->CloseAccountURL = nil;

}

@end
#endif
