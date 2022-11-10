//
//  ZIAMUtil.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 21/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZIAMUtil.h"
#include "ZIAMUtilConstants.h"
#include "NSData+Base64.h"
#include "SSOUserAccountsTableViewController.h"
#include "SSONetworkManager.h"
#include "ZSSOUser+Internal.h"
#include "ZSSOProfileData+Internal.h"
#include "SSOSFSafariViewController.h"
#include "SSOKeyPairUtil.h"
#include "SSO_NSData+AES.h"
#include "ZIAMToken+Internal.h"
#include "ZSSODCLUtil.h"
#include "ZIAMErrorHandler.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"
#include "SSOTokenFetch.h"
#if !TARGET_OS_WATCH
#import "DeviceCheck/DeviceCheck.h"
#endif
#if !SSOKit_DoNotUseXcode11
#import "AuthenticationServices/AuthenticationServices.h"
#endif
#if SSOKit_WECHATSDK_SUPPORTED
#import "WeChatUtil.h"
#endif
#if TARGET_OS_WATCH || SSOKit_DoNotUseXcode11
@interface ZIAMUtil ()
#else
@interface ZIAMUtil ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>
#endif
{
    BOOL isSSOAccessToken;
    dispatch_queue_t oauthGetQueue;
    #if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY && !SSOKit_DoNotUseXcode11
        UIView *loadingviewFrame;
        UIActivityIndicatorView *loadingActivityView;
    #endif
}
@end

@implementation ZIAMUtil

+ (ZIAMUtil *)sharedUtil {
    static ZIAMUtil *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance->oauthGetQueue = dispatch_queue_create("com.zoho.ssokit.oauthqueue", 0);
        [sharedInstance initTokenFetch];
    });

    return sharedInstance;
}

//Start of ZSSOKit Helpers
//Initializer
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH
- (void) initWithClientID: (NSString*)clientID
                    Scope:(NSArray*)scopearray
                URLScheme:(NSString*)URLScheme
               MainWindow:(UIWindow*)mainWindow
                BuildType:(SSOBuildType)buildType{
    [self initExtensionWithClientID:clientID Scope:scopearray URLScheme:URLScheme BuildType:buildType];

#if !SSO_APP__EXTENSION_API_ONLY
    MainWindow = mainWindow;
#endif
}
#endif


#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH
-(UIWindow *)getActiveWindow{
    if(self.presentationContextProviderSSOKit){
        return [self.presentationContextProviderSSOKit presentationAnchorForSSOKit];
    }else{
        return [ZIAMUtil sharedUtil]->MainWindow;
    }
}
#endif

- (void) initExtensionWithClientID:(NSString*)clientID
                             Scope:(NSArray*)scopearray
                         URLScheme:(NSString*)URLScheme
                         BuildType:(SSOBuildType)buildType{

    ClientID = clientID;

    // Create a string to concatenate all scopes existing in the _scopes array.
    Scopes = @"";
    BOOL isProfileScopeGiven = NO;
    BOOL isContactsScopeGiven = NO;



    for (int i=0; i<[scopearray count]; i++) {
        if([[scopearray objectAtIndex:i] caseInsensitiveCompare:@"aaaserver.profile.READ"] == NSOrderedSame){
            isProfileScopeGiven = YES;
        }
        if([[scopearray objectAtIndex:i] caseInsensitiveCompare:@"zohocontacts.userphoto.READ"] == NSOrderedSame){
            isContactsScopeGiven = YES;
        }

        Scopes = [Scopes stringByAppendingString:[scopearray objectAtIndex:i]];

        // If the current scope is other than the last one, then add the "+" sign to the string to separate the scopes.
        if (i < [scopearray count] - 1) {
            Scopes = [Scopes stringByAppendingString:@","];
        }
    }
    if(!isProfileScopeGiven){
        if([Scopes isEqualToString:@""]){
            Scopes = [Scopes stringByAppendingString:@"aaaserver.profile.READ"];
        }else{
            Scopes = [Scopes stringByAppendingString:@",aaaserver.profile.READ"];
        }

    }
    if(!isContactsScopeGiven){
        Scopes = [Scopes stringByAppendingString:@",zohocontacts.userphoto.READ"];
    }
    if(![URLScheme hasSuffix:@"://"]){
        UrlScheme = [URLScheme stringByAppendingString:@"://"];
    }else{
        UrlScheme = URLScheme;
    }

    MODE = buildType;
    NSBundle *bundle = [NSBundle mainBundle];

    [self initMode:MODE];

    if ([[bundle infoDictionary] valueForKey:@"SSOKIT_MAIN_APP_BUNDLE_ID"]) {
        AppName = [[bundle infoDictionary] valueForKey:@"SSOKIT_MAIN_APP_BUNDLE_ID"];
        return;
    }

    AppName = [bundle bundleIdentifier];

    if([[ZIAMUtil sharedUtil]checkShouldCallRevokeTokenInKeychain]){
        [[ZIAMUtil sharedUtil]revokeAccessTokenWithSuccess:^{
            [[ZIAMUtil sharedUtil]resetRevokeFailedinKeychain];
        } andFailure:^(NSError *error) {

        }];
    }

}

//Get Token
- (void) getTokenWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{

    [self getTokenForZUID:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
    return;
}

- (void) getTokenForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processgetTokenForZuid:zuid WithSuccess:success andFailure:failure];
        return;
    });
    return;
}

- (void) getTokenForWMSWithSuccess:(requestWMSSuccessBlock)success andFailure:(requestFailureBlock)failure{
    wmsCallBack = YES;
    [self getTokenWithSuccess:^(NSString *token) {
        success(token,self->expiresinMillis-wmsTimeCheckMargin);
        self->wmsCallBack = NO;
    } andFailure:^(NSError *error) {
        failure(error);
        self->wmsCallBack = NO;
    }];
}
-(void)getTokenForWMSHavingZUID:(NSString *)zuid WithSuccess:(requestWMSSuccessBlock)success andFailure:(requestFailureBlock)failure{
    wmsCallBack = YES;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        success(token,self->expiresinMillis-wmsTimeCheckMargin);
        self->wmsCallBack = NO;
    } andFailure:^(NSError *error) {
        failure(error);
        self->wmsCallBack = NO;
    }];
}

-(ZIAMToken *)getSyncOAuthToken{
    __block ZIAMToken *tokenObj = nil;
    [self getTokenForWMSWithSuccess:^(NSString *token, long long expiresMillis) {
        tokenObj = [[ZIAMToken alloc] init];
        [tokenObj initWithToken:token expiry:(int)expiresMillis error:nil];
    } andFailure:^(NSError *error) {
        tokenObj = [[ZIAMToken alloc] init];
        [tokenObj initWithToken:nil expiry:0 error:error];
    }];
    while (!tokenObj) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return tokenObj;
}

//Watch Utils
- (NSDictionary *)giveOAuthDetailsForWatchApp{
    return [self giveOAuthDetailsForWatchAppForZUID:[self getCurrentUserZUIDFromKeychain]];
}

- (NSDictionary *)giveOAuthDetailsForWatchAppForZUID:(NSString *)zuid{
    NSMutableDictionary *OAuthDetails = [[NSMutableDictionary alloc] init];
    if([self isHavingSSOAccount] && ([[self getSSOZUIDFromSharedKeychain] isEqualToString:zuid] && ([self isAppUsingSSOAccount] || [self isAppUsingMyZohoSSOAccount]))){
        //Handle For myzoho case later
        [OAuthDetails setValue:[self getSSOClientSecretFromSharedKeychainForZUID:zuid] forKey:@"client_secret"];
        [OAuthDetails setValue:[self getSSORefreshTokenFromSharedKeychainForZUID:zuid] forKey:@"refresh_token"];
        [OAuthDetails setValue:zuid forKey:@"zuid"];
        [OAuthDetails setValue:[self getSSOAccessTokenDataFromSharedKeychainForZUID:zuid] forKey:@"access_token"];
        [OAuthDetails setValue:[self getSSOAccountsURLFromKeychainForZUID:zuid] forKey:@"accounts_server"];
        [OAuthDetails setValue:[self getClientIDFromSharedKeychain] forKey:@"client_id"];
        [OAuthDetails setValue:[self getSSODCLLocationFromSharedKeychainForZUID:zuid] forKey:@"location"];
        [OAuthDetails setValue:@"true" forKey:@"is_sso_account"];
    }else{
        [OAuthDetails setValue:[self getClientSecretFromKeychainForZUID:zuid] forKey:@"client_secret"];
        [OAuthDetails setValue:[self getRefreshTokenFromKeychainForZUID:zuid] forKey:@"refresh_token"];
        [OAuthDetails setValue:zuid forKey:@"zuid"];
        [OAuthDetails setValue:[self getAccessTokenDataFromKeychainForZUID:zuid] forKey:@"access_token"];
        [OAuthDetails setValue:[self getAccountsURLFromKeychainForZUID:zuid] forKey:@"accounts_server"];
        [OAuthDetails setValue:[self getDCLLocationFromKeychainForZUID:zuid] forKey:@"location"];

    }
    return OAuthDetails;
}

-(void)setOAuthDetailsInKeychainForWatchApp:(NSDictionary *)OAuthDetails{

    [self setOAuthDetailsInKeychainForWatchAppHavingZUID:[self getCurrentUserZUIDFromKeychain] details:OAuthDetails];
}

-(void)setOAuthDetailsInKeychainForWatchAppHavingZUID:(NSString *)zuid details:(NSDictionary *)OAuthDetails{

    NSString* client_secret = [OAuthDetails objectForKey:@"client_secret"];
    NSString* CurrentAppUser = [OAuthDetails objectForKey:@"zuid"];
    NSString* refresh_token = [OAuthDetails objectForKey:@"refresh_token"];
    NSData *accessTokenData = [OAuthDetails objectForKey:@"access_token"];
    NSString *accountsUrl = [OAuthDetails objectForKey:@"accounts_server"];
    NSString *client_id = [OAuthDetails objectForKey:@"client_id"];
    NSString *location = [OAuthDetails objectForKey:@"location"];
    NSString *is_sso_account = [OAuthDetails objectForKey:@"is_sso_account"];

    if([is_sso_account isEqualToString:@"true"]){
        if(refresh_token)
            [self setSSORefreshTokenInSharedKeychain:refresh_token ForZUID:zuid];
        if(client_secret)
            [self setSSOClientSecretInSharedKeychain:client_secret ForZUID:zuid];
        if(accountsUrl)
            [self setAccountsURL:accountsUrl inKeychainForZUID:CurrentAppUser];
        if(accessTokenData != nil)
            [self setAppSSOAccessTokenDataInSharedKeychain:accessTokenData ForZUID:zuid];
        if(CurrentAppUser)
            [self setSSOZUIDInSharedKeychain:CurrentAppUser];
        if(location){
            [self setDCLLocation:location inKeychainForZUID:CurrentAppUser];
        }
        if(client_id)
            [self setSSOClientIDFromSharedKeychain:client_id];
    }else{
        if(refresh_token)
            [self setRefreshToken:refresh_token inKeychainForZUID:CurrentAppUser];
        if(client_secret)
            [self setClientSecret:client_secret inKeychainForZUID:CurrentAppUser];
        if(accountsUrl)
            [self setAccountsURL:accountsUrl inKeychainForZUID:CurrentAppUser];
        if(accessTokenData != nil)
            [self setAccessTokenData:accessTokenData inKeychainForZUID:CurrentAppUser];
        if(CurrentAppUser)
            [self setCurrentUserZUIDInKeychain:CurrentAppUser];
        if(client_id){
            [self setClientID:client_id inKeychainForZUID:CurrentAppUser];
        }
        if(location){
            [self setDCLLocation:location inKeychainForZUID:CurrentAppUser];
        }
    }
}

//Present Methods
- (void) presentInitialViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    ButtonClick = YES;
    [self getTokenWithSuccess:success andFailure:failure];
}

- (void) presentInitialViewControllerWithCustomParams:(NSString *)urlParams success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    ButtonClick = YES;
    UrlParams = urlParams;
    [self getTokenWithSuccess:success andFailure:failure];
}

- (void) presentGoogleSigninSFSafariViewControllerWithSuccess:(requestSuccessBlock)success
                                                   andFailure:(requestFailureBlock)failure{

    ButtonClick = YES;
    showGoogleSignIn = YES;
    [self getTokenWithSuccess:success andFailure:failure];
}

- (void) presentGoogleSigninSFSafariViewControllerWithoutOneAuthSuccess:(requestSuccessBlock)success
                                                             andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->showGoogleSignIn = YES;
        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
    });
}
#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY && !SSOKit_DoNotUseXcode11
// SIWA Works
- (void) presentNativeSignInWithAppleWithSuccess:(requestSuccessBlock)success
                                      andFailure:(requestFailureBlock)failure{
    finalMultiAccountSuccessBlock = success;
    finalMultiAccountFailureBlock = failure;
    DLog(@"Sign In With Apple Button tapped");
    if (@available(iOS 13.0, *)) {
        if([self isChineseLocale] && _isAppSupportingChinaSetup){
            [self showDCChooserActionSheet];
        }else{
            [self presentSIWA];
        }
        
    } else {
        // Return Error SIWA unavailable for this iOS version
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"SIWA unavailable for this iOS version" forKey:NSLocalizedDescriptionKey];
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAUnavailableForOSError userInfo:userInfo];
        finalMultiAccountFailureBlock(returnError);
    }
}
-(void)showDCChooserActionSheet {
    NSString *actionSheetTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.dcchooser.title" Comment:@"Select your region"];
    NSString *cancelTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.Cancel" Comment:@"Cancel"];
    NSString *zohoCNTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.dcchooser.china" Comment:@"China"];
    NSString *zohoTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.dcchooser.other" Comment:@"Other"];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:actionSheetTitle message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // keep safe zones
    UIAlertAction *actionZoho = [UIAlertAction actionWithTitle:zohoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->_siwaBaseURL = self->BaseUrl;
        [self presentSIWA];
        
    }];

    
    // delete safe zones
    UIAlertAction *actionZohoCN = [UIAlertAction actionWithTitle:zohoCNTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self->_siwaBaseURL = kZoho_CN_Base_URL;
        [self presentSIWA];
        
    }];
    
    // cancel
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction* _Nonnull action) {
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Select your region cancelled" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSODCChooserCancelledError userInfo:userInfo];
        self->finalMultiAccountFailureBlock(returnError);
        return;
    }];
    [alertVC addAction:actionZohoCN];
    [alertVC addAction:actionZoho];
    [alertVC addAction:actionCancel];
    
    //[[alertVC popoverPresentationController] setSourceView:MainWindow.rootViewController.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *top = [self topViewController];
        [[alertVC popoverPresentationController] setSourceView:self->_dcChooserActionSheetSourceView];
        [[alertVC popoverPresentationController] setSourceRect:self->_dcChooserActionSheetSourceView.bounds];
        if(top){
            [top presentViewController:alertVC animated:YES completion:nil];
        }else{
            [[self getActiveWindow].rootViewController presentViewController:alertVC animated:YES completion:nil];
        }
    });
}
-(void)presentSIWA{
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDProvider* appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest* request = [appleIDProvider createRequest];
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

        ASAuthorizationController* ctrl = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        ctrl.presentationContextProvider = self;
        ctrl.delegate = self;
        [ctrl performRequests];
    }
}
// SIWA Authorization success callback
- (void)authorizationController:(ASAuthorizationController *)controller
   didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){

    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
//        NSString *user = appleIDCredential.user;
//        NSString *email = appleIDCredential.email;
        // Store UserID for checking Revoke status later...
        if(appleIDCredential.fullName.givenName){
            [self setSIWAUserFirstNameInKeychain:appleIDCredential.fullName.givenName];
        }
        if(appleIDCredential.fullName.familyName){
            [self setSIWAUserLastNameInKeychain:appleIDCredential.fullName.familyName];
        }
        [self setSIWAUserIDInKeychain:appleIDCredential.user];
        NSString* GT = [[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding];
        [self proceedSignInUsingGrantToken:GT forProvider:@"apple"];

    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {

        //To Do: Study more on this...
/*
        // User login uses existing password credentials
        ASPasswordCredential *passwordCredential = authorization.credential;
        // User ID of the password credential object Unique ID of the user
        NSString *user = passwordCredential.user;
        // Password for the password credential object
        NSString *password = passwordCredential.password;
 */

        //Might be for native sign in using username and password...
    } else {
        //Authorization information does not match
        DLog(@"Authorization information does not match");

    }
}

//! SIWA Authorization failed callback
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){
        NSString *errorMsg = nil;
        NSInteger errorcode = 0;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"User canceled authorization request";
            errorcode = k_SSONativeSIWAASAuthorizationErrorCanceled;
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"Authorization request failed";
            errorcode = k_SSONativeSIWAASAuthorizationErrorFailed;
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"Authorization request response is invalid";
            errorcode = k_SSONativeSIWAASAuthorizationErrorInvalidResponse;
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"Failed to process authorization request";
            errorcode = k_SSONativeSIWAASAuthorizationErrorNotHandled;
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"Authorization request failed for unknown reason";
            errorcode = k_SSONativeSIWAASAuthorizationErrorUnknown;
            break;
    }

    if (errorMsg) {
        //return error callback...
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:errorMsg forKey:NSLocalizedDescriptionKey];
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorcode userInfo:userInfo];
        finalMultiAccountFailureBlock(returnError);
        return;
    }

    if (error.localizedDescription) {
        finalMultiAccountFailureBlock(error);
        return;
    }

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:@"SIWA unknown failure" forKey:NSLocalizedDescriptionKey];
    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAError userInfo:userInfo];
    finalMultiAccountFailureBlock(returnError);
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    return [self getActiveWindow];
}
/*
- (void)observeAppleSignInState { if (@available(iOS 13.0, *)) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (@available(iOS 13.0, *)) {
           [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
       }
    [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil]; } }
- (void)handleSignInWithAppleStateChanged:(NSNotification *)noti {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", noti);
    if([noti.name isEqualToString:@"ASAuthorizationAppleIDCredentialRevokedNotification"]){
        NSLog(@"Call SSOKit Revoke method");
    }

}
- (void)dealloc {
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}
 */
 - (void)observeSIWAAuthticationStateHavingCallback:(requestMultiAccountFailureBlock)failure {

     if (@available(iOS 13.0, *)) {
         // A mechanism for generating requests to authenticate users based on their Apple ID.
         ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];

         NSString *userIdentifier = [self getSIWAUserIDFromKeychain];
         NSError * __block returnError;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
         if (userIdentifier) {
             NSString *SIWA_ZUID = [self getZUIDFromKeychainForSIWAUID:userIdentifier];
             //Returns the credential state for the given user in a completion handler.
             [appleIDProvider getCredentialStateForUserID:userIdentifier completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                 switch (credentialState) {
                         // Apple certificate authorization status
                     case ASAuthorizationAppleIDProviderCredentialRevoked:
                         // Apple authorization credentials are invalid
                         [userInfo setValue:@"Apple authorization credentials Revoked" forKey:NSLocalizedDescriptionKey];
                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateCredentialRevoked userInfo:userInfo];
                         failure(SIWA_ZUID,returnError);
                         break;
                     case ASAuthorizationAppleIDProviderCredentialAuthorized:
                         // Apple authorization credentials are in good condition
                         failure(SIWA_ZUID,nil);
                         break;
                     case ASAuthorizationAppleIDProviderCredentialNotFound:
                         // No Apple Authorization Credentials Found
                         [userInfo setValue:@"No Apple Authorization Credentials Found" forKey:NSLocalizedDescriptionKey];
                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateCredentialNotFound userInfo:userInfo];
                         failure(SIWA_ZUID,returnError);
                         // Can guide the user to log in again
                         break;
                     case ASAuthorizationAppleIDProviderCredentialTransferred:
                         // AppleID Credential Transferred

                        [userInfo setValue:@"AppleID Credential Transferred" forKey:NSLocalizedDescriptionKey];
                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateCredentialTransferred userInfo:userInfo];
                         failure(SIWA_ZUID,returnError);
                         break;
                 }
             }];

         }else{
             //No SIWA User ID found...
            [userInfo setValue:@"SIWA No UserID Found in Keychain" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateNoUserID userInfo:userInfo];
             failure(nil, returnError);
         }

     }
 }
-(void)addLoadingViewInView:(UIView *)view{
    loadingviewFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    loadingviewFrame.center = CGPointMake(view.center.x,view.center.y);
    
    //LoadingView Constraints
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:90];
    [view addSubview:loadingviewFrame];
    loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
    [view addConstraint:centerX];
    [view addConstraint:centerY];
    [loadingviewFrame addConstraint:width];
    [loadingviewFrame addConstraint:height];
    [view setNeedsLayout];
    [view layoutIfNeeded];
    
    
    //view.backgroundColor = [UIColor clearColor];
    
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
        UILabel *loadingText= [[UILabel alloc]initWithFrame:loadingviewFrame.frame];
        loadingText.hidden = NO;
        loadingText.text =  [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.loading" Comment:@"Loading..."];
        loadingText.textColor = [UIColor whiteColor];
        loadingText.backgroundColor = [UIColor clearColor];
        loadingText.textAlignment = NSTextAlignmentCenter;
        loadingText.font = [UIFont fontWithName:@"Helvetica" size:16];
        loadingText.center = CGPointMake(loadingviewFrame.frame.size.width/2, (loadingviewFrame.frame.size.height/2)+30);
        [loadingviewFrame addSubview:loadingText];
        
        [view addSubview:loadingviewFrame];
        loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
        
        
        [view addConstraint:centerX];
        [view addConstraint:centerY];
        [loadingviewFrame addConstraint:width];
        [loadingviewFrame addConstraint:height];
        [view setNeedsLayout];
        [view layoutIfNeeded];
}
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
-(void)proceedSignInUsingGrantToken:(NSString *)grantToken forProvider:(NSString *)provider{
//    UIView *loadingView = [[UIView alloc] initWithFrame:[self topViewController].view.bounds];
//    dispatch_async(dispatch_get_main_queue(), ^{
//    loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
//        UIActivityIndicatorView *loadingActivity;
//        if (@available(iOS 13.0, *)) {
//            loadingActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
//
//        } else {
//            loadingActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        }
//        loadingActivity.center = loadingView.center;
//        [loadingView addSubview:loadingActivity];
//        [[self topViewController].view addSubview:loadingView];
//        [[self topViewController].view bringSubviewToFront:loadingView];
//        [[self topViewController].view setNeedsLayout];
//        [[self topViewController].view layoutIfNeeded];
//        [loadingActivity startAnimating];
//    });
     
     [self addLoadingViewInView:[self topViewController].view];
    NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
    if([provider isEqualToString:@"apple"]){
        //Add Parameters
        NSMutableDictionary *nameHeader = [[NSMutableDictionary alloc]init];
        NSMutableDictionary* nameParams = [[NSMutableDictionary alloc]init];
        
        if([self getSIWAUserFirstNameFromKeychain]){
            [nameParams setValue:[self getSIWAUserFirstNameFromKeychain] forKey:@"firstName"];
            [nameParams setValue:[self getSIWAUserLastNameFromKeychain] forKey:@"lastName"];
            [nameHeader setValue:nameParams forKey:@"name"];
            [paramsAndHeaders setValue:nameHeader forKey:@"custom_info"];
        }
    }
    
    [paramsAndHeaders setValue:grantToken forKey:@"id_data"];
    [paramsAndHeaders setValue:provider forKey:@"provider"];
    [paramsAndHeaders setValue:ClientID forKey:@"c_id"];
    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:[[ZIAMUtil sharedUtil] getUserAgentString] forKey:@"User-Agent"];
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
    //URL
    NSString *urlString;
    NSString *accountsbaseURL = BaseUrl;
    NSString *managedMDMDefaultDC = [[ZIAMUtil sharedUtil]getMDMDefaultDC];
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
    
    urlString = [NSString stringWithFormat:@"%@%@",accountsbaseURL,kSSONativeSignInHandling_URL];
    if([provider isEqualToString:@"wechat"] || [self->_siwaBaseURL isEqualToString:kZoho_CN_Base_URL]){
        urlString = [NSString stringWithFormat:@"%@%@",kZoho_CN_Base_URL,kSSONativeSignInHandling_URL];
    }
    [self showLoadingIndicator];
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                    //Request success
                                                    [self hideLoadingIndicator];
                                                    if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                                                        DLog(@"Success Response ");
                                                        self->NativeSignInTok = [jsonDict objectForKey:@"tok"];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             self->fsProvider = provider;
                                                             [self presentSSOSFSafariViewControllerWithSuccess:self->finalMultiAccountSuccessBlock andFailure:self->finalMultiAccountFailureBlock];
                                                             
                                                         });
                                                    }else{
                                                        //failure handling...
                                                        DLog(@"Status: Failure Response");
                                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                        [userInfo setValue:@"Native Sign In Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSignInServerError userInfo:userInfo];
                                                        self->finalMultiAccountFailureBlock(returnError);
                                                    }
                                                } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                    [self hideLoadingIndicator];
                                                    DLog(@"Failure Response");
                                                    [self handleNativeSigninError:errorType error:error failureBlock:self->finalMultiAccountFailureBlock];
                                                }];
}
#endif

//WeChatLogin
-(void) presentWeChatSignInHavingWeChatID:(NSString *)appID weChatAppSecret:(NSString *)appSecret universalLink:(NSString *)universalLink WithSuccess:(requestSuccessBlock)success
andFailure:(requestFailureBlock)failure{
    #if SSOKit_WECHATSDK_SUPPORTED
        finalMultiAccountSuccessBlock = success;
        finalMultiAccountFailureBlock = failure;
        WeChatUtil *weChatUtil= [[WeChatUtil alloc]init];
        weChatAppID = appID;
        weChatAppSecret = appSecret;
        weChatUniversalLink = universalLink;
        [weChatUtil presentWeChatSignIn];
    #endif
}

- (void) presentSignUpViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    if(_isAppSupportingChinaSetup && [self isChineseLocale]){
        BaseUrl = kZoho_CN_Base_URL;
    }
    self->showSignUp = YES;
    [self presentSignUp:success andFailure:failure];
}

- (void) presentSignUpViewControllerWithCustomParams:(NSString *)urlParams success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    UrlParams = urlParams;
    if(_isAppSupportingChinaSetup && [self isChineseLocale]){
        BaseUrl = kZoho_CN_Base_URL;
    }
    self->showSignUp = YES;
    [self presentSignUp:success andFailure:failure];
}

- (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    self->SignUpUrl = signupUrl;
    [self presentSignUp:success andFailure:failure];
}

- (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    self->SignUpUrl = signupUrl;
    self->CNSignUpURL = cnSignUpURL;
    [self presentSignUp:success andFailure:failure];
}

-(void)presentSignUp:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
    });
}

- (void) presentMultiAccountSigninWithCustomParams:(NSString *)urlParams success:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure{
    UrlParams = urlParams;
    [self presentMultiAccountSigninWithSuccess:success andFailure:failure];
}

- (void) presentMultiAccountSigninWithSuccess:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->isMultiAccountSignIn = YES;
        [self presentSSOSFSafariViewControllerWithSuccess:^(NSString *token) {
            success(token,self->setMultiAccountZUID);
        } andFailure:^(NSError *error) {
            failure(error);
        }];
    });
}

- (void) presentSignInUsingAnotherAccountWithCustomParams:(NSString *)urlParams success:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->UrlParams = urlParams;
        [self presentSSOSFSafariViewControllerWithSuccess:^(NSString *token) {
            success(token,self->setMultiAccountZUID);
        } andFailure:^(NSError *error) {
            failure(error);
        }];
    });
}

- (void) presentManageAccountsViewControllerWithSuccess:(ZSSOKitManageAccountsSuccessHandler)success
                                             andFailure:(ZSSOKitManageAccountsFailureHandler)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self presentAccountChooserWithSuccess:nil andFailure:failure havingSwitchSuccess:success];
    });
}

- (void) presentCloseAccountForZUID:(NSString *)zuid failure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ZSSOUser *user= [self getZSSOUserHavingZUID:zuid];
        NSString *emailID = user.profile.email;
        emailID = [self getEncodedStringForString:emailID];
        NSString *serviceURL = @"/home#setting/closeaccount";
        serviceURL = [self getEncodedStringForString:serviceURL];
        NSString* closeAccountPageURL = [NSString stringWithFormat:@"%@/signin?LOGIN_ID=%@&servicename=AaaServer&serviceurl=%@",[self getAccountsURLFromKeychainForZUID:zuid],emailID,serviceURL];
        
        self->CloseAccountURL = closeAccountPageURL;
        [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:failure];
    });
}


-(void)appFirstLaunchClearData{
    [self appFirstLaunchClearDataFromKeychain];
}

-(BOOL)isUserSignedIn{
    if([self getCurrentUserZUIDFromKeychain]){
        return YES;
    }
    return NO;
}

-(BOOL) isUserSignedInUsingSIWAForZUID:(NSString *)ZUID{
    NSString *SIWAUID = [self getSIWAUserIDFromKeychain];
    if(SIWAUID){
        NSString *siwaUserZUID = [self getZUIDFromKeychainForSIWAUID:SIWAUID];
        if([siwaUserZUID isEqualToString:ZUID]){
            return YES;
        }
    }
    return NO;
}

//URLScheme Redirection
-(BOOL)handleURL:url sourceApplication:sourceApplication annotation:annotation{
    // just making sure we send the notification when the URL is opened in SFSafariViewController
    if ([sourceApplication isEqualToString:@"com.apple.SafariViewService"] || [sourceApplication isEqualToString:@"com.apple.mobilesafari"]) {


        NSString* queryString = [url query];

        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            DLog(@"Key : %@------- Value:%@",key,value);
            [queryStringDictionary setObject:value forKey:key];
        }
        if([queryStringDictionary objectForKey:@"gt_hash"] || [queryStringDictionary objectForKey:@"error"] || [queryStringDictionary objectForKey:@"scope_enhanced"] || [queryStringDictionary objectForKey:@"user_confirmed"] || [queryStringDictionary objectForKey:@"activate_token"] || [queryStringDictionary objectForKey:@"device_verified"] || [queryStringDictionary objectForKey:@"usecase"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sfsafariredirection" object:queryStringDictionary];
            return YES;
        }
    }else if([sourceApplication isEqualToString:@"com.tencent.xin"]){
        #if SSOKit_WECHATSDK_SUPPORTED
            WeChatUtil *weChatUtil= [[WeChatUtil alloc]init];
            return [weChatUtil handleWeChatOpenURL:url];
        #endif
    }else if([sourceApplication isEqualToString:Service]){
        if([[url query] isEqualToString:@"cancel"]){
            //dimissed in OneAuth...
            NSError *returnError;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"OneAuth Sign in Dismissed" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthSignInDismiss userInfo:userInfo];
            setFailureBlock(returnError);
            return YES;
        }


        NSString* queryString = [url query];

        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            DLog(@"Key : %@------- Value:%@",key,value);
            [queryStringDictionary setObject:value forKey:key];
        }
        if([[queryStringDictionary objectForKey:@"status"] isEqualToString:@"success"]){
            //Sign In Success from OneAuth...
            [self setCurrentUserZUIDInKeychain:[queryStringDictionary objectForKey:@"zuid"]];
            ButtonClick = NO;
#if !SSO_APP__EXTENSION_API_ONLY
            [self processgetTokenForZuid:[queryStringDictionary objectForKey:@"zuid"] WithSuccess:setSuccessBlock andFailure:setFailureBlock];
#endif
            return YES;
        }else if([[queryStringDictionary objectForKey:@"oasignout"] isEqualToString:@"YES"]){
            //dimissed in OneAuth...
            ButtonClick = NO;
            NSError *returnError;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"OneAuth Sign out done" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthSignOut userInfo:userInfo];
            setFailureBlock(returnError);
            return YES;
        }
    }else{
        if (@available(iOS 13.0, *)) {
            // SourceApplication is not available in iOS 13.
            // https://forums.developer.apple.com/thread/119118
            // https://forums.developer.apple.com/message/381679
        } else {
            if (!([sourceApplication isEqualToString:@"com.apple.SafariViewService"] || [sourceApplication isEqualToString:@"com.apple.mobilesafari"])){
                return NO;
            }
        }
        NSString* queryString = [url query];
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            DLog(@"Key : %@------- Value:%@",key,value);
            [queryStringDictionary setObject:value forKey:key];
        }
        if([queryStringDictionary objectForKey:@"gt_hash"] || [queryStringDictionary objectForKey:@"error"] || [queryStringDictionary objectForKey:@"scope_enhanced"] || [queryStringDictionary objectForKey:@"user_confirmed"] || [queryStringDictionary objectForKey:@"activate_token"] || [queryStringDictionary objectForKey:@"usecase"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sfsafariredirection" object:queryStringDictionary];
            return YES;
        }
    }
    return NO;
}
-(void)handleOpenUniversalLink:(NSUserActivity *)userActivity{
    #if SSOKit_WECHATSDK_SUPPORTED
        WeChatUtil *weChatUtil= [[WeChatUtil alloc]init];
        return [weChatUtil handleOpenUniversalLink:userActivity];
    #endif
}


-(ZSSOUser *)getCurrentUser{

    NSArray *userDetails = [self getCurrentUserDetails];
    if(userDetails){
        ZSSOProfileData *profileData = [[ZSSOProfileData alloc]init];
        //Temp fix for App Store OneAuth UserDetails...
        NSData *returnProfilePhotoData;
        NSData *profileImageData = [userDetails objectAtIndex:2];
        BOOL hasImage;
        if(![profileImageData isEqual:[NSNull null]] && [[userDetails objectAtIndex:2] isKindOfClass:[NSData class]]){
            returnProfilePhotoData = profileImageData;
             hasImage = YES;
        }else if([[userDetails objectAtIndex:2] isKindOfClass:[UIImage class]]){
            UIImage *profileImage = [userDetails objectAtIndex:2];
            returnProfilePhotoData = UIImagePNGRepresentation(profileImage);
            hasImage = YES;
        }else{
            UIImage *profileImage;
            #if !TARGET_OS_WATCH
            profileImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
            #endif
            returnProfilePhotoData = UIImagePNGRepresentation(profileImage);
            hasImage = NO;
        }
        if(userDetails.count <4){
            [profileData initWithEmailid:[userDetails objectAtIndex:1]
                                    name:[userDetails objectAtIndex:0]
                             displayName:[userDetails objectAtIndex:0]
                                hasImage:hasImage
                        profileImageData:returnProfilePhotoData];
        }else{
            [profileData initWithEmailid:[userDetails objectAtIndex:1]
                                    name:[userDetails objectAtIndex:3]
                             displayName:[userDetails objectAtIndex:0]
                                hasImage:hasImage
                        profileImageData:returnProfilePhotoData];
        }


        ZSSOUser *ZUser = [[ZSSOUser alloc]init];
        NSString *zuid = [self getCurrentUserZUIDFromKeychain];

        NSArray *scopesArray;
        scopesArray = [Scopes componentsSeparatedByString:@","];

        NSString *location = [self getDCLLocationFromKeychainForZUID:zuid];

        [ZUser initWithZUID:zuid Profile:profileData accessibleScopes:scopesArray accountsUrl:[self getAccountsURLFromKeychainForZUID:zuid] location:location];
        return ZUser;

    }


    return nil;
}

//Logout Handling
-(void)revokeAccessTokenWithSuccess:(requestLogoutSuccessBlock)success
                         andFailure:(requestLogoutFailureBlock)failure{
    [self postDeviceIDtoServer:success andFailure:failure];

}

#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY

-(void)closeAccountFor:(NSString*)ZUID havingCompletionHandler:(requestFailureBlock)response {
    
    NSDictionary* tempTokenDict = [self getTempTokenForCloseAccountWebSessionForZUID:ZUID];
    
    if (tempTokenDict) {
        //Get the CurrentTime!
        long long currentMillis = [self getCurrentTimeMillis];
        
        NSString* timeStampString = [tempTokenDict objectForKey:@"expires_in_sec"];

        long long storedTime = [timeStampString longLongValue];
        
        long long time = currentMillis + timecheckbuffer;

        DLog(@"Close Account token :Current Time:%ld TimeStamp:%ld",currentMillis,timeStamp);

        if(time < storedTime){
            DLog(@"Close Account token :Time Check Success!!!");

            NSString* tempToken = [tempTokenDict objectForKey:@"token"];
            [self showAuthenticatedCloseAccountPageForZUID:ZUID havingTempToken:tempToken failureCallback:response];
        } else {
            DLog(@"Close Account token :Time Check failed!!!");
            [self deleteAccountFor:ZUID WithCallback:response];
        }
    } else {
        [self deleteAccountFor:ZUID WithCallback:response];
    }
}

//close account
-(void)deleteAccountFor:(NSString*)ZUID
           WithCallback:(ZSSOKitErrorResponse)failure {
    
    [self getTokenForZUID:ZUID WithSuccess:^(NSString *token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLoadingViewInView:[self topViewController].view];
        });
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* redirectURLDict = [[NSMutableDictionary alloc] init];
        [redirectURLDict setValue:self->UrlScheme forKey:@"redirect_uri"];
        [redirectURLDict setValue:@"close_account" forKey:@"action"];

        [paramsAndHeaders setValue:redirectURLDict forKey:@"token"];

        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
        NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        if(mdmToken){
            [headers setValue:mdmToken forKey:@"X-MDM-Token"];
        }

        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOTemporarySessionToken_URL];
        [self showLoadingIndicator];
        // Request....
        [[SSONetworkManager sharedManager]
         sendJSONPOSTRequestForURL: urlString
         parameters: paramsAndHeaders
         successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            [self hideLoadingIndicator];
            int status_code = [[jsonDict objectForKey:@"status_code"]intValue];
            if(status_code == 201 ){
                DLog(@"Success Response ");
                NSString* tempToken = [jsonDict objectForKey:@"message"];
                NSString* generatedTime = [NSString stringWithFormat:@"%lld",[self getCurrentTimeMillis] + 300000];
                [self setTempTokenForCloseAccountWebSession:tempToken expiresIn:generatedTime forZUID:ZUID];

                [self showAuthenticatedCloseAccountPageForZUID:ZUID havingTempToken:tempToken failureCallback:failure];
                
            }else{
                //failure handling...
                DLog(@"Status: Failure Response");
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:@"Close account - Server Error Occured" forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOCloseAccountServerError userInfo:userInfo];
                failure(returnError);
            }
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            [self hideLoadingIndicator];
            DLog(@"Failure Response");
            [self handleCloseAccountError:errorType error:error failureBlock:failure];
        }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

-(void)showAuthenticatedCloseAccountPageForZUID:(NSString*)ZUID havingTempToken:(NSString*)tempToken failureCallback:(ZSSOKitErrorResponse)failure {
    self->User_ZUID = ZUID;
    self->CloseAccountURL = [NSString stringWithFormat:@"%@%@?temp_token=%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOCloseAccount_URL,tempToken];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:failure];
        
    });
}
#endif

-(void)postDeviceIDtoServer:(requestLogoutSuccessBlock)success
andFailure:(requestLogoutFailureBlock)failure{
    // <accountsUrl>/oauth/sso/userSignOut?clientId=<childClientId>&deviceId=<deviceId>
    //kDeviceVerify_Signout_URL

     NSString *zuid = [self getCurrentUserZUIDFromKeychain];
    self->ButtonClick = NO;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        if(([[[NSBundle mainBundle] bundleIdentifier]  isEqual: kMDM_BundleID]) || ([[[NSBundle mainBundle] bundleIdentifier]  isEqual: kDevelopment_BundleID])){
            if([self getDeviceIDFromKeychain]){
                NSString *urlString = [NSString stringWithFormat:@"%@%@?clientId=%@&deviceId=%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSODeviceVerify_Signout_URL,[NSString stringWithFormat:@"%@",self->ClientID],[self getDeviceIDFromKeychain]];


                //Add Parameters
                NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];

                //Add Headers
                NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
                [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];

                //[headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
                if ([self getDeviceIDFromKeychain]){
                    [headers setValue:[self getDeviceIDFromKeychain] forKey:@"X-Device-Id"];
                }else{
                    [headers setValue:@"NOT_CONFIGURED" forKey:@"X-Device-Id"];
                }
                [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
                NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
                if(mdmToken){
                    [headers setValue:mdmToken forKey:@"X-MDM-Token"];
                }
                [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
                [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                  parameters: paramsAndHeaders
                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                    //Request success
                    [self removeAllScopesForZUID:[self getCurrentUserZUIDFromKeychain] success:success failure:failure];
                    DLog(@"deviceID delete Done for App:%@",AppName);

                } failureBlock:^(SSOInternalError errorType, NSError* error) {
                    //Request failed
                    [self handleRevokeError:errorType error:error failureBlock:failure];
                    return;
                }];
            }else{
                [self removeAllScopesForZUID:[self getCurrentUserZUIDFromKeychain] success:success failure:failure];
            }
        }else{
            [self removeAllScopesForZUID:[self getCurrentUserZUIDFromKeychain] success:success failure:failure];
        }



    } andFailure:^(NSError *error) {
        failure(error);
        return;
    }];

    // Request....





}

-(void)removeAllScopesForZUID:(NSString *)zuid success:(requestLogoutSuccessBlock)successBlock failure:(requestLogoutFailureBlock)failureBlock {

    if ([self checkifSSOAccountsMatchForZUID:zuid]) {
        
        // app logged in using account chooser
        //check if the OneAuth app is still using the same ZUID
        // clear app data for ZUID mapped with sso account
       NSError* logoutError = [self clearAppSSOAccountForUserHavingZUID:zuid];
        if (logoutError) {
            failureBlock(logoutError);
        } else {
            successBlock();
        }
    } else {
        
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSORevoke_URL];

        //Add Parameters
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:zuid forKey:@"mzuid"];
        [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",[self getRefreshTokenFromKeychainForZUID:zuid]] forKey:@"token"];

        //Add Headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
        NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        if(mdmToken){
            [headers setValue:mdmToken forKey:@"X-MDM-Token"];
        }
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

        // Request....
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                        //Request success
                                                        [self clearDataForLogoutHavingZUID:zuid];
                                                        DLog(@"Logout Done for App:%@",AppName);
                                                        successBlock();
                                                    } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                        //Request failed
                                                        [self handleRevokeError:errorType error:error failureBlock:failureBlock];
                                                        return;
                                                    }];
    }


}

-(NSError*)clearAppSSOAccountForUserHavingZUID:(NSString*)ZUID {
    
    // get SSO account ZUID
    NSString *SSO_Zuid =[self getSSOZUIDFromSharedKeychain];
    
    if ([SSO_Zuid isEqualToString:ZUID]) {
        [self clearDataForLogoutHavingZUID:ZUID];
        DLog(@"Logout Done for App:%@",AppName);
        [self clearDataForSSOLogoutHavingZUID:ZUID];
        return nil;
    } else {
        DLog(@"Account Mismatch");
        [self clearDataForSSOLogoutHavingZUID:ZUID];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"OneAuth SSO Account Mismatch" forKey:NSLocalizedDescriptionKey];
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthAccountMismatch userInfo:userInfo];
        return returnError;
    }
    
}


-(NSString *)ziamgetTransformedURLStringForURL:(NSString *)url{
    return [self getTransformedURLStringForURL:url];
}
-(NSDictionary *)ziamgetDCLInfoForCurrentUser{
    return [self getDCLInfoForCurrentUser];
}

-(NSString *)ziamgetTransformedURLStringForURL:(NSString *)url havingZUID:(NSString *)zuid{
    return [self getTransformedURLStringForURL:url forZuid:zuid];
}
-(NSDictionary *)ziamgetDCLInfoForZuid:(NSString *)zuid{
    return [self getDCLInfoForZuid:zuid];
}

-(NSArray *) getZSSOUsersArray{
    NSMutableArray *ZSSOUsers = [[NSMutableArray alloc]init];
    BOOL isHavingSSOAccount = NO;

    if([self isHavingSSOAccount]){
        isHavingSSOAccount = YES;
    }

    if(isHavingSSOAccount){
        NSString *SSO_Zuid =[self getSSOZUIDFromSharedKeychain];
        NSMutableDictionary *SSOUserDetailsDictionary  = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:[self getSSOUserDetailsDataFromSharedKeychain]];
        NSArray *userdetailsArray = [SSOUserDetailsDictionary objectForKey:SSO_Zuid];
        ZSSOProfileData *profileData = [[ZSSOProfileData alloc]init];
        if(userdetailsArray.count <4){
            [profileData initWithEmailid:[userdetailsArray objectAtIndex:1]
                                    name:[userdetailsArray objectAtIndex:0]
                             displayName:[userdetailsArray objectAtIndex:0]
                                hasImage:YES
                        profileImageData:[userdetailsArray objectAtIndex:2]];
        }else{
            [profileData initWithEmailid:[userdetailsArray objectAtIndex:1]
                                    name:[userdetailsArray objectAtIndex:3]
                             displayName:[userdetailsArray objectAtIndex:0]
                                hasImage:YES
                        profileImageData:[userdetailsArray objectAtIndex:2]];
        }


        ZSSOUser *ZOneAuthUser = [[ZSSOUser alloc]init];

        NSArray *scopesArray;
        scopesArray = [Scopes componentsSeparatedByString:@","];

        [ZOneAuthUser initWithZUID:SSO_Zuid
                           Profile:profileData accessibleScopes:scopesArray
                       accountsUrl:[self getSSOAccountsURLFromKeychainForZUID:SSO_Zuid]
                          location:SSO_Zuid];
        [ZSSOUsers addObject:ZOneAuthUser];

    }

    int count = [self getUsersCount];

    for(int i = 1; i <= count ; i++){

        NSString *Zuid = [self getZUIDFromKeyChainForIndex:i];
        ZSSOUser *zUser = [self getZSSOUserHavingZUID:Zuid];
        if(zUser){
            [ZSSOUsers addObject:zUser];
        }
    }
    return ZSSOUsers;

}
-(ZSSOUser *)getZSSOUserHavingZUID:(NSString *)zuid{

    NSArray *userDetails = [self getUserDetailsForZUID:zuid];
    if(userDetails){
        ZSSOProfileData *profileData = [[ZSSOProfileData alloc]init];
        //Temp fix for App Store OneAuth UserDetails...
        NSData *returnProfilePhotoData;
        NSData *profileImageData = [userDetails objectAtIndex:2];
        BOOL hasImage;
        if(![profileImageData isEqual:[NSNull null]] && [[userDetails objectAtIndex:2] isKindOfClass:[NSData class]]){
            returnProfilePhotoData = profileImageData;
             hasImage = YES;
        }else if([[userDetails objectAtIndex:2] isKindOfClass:[UIImage class]]){
            UIImage *profileImage = [userDetails objectAtIndex:2];
            returnProfilePhotoData = UIImagePNGRepresentation(profileImage);
            hasImage = YES;
        }else{
            UIImage *profileImage;
            #if !TARGET_OS_WATCH
            profileImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
            #endif
            returnProfilePhotoData = UIImagePNGRepresentation(profileImage);
            hasImage = NO;
        }
        if(userDetails.count <4){
            [profileData initWithEmailid:[userDetails objectAtIndex:1]
                                    name:[userDetails objectAtIndex:0]
                             displayName:[userDetails objectAtIndex:0]
                                hasImage:hasImage
                        profileImageData:returnProfilePhotoData];
        }else{
            [profileData initWithEmailid:[userDetails objectAtIndex:1]
                                    name:[userDetails objectAtIndex:3]
                             displayName:[userDetails objectAtIndex:0]
                                hasImage:hasImage
                        profileImageData:returnProfilePhotoData];
        }

        ZSSOUser *ZUser = [[ZSSOUser alloc]init];

        NSArray *scopesArray;
        scopesArray = [Scopes componentsSeparatedByString:@","];

        [ZUser initWithZUID:zuid Profile:profileData accessibleScopes:scopesArray accountsUrl:[self getAccountsURLFromKeychainForZUID:zuid] location:[self getDCLLocationFromKeychainForZUID:zuid]];
        return ZUser;

    }
    return nil;
}
// Add Secondary Email - WIP
#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY
-(void)addSecondaryEmailIDWithCallback:(ZSSOKitAddEmailIDHandler)failure{
    finalAddEmailIDBlock = failure;
    [self getTokenForZUID:[self getCurrentUserZUIDFromKeychain] WithSuccess:^(NSString *token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLoadingViewInView:[self topViewController].view];
        });
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* redirectURL = [[NSMutableDictionary alloc] init];
        [redirectURL setValue:self->UrlScheme forKey:@"redirect_uri"];
        [paramsAndHeaders setValue:redirectURL forKey:@"token"];
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
        NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        if(mdmToken){
            [headers setValue:mdmToken forKey:@"X-MDM-Token"];
        }

        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        //URL
        NSString *urlString;
        urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:[self getCurrentUserZUIDFromKeychain]],kSSOTemporarySessionToken_URL];
        [self showLoadingIndicator];
        // Request....
        [[SSONetworkManager sharedManager] sendJSONPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                        //Request success
                                                        [self hideLoadingIndicator];
            int status_code = [[jsonDict objectForKey:@"status_code"]intValue];
                                                        if(status_code == 201 ){
                                                            DLog(@"Success Response ");
                                                            self->AddSecondaryEmailURL = [NSString stringWithFormat:@"%@%@?temp_token=%@",[self getAccountsURLFromKeychainForZUID:[self getCurrentUserZUIDFromKeychain]],kSSOAddSecondaryEmail_URL,[jsonDict objectForKey:@"message"]];
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:self->finalAddEmailIDBlock];
                                                                 
                                                             });
                                                        }else{
                                                            //failure handling...
                                                            DLog(@"Status: Failure Response");
                                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                            [userInfo setValue:@"Native Sign In Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSignInServerError userInfo:userInfo];
                                                            self->finalAddEmailIDBlock(returnError);
                                                        }
                                                    } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                        [self hideLoadingIndicator];
                                                        DLog(@"Failure Response");
                                                        [self handleSecondaryEmailError:errorType error:error failureBlock:self->finalAddEmailIDBlock];
                                                    }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}
#endif

-(void)sendOTPTo:(NSString*)mobileNumber
      countryCode:(NSString*)code
         forZUID:(NSString*)userZUID
     WithResponse:(ZSSOKitOTPCodeResponse)response {
    
    [self getTokenForZUID:userZUID WithSuccess:^(NSString *token) {
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
            [paramDict setValue:[code uppercaseString] forKey:@"country_code"];
            [paramDict setValue:mobileNumber forKey:@"mobile"];
       
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"screen_name"];

            NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
            [finalDict setValue:paramDict forKey:@"mobile"];
            
            NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
            [headerDict setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];

            [headerDict setValue:[self getUserAgentString] forKey:@"User-Agent"];

            [finalDict setValue:headerDict forKey:SSO_HTTPHeaders];

            NSString *nativeSigninURL = [NSString stringWithFormat:@"%@%@", [self getAccountsURLFromKeychainForZUID:userZUID],kSSOSendOTPMobile];
        [[SSONetworkManager sharedManager]sendJSONPOSTRequestForURL:nativeSigninURL parameters:finalDict successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 200 || [[jsonDict valueForKey:@"status_code"] intValue] == 201){

                NSString *mobileID = [jsonDict valueForKeyPath:@"mobile.mobile"];

                response(mobileID,nil);

            } else {

                NSString* errorMessage = [jsonDict valueForKey:@"localized_message"];

                if (!errorMessage) {
                    errorMessage = @"An error occurred while sending OTP your mobile number. Please try again.";
                }
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberSendOTPError userInfo:userInfo];
                response(nil,returnError);

            }
        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
            DLog(@"Failure Response");
            NSLog(@"register mobile %@", errorInfo);

                if (errorType == SSO_ERR_CONNECTION_FAILED) {
                    NSError* returnError = (NSError*)errorInfo ;
                    response(nil,returnError);

                }else if (errorType == SSO_ERR_SERVER_ERROR) {
                    NSString* errormessage = (NSString*) errorInfo;
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberSendOTPError userInfo:userInfo];
                    response(nil,returnError);

                } else {
                    NSString* errormessage = @"An error occurred while sending OTP your mobile number. Please try again.";
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberSendOTPError userInfo:userInfo];
                    response(nil, returnError);
                }
        }];
                                                         
    } andFailure:^(NSError *error) {
        response(nil, error);
    }];
    
}


-(void)resendOTPForMobilID:(NSString*)mobileID
         forZUID:(NSString*)userZUID
     WithResponse:(ZSSOKitErrorResponse)response {
    
    [self getTokenForZUID:userZUID WithSuccess:^(NSString *token) {
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
       
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"is_resend"];
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"screen_name"];
            NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
            [finalDict setValue:paramDict forKey:@"mobile"];
            
            NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
            [headerDict setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];

            [headerDict setValue:[self getUserAgentString] forKey:@"User-Agent"];

            [finalDict setValue:headerDict forKey:SSO_HTTPHeaders];

            NSString *nativeSigninURL = [NSString stringWithFormat:@"%@%@/%@", [self getAccountsURLFromKeychainForZUID:userZUID],kSSOSendOTPMobile, mobileID];
        
        [[SSONetworkManager sharedManager]sendJSONPUTRequestForURL:nativeSigninURL parameters:finalDict successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 200 || [[jsonDict valueForKey:@"status_code"] intValue] == 201){

                response(nil);

            } else {

                NSString* errorMessage = [jsonDict valueForKey:@"localized_message"];

                if (!errorMessage) {
                    errorMessage = @"An error occurred while resending OTP your mobile number. Please try again.";
                }
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberResendOTPError userInfo:userInfo];
                response(returnError);

            }
        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
            DLog(@"Failure Response");
            NSLog(@"register mobile %@", errorInfo);

                if (errorType == SSO_ERR_CONNECTION_FAILED) {
                    NSError* returnError = (NSError*)errorInfo ;
                    response(returnError);

                }else if (errorType == SSO_ERR_SERVER_ERROR) {
                    NSString* errormessage = (NSString*) errorInfo;
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberResendOTPError userInfo:userInfo];
                    response(returnError);

                } else {
                    NSString* errormessage = @"An error occurred while resending OTP your mobile number. Please try again.";
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberResendOTPError userInfo:userInfo];
                    response(returnError);
                }
        }];
                                                         
    } andFailure:^(NSError *error) {
        response( error);
    }];
    
}

-(void)verifyMobileD:(NSString*)mobileID
         WithOTPCode:(NSString *)otp
             forZUID:(NSString*)userZUID
            response:(ZSSOKitErrorResponse)response {
    
    [self getTokenForZUID:userZUID WithSuccess:^(NSString *token) {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
        
        [paramDict setValue:otp forKey:@"code"];
        [paramDict setValue:[NSNumber numberWithBool:NO] forKey:@"is_resend"];
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"screen_name"];
        
        NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
        [headerDict setValue:[self getUserAgentString] forKey:@"User-Agent"];
        [headerDict setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
        [finalDict setValue:paramDict forKey:@"mobile"];
        [finalDict setValue:headerDict forKey:SSO_HTTPHeaders];
        
        NSString *nativeSigninURL = [NSString stringWithFormat:@"%@%@/%@", [self getAccountsURLFromKeychainForZUID:userZUID],kSSOSendOTPMobile,mobileID];
        
        [[SSONetworkManager sharedManager]sendJSONPUTRequestForURL:nativeSigninURL parameters:finalDict successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 200 || [[jsonDict valueForKey:@"status_code"] intValue] == 201){
                NSLog(@"%@", jsonDict);
                response(nil);
                
            } else {
                NSString* errorMessage = [jsonDict valueForKey:@"localized_message"];
                
                if (!errorMessage) {
                    errorMessage = @"Verification failed. Please try again by resending the code.";

                }
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberVerifyError userInfo:userInfo];
                response( returnError);
                
            }
        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
            if (errorType == SSO_ERR_CONNECTION_FAILED) {
                NSError* returnError = (NSError*)errorInfo ;
                response(returnError);

            }else if (errorType == SSO_ERR_SERVER_ERROR) {
                NSString* errormessage = (NSString*) errorInfo;
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberVerifyError userInfo:userInfo];
                response(returnError);

            } else {
                NSString* errormessage = @"Verification failed. Please try again by resending the code.";
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberVerifyError userInfo:userInfo];
                response(returnError);
            }
        }];
    } andFailure:^(NSError *error) {
        response(error);
    }];
    
}

//Scope Enhancement
-(void)enhanceScopeWithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                    andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure{
    [self enhanceScopeForZuid:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
}
-(void)enhanceScopeForZuid:(NSString *)zuid WithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure{

    finalScopeEnhancementSuccessBlock = success;
    finalScopeEnhancementFailureBlock = failure;
    User_ZUID = zuid;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        if(self->isSSOAccessToken){
            success(token);
        }else{
            NSString* client_secret = [self getClientSecretFromKeychainForZUID:zuid];

            NSString *encoded_gt_sec=[self getEncodedStringForString:client_secret];

            //Add Parameters
            NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
            [paramsAndHeaders setValue:@"enhancement_scope" forKey:@"grant_type"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",self->ClientID] forKey:@"client_id"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",encoded_gt_sec] forKey:@"client_secret"];
            if(![ZIAMUtil sharedUtil].donotSendScopesParam){
                [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",self->Scopes] forKey:@"scope"];
            }

            //Add headers
            NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
            [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
            [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
            NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
            if(mdmToken){
                [headers setValue:mdmToken forKey:@"X-MDM-Token"];
            }

            [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

            #if !TARGET_OS_WATCH
            if (@available(iOS 11.0, *)) {
                DCDevice *device = [DCDevice currentDevice];
                if(device.isSupported){
                    [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
                        if(error == nil && token!=nil){
                            NSString *dcToken;
                            NSCharacterSet *urlChars = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
                            dcToken = [token base64EncodedStringWithOptions:0];
                            dcToken = [dcToken stringByAddingPercentEncodingWithAllowedCharacters:[urlChars invertedSet]];
                            [paramsAndHeaders setValue:dcToken forKey:@"device_verify_token"];
                            if([self->Service isEqualToString:kMDM_BundleID]){
                                [paramsAndHeaders setValue:@"mdm" forKey:@"appid"];
                            }else{
                                [paramsAndHeaders setValue:@"prd" forKey:@"appid"];
                            }

                            [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
                        }else{
                            //DCToken Error Fallback
                            [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
                        }
                    }];
                }else{
                    //DCToken Device not Supported fallback
                    [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
                }
            }else{
                // iOS 11 below fallback
                [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
            }
            #endif
        }
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

-(void)makeScopeEnhancementPostToServerHavingParams:(NSMutableDictionary *)paramsAndHeaders forZuid:(NSString *)zuid WithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                                         andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOScopeEnhancement_URL];
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:
     ^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
        //Request success
        if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
            DLog(@"Success Response ");
            NSString *scopeEnhancementAccessToken = [jsonDict objectForKey:@"scope_token"];
            
            NSString* enhancementPageURL = [NSString stringWithFormat:@"%@%@?client_id=%@&redirect_uri=%@&state=Test&response_type=code&access_type=offline&scope_token=%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOAddScope_URL,self->ClientID,self->UrlScheme,scopeEnhancementAccessToken];
            
            // exclude scopes for default scoped client
            if(![ZIAMUtil sharedUtil].donotSendScopesParam){
                enhancementPageURL = [enhancementPageURL stringByAppendingFormat:@"&scope=%@",self->Scopes];
            }
            self->ScopeEnhancementUrl = enhancementPageURL;
            //present SFSafari to show scope enhancement
            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
        }else{
            //failure handling...
            if([[jsonDict objectForKey:@"reason"] isEqualToString:@"scope_enhanced"]){
                //Scope Enhancement Success...
                [self getForceFetchOAuthTokenForZUID:self->User_ZUID success:self->finalScopeEnhancementSuccessBlock andFailure:self->finalScopeEnhancementFailureBlock];
                return;
            }else if([[jsonDict objectForKey:@"reason"] isEqualToString:@"scope_already_enhanced"]){
                //Scope Already Enhanceed error
                DLog(@"Scope Already Enhanceed");
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:@"Scope Already Enhanceed" forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementAlreadyDone userInfo:userInfo];
                failure(returnError);
                return;
            }
            DLog(@"Status: Failure Response");
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Get Extra Scope Server Error Occured" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementServerError userInfo:userInfo];
            failure(returnError);
            return;
        }
    } failureBlock:^(SSOInternalError errorType, NSError* error) {
        DLog(@"Failure Response");
        [self handleScopeEnhancementError:errorType error:error failureBlock:failure];
    }];
}


//AuthToOAuth
-(void)getOAuth2TokenUsingAuthToken:(NSString *)authtoken forApp:(NSString *)appName havingAccountsURL:(NSString *)accountsBaseURL havingSuccess:(requestSuccessBlock)success
                         andFailure:(requestFailureBlock)failure
{
    //enc_token Signature - clientidvalue__i__devicename__i_timestamp__i__authtoken__i__Test_App
    // Do any additional setup after loading the view.
    SSOKeyPairUtil *keygen= [[SSOKeyPairUtil alloc] init];
    [keygen setIdentifierForPublicKey:@"com.zoho.publicKey"
                           privateKey:@"com.zoho.privateKey"
                      serverPublicKey:@"com.zoho.serverPublicKey"];
    [keygen generateKeyPairRSA];

    //PublicKey to be Stored in IAM Server!
    NSString *oauthpub = [keygen getPublicKeyAsBase64ForJavaServer];
    oauthpub = [self getEncodedStringForString:oauthpub];



    /// NSLog(@"%@ %@ %ld",uaString,appName,millis);
    NSString *stringToBeEncrypted;
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
    double timePassed_ms = ([[NSDate date] timeIntervalSince1970] * 1000);
    stringToBeEncrypted = [NSString stringWithFormat:@"%@__i__%@__i__%.0f__i__%@__i__%@__i__%@__i__%@",[self deviceName],AppName,timePassed_ms,[[UIDevice currentDevice] name],ClientID,appName,authtoken];
#endif
#endif
    NSData *data = [stringToBeEncrypted dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [data AES128EncryptedDataWithKey:kSSOSHARED_SECRET];
    NSString *encryptedDataString = [encryptedData base64EncodedStringWithOptions:0];
    encryptedDataString = [self getEncodedStringForString:encryptedDataString];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",accountsBaseURL,kSSOAuthToOAuth_URL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
    [paramsAndHeaders setValue:encryptedDataString forKey:@"enc_token"];
    [paramsAndHeaders setValue:ClientID forKey:@"client_id"];
    [paramsAndHeaders setValue:oauthpub forKey:@"ss_id"];
    
    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:[[ZIAMUtil sharedUtil] getUserAgentString] forKey:@"User-Agent"];
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
    
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {

                                                    //Header for DCL Handling
                                                    if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
                                                        NSDictionary *dictionary = [httpResponse allHeaderFields];
                                                        if([dictionary objectForKey:@"X-Location-Meta"]){
                                                            NSString *base64EncodedString = [dictionary objectForKey:@"X-Location-Meta"];
                                                            NSData *bas64DCL_Meta_Data = [NSData dataFromBase64String:base64EncodedString];
                                                            self->setBas64DCL_Meta_Data=bas64DCL_Meta_Data;
                                                        }
                                                    }

                                                    //Request success
                                                    if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                                                        self->setAccountsServerURL = accountsBaseURL;
                                                        self->setAccessToken = [jsonDict objectForKey:@"access_token"];
                                                        self->setExpiresIn = [jsonDict objectForKey:@"expires_in"];
                                                        self->setLocation = [jsonDict objectForKey:@"location"];
                                                        self->setRefreshToken = [jsonDict objectForKey:@"rt_token"];

                                                        //Get the KeyPair!
                                                        SSOKeyPairUtil *keygen= [[SSOKeyPairUtil alloc] init];
                                                        [keygen setIdentifierForPublicKey:@"com.zoho.publicKey"
                                                                               privateKey:@"com.zoho.privateKey"
                                                                          serverPublicKey:@"com.zoho.serverPublicKey"];

                                                        NSString*  encrypted_gt_sec   =   [jsonDict objectForKey:@"gt_sec"];



                                                        NSData *granttokenData = [NSData dataFromBase64String:encrypted_gt_sec];

                                                        //Decrypt using private key
                                                        self->setClientSecret= [keygen decryptUsingPrivateKeyWithData:granttokenData];

                                                        [self fetchUserInfoWithBlock:^(NSError *error) {
                                                            if(error == nil){
                                                                //Success
                                                                DLog(@"Got profile info and stored items in keychain success");
                                                                success(self->setAccessToken);
                                                            }else{
                                                                //Error Occured...
                                                                failure(error);
                                                            }
                                                        }];


                                                    }else{
                                                        //failure handling...
                                                        DLog(@"Status: Failure Response");
                                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                        [userInfo setValue:@"Get OAuth from AuthToken Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAuthToOAuthServerError userInfo:userInfo];
                                                        failure(returnError);
                                                    }
                                                } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                    //Request failed

                                                    DLog(@"Failure Response");
                                                    [self handleAuthToOAuthError:errorType error:error failureBlock:failure];
                                                }];

}

-(void)checkAndLogout:(requestFailureBlock)logoutBlock{
    [self checkAndLogoutForZUID:[self getCurrentUserZUIDFromKeychain] handler:logoutBlock];
}
-(void)checkAndLogoutForZUID:(NSString *)zuid handler:(requestFailureBlock)logoutBlock{

    [self getForceFetchOAuthTokenForZUID:zuid success:^(NSString *token) {
        logoutBlock(nil);
    } andFailure:^(NSError *error) {
        if (([error code]== k_SSOTokenFetchError || [error code]== k_SSOOneAuthTokenFetchError) && [[error localizedDescription] isEqualToString:@"invalid_mobile_code"]) {
            [self clearDataForLogoutHavingZUID:zuid];
        }
        logoutBlock(error);
    }];
}

-(BOOL)getIsSignedInUsingSSOAccount{
    return [self checkifSSOAccountsMatchForZUID:[self getCurrentUserZUIDFromKeychain]];
}

-(BOOL)getIsSignedInUsingSSOAccountForZUID:(NSString *)zuid{
    return [self checkifSSOAccountsMatchForZUID:zuid];
}
//End of ZSSOKit Helpers

//Main Handler
-(void)processgetTokenForZuid:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure
{
    //Case1: OneAuth not installed but already Signed in--- Get token from this App's Keychain
    DLog(@"Checking for Case1: OneAuth not installed but already Signed in--- Get token from this App's Keychain");

    NSString* refresh_token = [self getRefreshTokenFromKeychainForZUID:zuid];

    if(refresh_token){
        if(ButtonClick){
            //Should not come here....
            int errorCode = k_SSOOldAccessTokenNotDeleted;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Old Access Token Not Deleted" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorCode userInfo:userInfo];
            failure(returnError);
            return;
        }
        NSData *access_token_data = [self getAccessTokenDataFromKeychainForZUID:zuid];
        //Get the CurrentTime!
        long long millis = [self getCurrentTimeMillis];

        NSMutableDictionary* accessTokenDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:access_token_data];
        NSArray* tokenArray = [accessTokenDictionary objectForKey:Scopes];
        //DLog(@"Keychain Dictionary objects test Token Final: %@",tokenArray[0]);
        NSString* timeStampString = tokenArray[1];

        long long timeStamp = [timeStampString longLongValue];
        if(wmsCallBack){
            expiresinMillis = timeStamp - millis;
            millis = millis + wmsTimeCheckMargin;
        }else{
            expiresinMillis = timeStamp - millis;
            millis = millis + timecheckbuffer;
        }

        DLog(@"Current Time:%ld TimeStamp:%ld",millis,timeStamp);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->isSSOAccessToken = NO;
        });
        if(millis < timeStamp){
            DLog(@"Time Check Success!!!");
            NSString* token = tokenArray[0];
            //Backward Compatability to set the is_using_ssoaccount boolean in keychain for respective app.
            [[ZIAMUtil sharedUtil] removeisAppUsingSSOAccount];
            success(token);
        }else{
            DLog(@"Time Check Failed!!!");
            [self processTokenFetchForZUID:zuid isSSOAccount:NO WithSuccess:success andFailure:failure];
        }
    }else{
        //Case1: OneAuth Already there and signed in----- Get token from shared keychain

        DLog(@"Checking for Case1");

        NSString *SSO_Zuid =[self getSSOZUIDFromSharedKeychain];

        NSString *AppCurrentUserZUID = [self getCurrentUserZUIDFromKeychain];

        //OneAuth Multi-Account Handling
        BOOL isZUIDAvailableInOneAuth = NO;
        NSData* SSO_ZuidsData = [self getSSOZUIDListFromSharedKeychain];
        if(SSO_ZuidsData){
            NSMutableArray* SSO_ZuidsArray = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:SSO_ZuidsData];
            if(zuid){
                isZUIDAvailableInOneAuth = [SSO_ZuidsArray containsObject:zuid];
//                for (id SSOZUID in SSO_ZuidsArray) {
//                    if([SSOZUID isEqualToString:zuid]){
//                        isZUIDAvailableInOneAuth = true;
//                    }
//                }
            }
        }else if(SSO_Zuid){
            isZUIDAvailableInOneAuth = [SSO_Zuid isEqualToString:zuid];
        }


        if(!isZUIDAvailableInOneAuth && zuid!=nil){
            if(![SSO_Zuid isEqualToString:AppCurrentUserZUID] && AppCurrentUserZUID!=nil){
                DLog(@"Account Mismatch");
                //Remove CurrentUser if this ZUID is the currentApp user...
                [self removeCurrentUserZUIDFromKeychain];
            }
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"OneAuth SSO Account Mismatch" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthAccountMismatch userInfo:userInfo];
            failure(returnError);
            return ;
        }
        NSString* sso_refresh_token;
        
       
        if(ButtonClick && !zuid){
            sso_refresh_token = [self getSSORefreshTokenFromSharedKeychainForZUID:SSO_Zuid];
        }else{
            sso_refresh_token = [self getSSORefreshTokenFromSharedKeychainForZUID:zuid];
        }
        
        if(sso_refresh_token){

            if([self checkIfUnauthorisedManagedMDMSSOAccount]){
                [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                return;
            }

            if(ButtonClick){
#if !SSO_APP__EXTENSION_API_ONLY
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentAccountChooserWithSuccess:success andFailure:failure havingSwitchSuccess:nil];
                });
                return;
#endif
            }

            NSData* access_token_data;
            //changes related to moving individual accesstokens to individual apps.
            if([self getAppSSOAccessTokenDataFromSharedKeychainForZUID:zuid]){
                access_token_data = [self getAppSSOAccessTokenDataFromSharedKeychainForZUID:zuid];
            }else{
                access_token_data = [self getSSOAccessTokenDataFromSharedKeychainForZUID:zuid];
            }

            //Get the CurrentTime!
            long long millis = [self getCurrentTimeMillis];

            NSMutableDictionary* accessTokenDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:access_token_data];
            NSString* overAllScopeKey;
            BOOL scopeFound = false;

            for (id key in accessTokenDictionary) {
                DLog(@"Dictionary Keys: %@",key);
                NSArray *overAllScopesArray = [key componentsSeparatedByString:@","];
                NSArray *appScopesArray = [Scopes componentsSeparatedByString:@","];

                NSSet *overAllSet = [NSSet setWithArray:overAllScopesArray];
                NSSet *scopeset = [NSSet setWithArray:appScopesArray];
                __block NSInteger count = 0;
                [overAllSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([scopeset containsObject:obj]){
                        count++;
                    }
                    if (count == [appScopesArray count]){
                        *stop = YES;

                    }
                }];

                if(count == [appScopesArray count])
                {
                    DLog(@"ScopeFound: %@ OverAllScope: %@",Scopes,key);
                    overAllScopeKey = key;
                    scopeFound = true;
                    break;
                }
            }
            //Fix : Storing this variable when any scope is missing(Enhance scope case)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->isSSOAccessToken = YES;
            });

            if(scopeFound){
                NSArray* tokenArray = [accessTokenDictionary objectForKey:Scopes];
                //DLog(@"One Auth Shared Keychain Dictionary objects test Token Final: %@",tokenArray[0]);
                NSString* timeStampString = tokenArray[1];
                long long timeStamp = [timeStampString longLongValue];
                DLog(@"One Auth Current Time:%ld TimeStamp:%ld",millis,timeStamp);
                if(wmsCallBack){
                    expiresinMillis = timeStamp - millis;
                    millis = millis + wmsTimeCheckMargin;
                }else{
                    expiresinMillis = timeStamp - millis;
                    millis = millis + timecheckbuffer;
                }
                if(millis < timeStamp){
                    DLog(@"One Auth Time Check Success!!!");
                    NSString* token = tokenArray[0];
                    //Backward Compatability to set the is_using_ssoaccount boolean in keychain for respective app.
                    if(![self isAppUsingSSOAccount] && ([Service isEqualToString:kDevelopment_BundleID] || [Service isEqualToString:kMDM_BundleID])){
                        [self setisAppUsingSSOAccount];
                    }
                    success(token);
                }else{
                    DLog(@"One Auth Time Check Failed!!!");
                    self->isSSOAccessToken = YES;
                    [self processTokenFetchForZUID:zuid isSSOAccount:YES WithSuccess:success andFailure:failure];
                }
            }else{
                DLog(@"Scope Not Found");
                self->isSSOAccessToken = YES;
                [self processTokenFetchForZUID:zuid isSSOAccount:YES WithSuccess:success andFailure:failure];
            }
        }else if(ButtonClick){

            [self isOneAuthInstalled:^(BOOL isValid) {
                if(isValid){
                    if([self checkIfUnauthorisedManagedMDMSSOAccount]){
                        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                        return;
                    }
                    //Case2: OneAuth there and and not signed in---- Open OneAuth in URL Scheme and reopen the source app. Source App should then call getToken.
                    DLog(@"Checking for Case2");
                    self->setFailureBlock = failure;
                    self->setSuccessBlock = success;
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *oneauthscheme = self->IAMURLScheme;
                        NSString* urlString = [NSString stringWithFormat:@"%@?scheme=%@&appname=%@",oneauthscheme,self->UrlScheme,self->AppName];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                    });
#endif
#endif
                }else{
                    [self isMyZohoInstalled:^(BOOL isValid) {
                        if(isValid){
                            if([self checkIfUnauthorisedManagedMDMSSOAccount]){
                                [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                                return;
                            }
                            //Case2: OneAuth there and and not signed in---- Open OneAuth in URL Scheme and reopen the source app. Source App should then call getToken.
                            DLog(@"Checking for Case2.1");
                            NSString *myzohoscheme;
                            if([self->Service isEqualToString:kDevelopment_BundleID] || [self->Service isEqualToString:kDevelopment_MyZoho_BundleID]){
                                myzohoscheme  = kMyZohoURLScheme;
                            }else{
                                myzohoscheme  = kMyZohoMDMURLScheme;
                            }
                            if(myzohoscheme)
                                DLog(@"MyZoho URLScheme:%@",myzohoscheme);
                            self->setFailureBlock = failure;
                            self->setSuccessBlock = success;
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString* urlString = [NSString stringWithFormat:@"%@?scheme=%@&appname=%@",myzohoscheme,self->UrlScheme,self->AppName];
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                            });
#endif
#endif
                        }else{
                            //Case4: OneAuth not there and not Signed in--- Open LoginWebViewController and then send the response token after successful login.
                            DLog(@"Checking for Case4");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                            });
                        }
                    }];
                }
            }];

        }else{
            
            //No need to removeisAppUsingSSOAccount during the blocked state, should handle that...
           
            if([self isAppUsingSSOAccount]){
                [self removeisAppUsingSSOAccount];
            }

            if([self isAppUsingMyZohoSSOAccount]){
                [self removeisAppUsingMyZohoSSOAccount];
            }
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"There is no Access Token" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONoAccessToken userInfo:userInfo];
            failure(returnError);
            return ;
        }
    }
}

-(void)verifySSOPasswordForZUID:(NSString*)zuid
                        success:(requestSuccessBlock)successBlock
                        failure:(requestFailureBlock)failureBlock {
    
    NSString *inc_token = self->inc_token;
    self->OneAuthTokenActivationURL = [NSString stringWithFormat:@"%@%@?redirect_uri=%@&inc_token=%@",[self getSSOAccountsURLFromKeychainForZUID:zuid],kSSOInactiveRefreshToken_URL,self->UrlScheme,inc_token];
    self->User_ZUID = zuid;
    //present SFSafari to show scope enhancement
    [self presentSSOSFSafariViewControllerWithSuccess:successBlock andFailure:failureBlock];
}
-(void)presentAccountChooserWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure havingSwitchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess{
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
    SSOUserAccountsTableViewController *accountListTableViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SSOStoryboard"
                                                             bundle: [NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]]];
    accountListTableViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:@"accountchooser"];

    NSData* user_details_data = [self getUserDetailsDataFromKeychain];
    int count;
    NSMutableDictionary*  userDetailsDictionary;
    if(user_details_data){
        userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        count =  (int)[userDetailsDictionary count];
    }else{
        count = 0;
    }

    if([self isHavingSSOAccount]){
        accountListTableViewController.isHavingSSOAccount = YES;
        count = count+1;
    }else{
        if (count == 0) {
            int errorCode = k_SSONoUsersFound;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"No Users Found" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorCode userInfo:userInfo];
            failure(returnError);
            return;
        }
        accountListTableViewController.isHavingSSOAccount = NO;
    }
    accountListTableViewController.count = count;
    accountListTableViewController.userDetailsDictionary = userDetailsDictionary;

    accountListTableViewController.success = success;
    accountListTableViewController.failure = failure;
    accountListTableViewController.switchSuccess = switchSuccess;

    NSString *CurrentUserZuid = [self getCurrentUserZUIDFromKeychain];
    accountListTableViewController.CurrentUserZUID = CurrentUserZuid;

    
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:accountListTableViewController];
        UIViewController *top = [self topViewController];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self->_shouldPresentInFormSheet) {
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        if(top){
            [top presentViewController:nav animated:YES completion:nil];
        }else{
            [[self getActiveWindow].rootViewController presentViewController:nav animated:YES completion:nil];
        }
    });

#endif
#endif

}

-(void)getForceFetchOAuthToken:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    [self getForceFetchOAuthTokenForZUID:[self getCurrentUserZUIDFromKeychain] success:success andFailure:failure];
}

-(void)getForceFetchOAuthTokenForZUID:(NSString *)zuid success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    if([self checkifSSOAccountsMatchForZUID:zuid]){
        [self getSSOForceFetchOAuthTokenWithSuccess:success andFailure:failure];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self processTokenFetchForZUID:zuid isSSOAccount:NO WithSuccess:success andFailure:failure];
        });
    }
}

-(void)getSSOForceFetchOAuthTokenWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->isSSOLogin = YES;
        [self processTokenFetchForZUID:[self getSSOZUIDFromSharedKeychain] isSSOAccount:YES WithSuccess:success andFailure:failure];
    });
}

-(void)getClientPortalUserTokenWithSuccess:(requestSuccessBlock)success
                                andFailure:(requestFailureBlock)failure{
    [self getClientPortalUserTokenForZUID:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
}
-(void)getClientPortalUserTokenForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success
                                andFailure:(requestFailureBlock)failure{
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        BOOL isSignedUsingSSO = [self checkifSSOAccountsMatchForZUID:zuid];

            //URL

            NSString *client_id;
            NSString* client_secret;
            NSString *accountsUrl;

            if(isSignedUsingSSO ){
                accountsUrl = [self getSSOAccountsURLFromKeychainForZUID:zuid];
                client_id = [self getClientIDFromSharedKeychain];
                client_secret = [self getSSOClientSecretFromSharedKeychainForZUID:zuid];
            }else{
                accountsUrl = [self getAccountsURLFromKeychain];
                client_id = self->ClientID;
                client_secret = [self getClientSecretFromKeychainForZUID:zuid];
            }
            NSString *urlString = [NSString stringWithFormat:@"%@%@",accountsUrl,kSSOClientPortalRemoteLogin_URL];
            NSString *encoded_gt_sec= [self getEncodedStringForString:client_secret];
            //Add Parameters
            NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
            [paramsAndHeaders setValue:@"enhancement_scope" forKey:@"grant_type"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",client_id] forKey:@"client_id"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",encoded_gt_sec] forKey:@"client_secret"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",client_id] forKey:@"client_id"];
            if(isSignedUsingSSO)
                [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",self->ClientID] forKey:@"remote_app_name"];

            //Add headers
            NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
            [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
            if(isSignedUsingSSO)
                [headers setValue: self->ClientID forKey:@"X-Client-Id"];
            [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
            NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
            if(mdmToken){
                [headers setValue:mdmToken forKey:@"X-MDM-Token"];
            }

            [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

            // Request....
            [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                          parameters: paramsAndHeaders
                                                        successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                            //Request success
                                                            if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                                                                DLog(@"Success Response ");
                                                                NSString *loginAccessToken = [jsonDict objectForKey:@"login_token"];
                                                                success(loginAccessToken);
                                                            }else{
                                                                //failure handling...
                                                                DLog(@"Status: Failure Response");
                                                                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                                [userInfo setValue:@"Get Remote LoginKey Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORemoteLoginServerError userInfo:userInfo];
                                                                failure(returnError);
                                                            }

                                                        } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                            //Request failed

                                                            DLog(@"Failure Response");
                                                            [self handleRemoteLoginError:errorType error:error failureBlock:failure];


                                                        }];
        } andFailure:^(NSError *error) {
            failure(error);
        }];
}

-(NSString*)getClientSecretForZUID:(NSString *)zuid {
    if ([self checkifSSOAccountsMatchForZUID:zuid]) {
        return [self getSSOClientSecretFromSharedKeychainForZUID:zuid];
    } else {
        return [self getClientSecretFromKeychainForZUID:zuid];
    }

}
-(NSString*)accountsURLForZUID:(NSString *)zuid {
    if ([self checkifSSOAccountsMatchForZUID:zuid]) {
        return [self getSSOAccountsURLFromKeychainForZUID:zuid];
    } else {
        return [self getAccountsURLFromKeychain];
    }
}

-(void)generateHandshakeIDHavingClientZID:(NSString *)clientZID WithSuccess:(requestSuccessBlock)success
                               andFailure:(requestFailureBlock)failure{
    [self generateHandshakeIDHavingClientZID:clientZID havingZUID:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
}

-(void)generateHandshakeIDHavingClientZID:(NSString *)clientZID havingZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success
                               andFailure:(requestFailureBlock)failure{
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:clientZID forKey:@"client_zid"];
        
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];

        
        BOOL isSSOLogin = [self checkifSSOAccountsMatchForZUID:zuid];
        
        if (isSSOLogin) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        
        //Make API
        // Request....
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOGenerateHandshakeID_URL];
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            
            DLog(@"Success Response ");
            NSString *handshakeid = [jsonDict objectForKey:@"handShakeId"];
            success(handshakeid);
            
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            //Request failed
            
            DLog(@"Failure Response");
            failure(error);
            
            
        }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getDeviceVerifyToken: (void (^)(NSString*))completionBlock {
    
#if !TARGET_OS_WATCH
    if (@available(iOS 11.0, *)) {
        DCDevice *device = [DCDevice currentDevice];
        if(device.isSupported){
            [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
                if(error == nil && token!=nil){
                    NSString *dcToken = [token base64EncodedStringWithOptions:0];
                    NSCharacterSet *urlChars = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
                    dcToken = [dcToken stringByAddingPercentEncodingWithAllowedCharacters:[urlChars invertedSet]];
                    completionBlock(dcToken);
                } else {
                    completionBlock(nil);
                }
            }];
        } else {
            completionBlock(nil);
        }
    } else {
        completionBlock(nil);
    }
#else
    completionBlock(nil);
#endif

}


-(void)activateRefreshTokenUsing:(NSString*)handshakeID
                      havingZUID:(NSString *)zuid
             ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                     WithSuccess:(requestSuccessBlock)success
                      andFailure:(requestFailureBlock)failure {
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:@"true" forKey:@"new_verify"];

        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
        NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        if(mdmToken){
            [headers setValue:mdmToken forKey:@"X-MDM-Token"];
        }
        
        BOOL isSSOLogin = [self checkifSSOAccountsMatchForZUID:zuid];
        
        if (isSSOLogin) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
 
        //Make API
        NSString *urlString = [NSString stringWithFormat:@"%@%@?handshakeId=%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOInternalTokenActivation_URL, handshakeID] ;
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            
            DLog(@"Success Response %@", jsonDict);
            
            if ([jsonDict objectForKey:@"activate_token"]) {
                BOOL activationSuccess = [[jsonDict objectForKey:@"activate_token"] boolValue];
                if (activationSuccess) {
                    success(token);
                } else {
                    // throw static error
        
                }
            }
            
            
            
        } failureBlock:^(SSOInternalError errorType, NSError* activateError) {
            //Request failed
            
            DLog(@"Failure Response");
                        
            if (activateError) {
                NSDictionary *userInfo = [activateError userInfo];
                if ([[userInfo valueForKey:@"error"] isEqualToString:@"unverified_device"]) {
                    
                    [self getDeviceVerifyToken:^(NSString *deviceToken) {
                        if (ignorePasswordVerification && deviceToken == nil ) {
                            //device token is nil. Device verification API will fail
                            failure(activateError);
                            return;
                        } else {
                            // Call device verify even though the devicetoken is nil. inc_token will be received in device verify api only.
                            [self verifyDeviceFor:zuid
                                      deviceToken:deviceToken
                             ignorePasswordVerification:ignorePasswordVerification
                                       completion:^(NSError *deviceVerifyError) {
                                if (deviceVerifyError) {
                                    failure(deviceVerifyError);
                                } else {
                                    //device verification success. Activate refresh token
                                    [self activateRefreshTokenUsing:handshakeID
                                                         havingZUID:zuid
                                               ignorePasswordPrompt:ignorePasswordVerification
                                                        WithSuccess:success
                                                         andFailure:failure];
                                }
                            }];
                        }
                        
                    }];
                    
                } else {
                    //throw error
                    failure(activateError);
                }
            } else {
                //throw error
                failure(activateError);
            }
            
            
        }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

-(void)verifyDeviceFor:(NSString*)zuid
           deviceToken:(NSString*)dcToken
ignorePasswordVerification:(BOOL)ignorePasswordVerification
            completion:(requestFailureBlock)completionBlock {
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        
        if([self->Service isEqualToString:kMDM_BundleID]){
            [paramsAndHeaders setValue:@"mdm" forKey:@"appid"];
        }else{
            [paramsAndHeaders setValue:@"prd" forKey:@"appid"];
        }
        
        if (dcToken) {
            [paramsAndHeaders setValue:dcToken forKey:@"device_verify_token"];
        }
        
        //Add Parameters
        [paramsAndHeaders setValue:@"0" forKey:@"deviceType"];
        [paramsAndHeaders setValue:self->UrlScheme forKey:@"redirect_uri"];
        
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
        NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        if(mdmToken){
            [headers setValue:mdmToken forKey:@"X-MDM-Token"];
        }
        
        BOOL isSSOLogin = [self checkifSSOAccountsMatchForZUID:zuid];
        
        if (isSSOLogin) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        
        //Make API
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSODeviceVerify_URL];
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            
            DLog(@"Success Response %@", jsonDict);
            
            NSString *activationStatus = [jsonDict objectForKey:@"status"];
            
            if ([activationStatus isEqualToString:@"success"]) {
                completionBlock(nil);
            } else {
                // get temp token and present safari
                
            }
            
            
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            //Request failed
            
            DLog(@"Failure Response");
            if (error) {
                NSDictionary *userInfo = [error userInfo];
                if ([[userInfo valueForKey:@"error"] isEqualToString:@"unverified_device"]) {
                
                    if (ignorePasswordVerification) {
                        completionBlock(error);
                    } else {
                        NSString *inc_token = [userInfo objectForKey:@"inc_token"];
                        [self promptDeviceVerificationFor:zuid having:inc_token completion:^(NSError *deviceCheckerror) {
                            if (deviceCheckerror == nil) {
                                completionBlock(nil);
                            } else {
                                completionBlock(deviceCheckerror);
                            }
                        }];
                    }
                    
                } else {
                    //throw static error
                    completionBlock(error);
                }
            } else {
                //throw static error
                completionBlock(error);
            }
        }];
    } andFailure:^(NSError *error) {
        completionBlock(error);
    }];
}


- (void)promptDeviceVerificationFor:(NSString*)zuid
                             having:(NSString*)tempToken
                            completion:(ZSSOKitErrorResponse)activationHandler {
    [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock = activationHandler;
    [ZIAMUtil sharedUtil]->deviceVerificationURL = [NSString stringWithFormat:@"%@%@?inc_token=%@",[[ZIAMUtil sharedUtil] getAccountsURLFromKeychainForZUID:zuid],kSSODeviceVerifyWebPage_URL,tempToken];
    //present SFSafari to show scope enhancement
    [[ZIAMUtil sharedUtil] presentSSOSFSafariViewControllerWithSuccess:nil  andFailure:nil];
}

-(void)fetchUserInfoWithBlock:(requestFailureBlock)errorBlock {
    if(self.donotfetchphoto){
        [self fetchUserInfoHavingContactsURL:nil WithBlock:errorBlock];
    }else{
        [self fetchUserInfoHavingContactsURL:ContactsUrl WithBlock:errorBlock];
    }
}
-(void)fetchUserInfoHavingContactsURL:(NSString *)contactsURL WithBlock:(requestFailureBlock)errorBlock{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",setAccountsServerURL,kSSOFetchUserInfo_URL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];

    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init ];
    [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",setAccessToken]
               forKey:@"Authorization"];
    [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }

    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendGETRequestForURL: urlString
                                                 parameters: paramsAndHeaders
                                               successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                   //Request success
                                                   self->setProfileInfoDict = jsonDict;
                                                   long long ZUID_long = [[self->setProfileInfoDict objectForKey:@"ZUID"] longLongValue];
                                                   NSString *ZUID =[NSString stringWithFormat: @"%lld", ZUID_long];
                                                   self->setMultiAccountZUID = ZUID;
                                                   NSString *transformedContactsURL;
                                                   if(self->setLocation){
                                                       [self setDCLLocation:self->setLocation inKeychainForZUID:ZUID];
                                                   }
                                                   if(self->setBas64DCL_Meta_Data && ([self->setBas64DCL_Meta_Data length]>0)){
                                                       [self setDCLMeta:self->setBas64DCL_Meta_Data inKeychainForZUID:ZUID];
                                                   }
                                                   if(contactsURL){
                                                       transformedContactsURL = [self transformURL:contactsURL ZUID:ZUID Location:self->setLocation];
                                                       [self fetchProfilePhotoHavingContactsURL:transformedContactsURL withBlock:errorBlock];
                                                   }else{
                                                       self->setProfileImageData = nil;
                                                       [self storeItemsInKeyChainOnSuccess];
                                                       errorBlock(nil);
                                                   }
                                               } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                   //Request failed
                                                   errorBlock(error);
                                               }];

}
-(void)fetchProfilePhoto:(requestFailureBlock)errorBlock {
    [self fetchProfilePhotoHavingContactsURL:ContactsUrl withBlock:errorBlock];
}
-(void)fetchProfilePhotoHavingContactsURL:(NSString *)contactsURL withBlock:(requestFailureBlock)errorBlock{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@",contactsURL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];

    //Add headers
    NSMutableDictionary *headers =[[NSMutableDictionary alloc] init];
    [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",setAccessToken] forKey:@"Authorization"];
    [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendGETRequestForURL: urlString
                                                 parameters: paramsAndHeaders
                                       successBlockWithData:^(NSData *data, NSHTTPURLResponse *httpResponse) {
                                           //Request success

                                           self->setProfileImageData = data;
                                           [self storeItemsInKeyChainOnSuccess];
                                           errorBlock(nil);


                                       } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                           //Request failed
                                           self->setProfileImageData = nil;
                                           [self storeItemsInKeyChainOnSuccess];
                                           errorBlock(nil);
                                       }];
}
-(void)forceFetchProfilePhotoForCurrentUserhavingAccessToken:(NSString *)accessToken withSuccessBlock:(photoSuccessBlock)successBlock withErrorBlock:(requestFailureBlock)errorBlock{
    [self fetchProfilePhotoHavingContactsURL:[self getTransformedURLStringForURL:ContactsUrl] havingAccessToken:accessToken withSuccessBlock:successBlock withErrorBlock:errorBlock];
}
-(void)fetchProfilePhotoHavingContactsURL:(NSString *)contactsURL havingAccessToken:(NSString *)accessToken withSuccessBlock:(photoSuccessBlock)successBlock withErrorBlock:(requestFailureBlock)errorBlock{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@",contactsURL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];

    //Add headers
    NSMutableDictionary *headers =[[NSMutableDictionary alloc] init];
    [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",accessToken] forKey:@"Authorization"];
    [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){
        [headers setValue:mdmToken forKey:@"X-MDM-Token"];
    }
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendGETRequestForURL: urlString
                                                 parameters: paramsAndHeaders
                                       successBlockWithData:^(NSData *data, NSHTTPURLResponse *httpResponse) {
                                           //Request success
                                           successBlock(data);
                                       } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                           //Request failed
                                           errorBlock(error);
                                       }];
}

-(void)presentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    [self checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:success andFailure:failure switchSuccess:nil];
}
-(void)checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure switchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess{
#if !SSO_APP__EXTENSION_API_ONLY
    [self isJailbroken:^(BOOL isValid) {
            if(isValid){
                NSString *continueTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.continue" Comment:@"Continue"];

                NSString *cancelTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.cancel" Comment:@"Cancel"];
                NSString *alertTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.rooted.alert" Comment:@"Your device is rooted. Proceed at your own risk since using a rooted device will make the app vulnerable to malicious attacks."];
                UIAlertController *alertController;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    alertController = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
                }else{
                    alertController = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                }
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDestructive handler:nil];
                UIAlertAction *continueAction = [UIAlertAction actionWithTitle:continueTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure switchSuccess:switchSuccess];

                }];
                [alertController addAction:continueAction];
                [alertController addAction:cancel];

                [[alertController popoverPresentationController] setSourceView:[self getActiveWindow].rootViewController.view];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *top = [self topViewController];
                    if(top){
                        [top presentViewController:alertController animated:YES completion:nil];
                    }else{
                        [[self getActiveWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
                    }
                });
            }else{
                [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure switchSuccess:switchSuccess];
            }
    }];
    
#endif

}
-(void)presentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure switchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess{
#if !SSO_APP__EXTENSION_API_ONLY
    dispatch_async(dispatch_get_main_queue(), ^{
    SSOSFSafariViewController *sfview = [[SSOSFSafariViewController alloc] init];
    sfview.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if(success)
        sfview.success = success;
    if(switchSuccess)
        sfview.switchSuccess = switchSuccess;
    sfview.failure = failure;

        UIViewController *top = [self topViewController];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self->_shouldPresentInFormSheet) {
            sfview.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        if(top){
            [top presentViewController:sfview animated:YES completion:nil];
        }else{
            [[self getActiveWindow].rootViewController presentViewController:sfview animated:YES completion:nil];
        }
    });
#endif
}

-(BOOL)checkifSSOAccountsMatchForZUID:(NSString *)zuid {
    BOOL isDeviceHavingOneAuthAccountLoggedIn = [self isHavingSSOAccount];
    BOOL thisAppLoggedInUsingSSOAccount = ([self isAppUsingSSOAccount] || [self isAppUsingMyZohoSSOAccount]);
    if(isDeviceHavingOneAuthAccountLoggedIn && thisAppLoggedInUsingSSOAccount){
        NSString *SSO_Zuid =[self getSSOZUIDFromSharedKeychain];
        //OneAuth Multi-Account Handling
        BOOL isZUIDAvailableInOneAuth = NO;
        NSData* SSO_ZuidsData = [self getSSOZUIDListFromSharedKeychain];
        if (SSO_ZuidsData) {
            //OneAuth 2.0 ZUIDs list available
            NSMutableArray* SSO_ZuidsArray = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:SSO_ZuidsData];
            if(zuid){
                for (id SSOZUID in SSO_ZuidsArray) {
                    if([SSOZUID isEqualToString:zuid]){
                        isZUIDAvailableInOneAuth = YES;
                        break;
                    }
                }
            }
        } else if(SSO_Zuid) {
            if([SSO_Zuid isEqualToString:zuid]){
                isZUIDAvailableInOneAuth = YES;
            }
        }
        return isZUIDAvailableInOneAuth;
    }
    return NO;
}


-(void)setRevokeFailedDueToNetworkError{
    [self setRevokeFailedDueToNetworkErrorInKeychain];
}




@end


