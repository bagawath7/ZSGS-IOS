//
//  ZIAMHelpers.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZIAMHelpers.h"
#import "ZIAMKeyChainUtil.h"
#import <sys/utsname.h>
#include <sys/time.h>
#include "ZIAMUtilConstants.h"
#if TARGET_OS_WATCH && !TARGET_OS_UIKITFORMAC
@import WatchKit;
#endif

@implementation ZIAMUtil(ZIAMHelpers)


-(void)initMode:(SSOBuildType)mode{
    
    if(mode == Live_SSO){
        Service = kDevelopment_BundleID;
        AccessGroup = kDevelopment_AppGroup;
        BaseUrl = kZoho_Base_URL;
        ContactsUrl = kCONTACTS_Zoho_PROFILE_PHOTO;
        IAMURLScheme = kOneAuthURLScheme;
    }else if(mode == Live_SSO_Mdm){
        Service = kMDM_BundleID;
        AccessGroup = kMDM_AppGroup;
        BaseUrl = kZoho_Base_URL;
        ContactsUrl = kCONTACTS_Zoho_PROFILE_PHOTO;
        IAMURLScheme = kOneAuthMDMURLScheme;
    }else if(mode == SKYDESK_Live){
        Service = kDevelopment_BundleID;
        AccessGroup = kDevelopment_AppGroup;
        BaseUrl = kAccountsSkyDesk_URL;
        ContactsUrl = kContactsSkyDesk_URL;
        IAMURLScheme = kOneAuthURLScheme;
    }else if(mode == CHARM_LIVE){
        Service = kDevelopment_BundleID;
        AccessGroup = kDevelopment_AppGroup;
        BaseUrl = kAccountsCharm_URL;
        ContactsUrl = kContactsCharm_URL;
        IAMURLScheme = kOneAuthURLScheme;
    } else {
        #if defined(SSO_LOCAL_MDM) || defined(DEBUG)

        if(mode == Local_SSO_Development){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kLocalZoho_Base_URL;
            ContactsUrl = kCONTACTS_Localzoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthURLScheme;
        }else if (mode == Local_SSO_Mdm){
            Service = kMDM_BundleID;
            AccessGroup = kMDM_AppGroup;
            BaseUrl = kLocalZoho_Base_URL;
            ContactsUrl = kCONTACTS_Localzoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthMDMURLScheme;
        }else if(mode == LocalDev_SSO_Development){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kLocalZoho_DEV_Base_URL;
            ContactsUrl = kCONTACTS_Localzoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthURLScheme;
        }else if(mode == CSEZ_SSO_Dev){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kCSEZ_Base_URL;
            ContactsUrl = kContacts_CSEZ_Base_URL;
            IAMURLScheme = kOneAuthURLScheme;
        }else if(mode == SKYDESK_PRE){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kAccountsSkyDeskPre_URL;
            ContactsUrl = kContactsSkyDeskPre_URL;
            IAMURLScheme = kOneAuthURLScheme;
        }else if (mode == iAccounts_SSO_MDM){
            Service = kMDM_BundleID;
            AccessGroup = kMDM_AppGroup;
            BaseUrl = kZoho_iAccounts_URL;
            ContactsUrl = kCONTACTS_prezoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthMDMURLScheme;
        }else if(mode == iAccounts_SSO_Dev){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kZoho_iAccounts_URL;
            ContactsUrl = kCONTACTS_prezoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthURLScheme;
        }else if (mode == PRE_SSO_MDM){
            Service = kMDM_BundleID;
            AccessGroup = kMDM_AppGroup;
            BaseUrl = kZoho_Pre_URL;
            ContactsUrl = kCONTACTS_prezoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthMDMURLScheme;
        }else if(mode == PRE_SSO_Dev){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kZoho_Pre_URL;
            ContactsUrl = kCONTACTS_prezoho_PROFILE_PHOTO;
            IAMURLScheme = kOneAuthURLScheme;
        }else if (mode == CSEZ_SSO_MDM){
            Service = kMDM_BundleID;
            AccessGroup = kMDM_AppGroup;
            BaseUrl = kCSEZ_Base_URL;
            ContactsUrl = kContacts_CSEZ_Base_URL;
            IAMURLScheme = kOneAuthMDMURLScheme;
        }else if(mode == SKYDESK_STAGE){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kAccountsSkyDeskStage_URL;
            ContactsUrl = kContactsSkyDeskStage_URL;
            IAMURLScheme = kOneAuthURLScheme;
        }else if(mode == CHARM_PRE){
            Service = kDevelopment_BundleID;
            AccessGroup = kDevelopment_AppGroup;
            BaseUrl = kAccountsCharmPre_URL;
            ContactsUrl = kContactsCharmPre_URL;
            IAMURLScheme = kOneAuthURLScheme;
        }
        #endif
    }
    
    //To handle the bundle id of OneAuth and Myzoho
    /*
    NSData* access_token_data;
    
    access_token_data = [self getSSOAccessTokenDataFromSharedKeychain];
    
    NSData* mz_access_token_data;
    if([IAMURLScheme isEqualToString:kOneAuthURLScheme]){
        mz_access_token_data = [self getSSOAccessTokenDataFromSharedKeychainForService:kDevelopment_MyZoho_BundleID];
    }else{
        mz_access_token_data = [self getSSOAccessTokenDataFromSharedKeychainForService:kMDM_MyZoho_BundleID];
    }
    
    if(!access_token_data){
        //There is no entry in shared keychain of OneAuth
        
        //To check if it is MDM or AppStore
        if([IAMURLScheme isEqualToString:kOneAuthURLScheme] || [IAMURLScheme isEqualToString:kMyZohoURLScheme]){
            
            if([self isAppUsingMyZohoSSOAccount] || mz_access_token_data){
                //Override service to MyZoho BundleID from OneAuth
                Service = kDevelopment_MyZoho_BundleID;
                //App is already using SSOAccount using MyZoho, so override urlscheme.
                IAMURLScheme = kMyZohoURLScheme;
            }
        }else{
            
            if([self isAppUsingMyZohoSSOAccount] || mz_access_token_data){
                //Override service to MyZoho BundleID from OneAuth
                Service = kMDM_MyZoho_BundleID;
                //App is already using SSOAccount using MyZoho, so override urlscheme.
                IAMURLScheme = kMyZohoMDMURLScheme;
            }
        }
    }else if([self isAppUsingMyZohoSSOAccount]){
        if([IAMURLScheme isEqualToString:kOneAuthURLScheme] || [IAMURLScheme isEqualToString:kMyZohoURLScheme]){
            Service = kDevelopment_MyZoho_BundleID;
            IAMURLScheme = kMyZohoURLScheme;
        }else{
            Service = kMDM_MyZoho_BundleID;
            IAMURLScheme = kMyZohoMDMURLScheme;
        }
    }
     */
}


-(NSString *)getEncodedStringForString:(NSString *)str{
    //Note have to change encoding format
    NSCharacterSet * queryKVSet = [NSCharacterSet
                                   characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "
                                   ].invertedSet;
    NSString *encoded_str = [str stringByAddingPercentEncodingWithAllowedCharacters:queryKVSet];
    //NSString *encoded_str=CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    return encoded_str;
}

-(void)storeItemsInKeyChainOnSuccess{
    long long ZUID_long = [[setProfileInfoDict objectForKey:@"ZUID"] longLongValue];
    DLog(@"ZUID : %lld",ZUID_long);
    
    
    
    NSString *DisplayName = [setProfileInfoDict objectForKey:@"Display_Name"];
    
    DLog(@"DN: %@",DisplayName);
    
    NSString *EmailId = [setProfileInfoDict objectForKey: @"Email"];
    
    DLog(@"Email: %@",EmailId);
    
    
    NSString *ZUID =[NSString stringWithFormat: @"%lld", ZUID_long];
    DLog(@" String ZUID : %@",ZUID);
    
    if([fsProvider isEqualToString:@"apple"]){
        NSString *siwa_UID = [self getSIWAUserIDFromKeychain];
        if(siwa_UID)
            [self setZUID:ZUID forSIWAUserIDInKeychain:[self getSIWAUserIDFromKeychain]];
    }
    
    NSString *firstName = [setProfileInfoDict objectForKey: @"First_Name"];
    NSString *lastName = [setProfileInfoDict objectForKey: @"Last_Name"];
    NSString *fullName;
    if(firstName && lastName){
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    }else if(firstName && !lastName){
        fullName = firstName;
    }else if (!firstName && lastName){
        fullName = lastName;
    }
    
    
    NSData* user_details_data = [self getUserDetailsDataFromKeychain];
    NSArray *userDetailArray;
    if(user_details_data){
        NSMutableDictionary* userDetailsDictionary;
        userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        
        if(setProfileImageData){
            if(DisplayName && EmailId && fullName)
                userDetailArray = @[DisplayName,EmailId,setProfileImageData,fullName];
        }else{
            if(DisplayName && EmailId && fullName)
                userDetailArray = @[DisplayName,EmailId,[NSNull null],fullName];
        }
        if(userDetailArray)
            [userDetailsDictionary setObject:userDetailArray forKey:ZUID];
        
        
        NSData *userDetailsdictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:userDetailsDictionary];
        
        [self setUserDetailsDataInKeychain:userDetailsdictionaryRep];
        [self setZUIDInKeyChain:ZUID atIndex:(int)[userDetailsDictionary count]];
    }else{
        NSMutableDictionary* userDetailsDictionary = [[NSMutableDictionary alloc]init];
        if(setProfileImageData){
            if(DisplayName && EmailId && fullName)
                userDetailArray = @[DisplayName,EmailId,setProfileImageData,fullName];
        }else{
            if(DisplayName && EmailId && fullName)
                userDetailArray = @[DisplayName,EmailId,[NSNull null],fullName];
        }
        if(userDetailArray)
            [userDetailsDictionary setObject:userDetailArray forKey:ZUID];
        NSData *userDetailsdictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:userDetailsDictionary];
        
        [self setUserDetailsDataInKeychain:userDetailsdictionaryRep];
        [self setZUIDInKeyChain:ZUID atIndex:1];
    }
    if(!isMultiAccountSignIn){
        [self setCurrentUserZUIDInKeychain:ZUID];
    }
    isMultiAccountSignIn = NO;
    long long millis = [self getCurrentTimeMillis];
    
    long long expiresIn = [setExpiresIn longLongValue];
    
    long long timeStampMillis = millis+expiresIn;
    
    NSString* timeStamp = [NSString stringWithFormat:@"%lld",timeStampMillis];
    
    NSArray *accessTokenArray = @[setAccessToken, timeStamp];
    NSMutableDictionary* access_token_dictionary = [NSMutableDictionary dictionaryWithObject:accessTokenArray forKey:Scopes];
    DLog(@"Dictionary check:%@",[access_token_dictionary objectForKey:Scopes]);
    
    NSData *dictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:access_token_dictionary];
    [self setAccessTokenData:dictionaryRep inKeychainForZUID:ZUID];
    
    [self setRefreshToken:setRefreshToken inKeychainForZUID:ZUID];
    
    [self setClientSecret:setClientSecret inKeychainForZUID:ZUID];
    
    [self setAccountsURL:setAccountsServerURL inKeychainForZUID:ZUID];
}

-(NSString *) GetLocalizedString:(NSString*)key Comment: (NSString*) comment {
    
    return NSLocalizedStringFromTableInBundle(key, @"SSO", [NSBundle bundleForClass:[self class]], comment);
}

-(void)showNetworkActivityIndicator{
#if !SSO_APP__EXTENSION_API_ONLY
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
#endif
}

-(void)hideNetworkActivityIndicator{
#if !SSO_APP__EXTENSION_API_ONLY
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
#endif
}

-(int)getUsersCount{
    NSData* user_details_data = [self getUserDetailsDataFromKeychain];
    if(user_details_data){
        NSMutableDictionary* userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        return (int)[userDetailsDictionary count];
    }else{
        return 0;
    }
}

-(NSArray*)getCurrentUserDetails{
    
    return [self getUserDetailsForZUID:[self getCurrentUserZUIDFromKeychain]];
}

-(NSArray*)getUserDetailsForZUID:(NSString *)ZUID{
    BOOL isHavingSSOAccount = NO;
    
    if([self isHavingSSOAccount]){
        isHavingSSOAccount = YES;
    }
    
    if(isHavingSSOAccount){
        NSString *SSO_Zuid =[self getSSOZUIDFromSharedKeychain];
        if([SSO_Zuid isEqualToString:ZUID]){
            NSMutableDictionary *SSOUserDetailsDictionary  = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:[self getSSOUserDetailsDataFromSharedKeychain]];
            NSArray *userdetailsArray = [SSOUserDetailsDictionary objectForKey:SSO_Zuid];
            return userdetailsArray;
        }
    }
    
    NSData* user_details_data = [self getUserDetailsDataFromKeychain];
    
    if(user_details_data){
        NSMutableDictionary* userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        NSArray *userdetailsArray = [userDetailsDictionary objectForKey:ZUID];
        return userdetailsArray;
    }else{
        return nil;
    }
    
}

-(BOOL)isHavingSSOAccount
{

    //Refactor this method based on OneAuthV2 multi account handling...
    NSData* SSO_ZuidsData = [self getSSOZUIDListFromSharedKeychain];
    NSMutableArray* SSO_ZuidsArray = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:SSO_ZuidsData];
    NSString *SSO_Zuid =[self getSSOZUIDFromSharedKeychain];
    if([SSO_ZuidsArray count] > 0 || SSO_Zuid){
        return YES;
    }else{
        return NO;
    }
}

-(long long)getCurrentTimeMillis{
    struct timeval time;
    gettimeofday(&time, NULL);
    long long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    return millis;
}

-(void)clearDataForSSOLogoutHavingZUID:(NSString*)ZUID {

    if([self isAppUsingSSOAccount]){
        [self removeisAppUsingSSOAccount];
    }

    if([self isAppUsingMyZohoSSOAccount]){
        [self removeisAppUsingMyZohoSSOAccount];
    }
    
    [self removeAppSSOAccessTokenDataFromSharedKeychainForZUID:ZUID];
    if([ZUID isEqualToString:[self getCurrentUserZUIDFromKeychain]]){
        [self removeCurrentUserZUIDFromKeychain];
    }
}

-(void)clearDataForDeletingSSOAccountHavingZUID:(NSString*)ZUID {
    //delete mapped details
    [self clearDataForSSOLogoutHavingZUID:ZUID];
    //delete refresh token also
    [self removeAppSSORefreshTokenDataFromSharedKeychainForZUID:ZUID];
}

-(void)clearDataForLogoutHavingZUID:(NSString *)ZUID{
    NSString *SIWA_UID = [self getSIWAUserIDFromKeychain];
    if(SIWA_UID) {
        [self removeZUIDFromKeychainForSIWAUID:SIWA_UID];
        [self removeSIWAUserIDFromKeychain];
        [self removeSIWAUserFirstNameFromKeychain];
        [self removeSIWAUserLastNameFromKeychain];
    }
    [self removeRefreshTokenFromKeychainForZUID:ZUID];
    [self removeAccessTokenDataFromKeychainForZUID:ZUID];
    [self removeCloseAccountTempTokenFromKeychainForZUID:ZUID];
    NSData* user_details_data = [self getUserDetailsDataFromKeychain];
    NSMutableDictionary*  userDetailsDictionary;
    if(user_details_data){
        userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        int deletedIndex;
        int i;
        if([userDetailsDictionary count]>1){
            for(i=1;i<=[userDetailsDictionary count];i++){
                NSString *checkZUID = [self getZUIDFromKeyChainForIndex:i];
                if([checkZUID isEqualToString:ZUID]){
                    deletedIndex = i;
                    [userDetailsDictionary removeObjectForKey:ZUID];
                    NSData *userDetailsdictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:userDetailsDictionary];
                    [self setUserDetailsDataInKeychain:userDetailsdictionaryRep];
                    //Re Order ZUID's Keys
                    for (i=deletedIndex; i<=[userDetailsDictionary count]; i++) {
                        NSString *ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:i+1];
                        [[ZIAMUtil sharedUtil] setZUIDInKeyChain:ZUID atIndex:i];
                    }
                    break;
                }
            }
        }else{
            [userDetailsDictionary removeObjectForKey:ZUID];
            [self removeUserDetailsDataFromKeychain];
        }
        //Delete the last index...
        [self removeZUIDFromKeyChainatIndex:(int)[userDetailsDictionary count]+1];
    }
    if([ZUID isEqualToString:[self getCurrentUserZUIDFromKeychain]]){
        [self removeCurrentUserZUIDFromKeychain];
        /*
        NSString *U0_ZUID;
        if([self isHavingSSOAccount] && ![[self getSSOZUIDFromSharedKeychain] isEqualToString:ZUID]){
            U0_ZUID = [self getSSOZUIDFromSharedKeychain];
        }else{
            U0_ZUID = [self getZUIDFromKeyChainForIndex:1];
        }
        if(U0_ZUID!= nil){
            [self setCurrentUserZUIDInKeychain:U0_ZUID];
        }
         */
    }
}

-(void) isOneAuthInstalled:(boolBlock)isInstalled
{
#if !SSO_APP__EXTENSION_API_ONLY
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *ourApplication = [UIApplication sharedApplication];
        NSString *ourPath = self->IAMURLScheme;
        NSURL *ourURL = [NSURL URLWithString:ourPath];
        if ([ourApplication canOpenURL:ourURL]) {
            isInstalled(YES);
        }
        else {
            isInstalled(NO);
        }
    });
#endif
}

-(void) isMyZohoInstalled:(boolBlock)isInstalled
{
#if !SSO_APP__EXTENSION_API_ONLY
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *ourApplication = [UIApplication sharedApplication];
        NSString *ourPath;
        if([self->Service isEqualToString:kDevelopment_BundleID] || [self->Service isEqualToString:kDevelopment_MyZoho_BundleID]){
            ourPath  = kMyZohoURLScheme;
        }else{
            ourPath  = kMyZohoMDMURLScheme;
        }
        
        NSURL *ourURL = [NSURL URLWithString:ourPath];
        if ([ourApplication canOpenURL:ourURL]) {
            isInstalled(YES);
        }
        else {
            isInstalled(NO);
        }
    });
#endif
}

#if (!SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH)
- (UIViewController*)topViewController {
    
    return [self topViewControllerWithRootViewController:[self getActiveWindow].rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
#endif

-(NSString *) getUserAgentString
{
    NSString *version =[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];//It will update depends on the build number
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *appversion = [NSString stringWithFormat:@"%@.%@",version,build];
#if !TARGET_OS_WATCH
    NSString* deviceModel = [self getEncodedStringForString:[self deviceName]];
    NSString *userAgent = [[NSString alloc] initWithFormat:@"ZohoSSO_%@/%@_%@ (iOS %@; Apple %@; ZC_iOS %@ Extension)",kSSOKitVersion,AppName,appversion,[[UIDevice currentDevice] systemVersion],deviceModel,[[UIDevice currentDevice] model]];
#else
    NSString *userAgent = [[NSString alloc] initWithFormat:@"ZohoSSO_%@/%@_%@ (%@ %@; %@)",kSSOKitVersion,AppName,appversion,[[WKInterfaceDevice currentDevice] systemName],[[WKInterfaceDevice currentDevice] systemVersion],[[WKInterfaceDevice currentDevice] model]];
#endif
    return userAgent;
}

- (NSString*) deviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    if (!deviceNamesByCode) {
        deviceNamesByCode = @{
            @"i386"      :                               @"Simulator",
            @"x86_64"    :                               @"Simulator",
            @"iPod1,1"   :                               @"iPod Touch",      // (Original)
            @"iPod2,1"   :                               @"iPod Touch",      // (Second Generation)
            @"iPod3,1"   :                               @"iPod Touch",      // (Third Generation)
            @"iPod4,1"   :                               @"iPod Touch",      // (Fourth Generation)
            @"iPod5,1":                                  @"iPod touch (5th generation)",
            @"iPod7,1":                                  @"iPod touch (6th generation)",
            @"iPod9,1":                                  @"iPod touch (7th generation)",
            @"iPhone3,1":                                @"iPhone 4",
            @"iPhone3,2":                               @"iPhone 4",
            @"iPhone3,3":                                @"iPhone 4",
            @"iPhone4,1":                                @"iPhone 4s",
            @"iPhone5,1":                                  @"iPhone 5",
            @"iPhone5,2":                                 @"iPhone 5",
            @"iPhone5,3":                                  @"iPhone 5c",
            @"iPhone5,4":                                @"iPhone 5c",
            @"iPhone6,1":                                @"iPhone 5s",
            @"iPhone6,2":                               @"iPhone 5s",
            @"iPhone7,2":                                @"iPhone 6",
            @"iPhone7,1":                                @"iPhone 6 Plus",
            @"iPhone8,1":                                @"iPhone 6s",
            @"iPhone8,2":                                @"iPhone 6s Plus",
            @"iPhone8,4":                                @"iPhone SE",
            @"iPhone9,1":                                @"iPhone 7",
            @"iPhone9,3":                                 @"iPhone 7",
            @"iPhone9,2":                                @"iPhone 7 Plus",
            @"iPhone9,4":                                 @"iPhone 7 Plus",
            @"iPhone10,1":                                @"iPhone 8",
            @"iPhone10,4":                                @"iPhone 8",
            @"iPhone10,2":                                @"iPhone 8 Plus",
            @"iPhone10,5":                                @"iPhone 8 Plus",
            @"iPhone10,3":                                @"iPhone X",
            @"iPhone10,6":                                @"iPhone X",
            @"iPhone11,2":                               @"iPhone XS",
            @"iPhone11,4":                               @"iPhone XS Max",
            @"iPhone11,6":                                @"iPhone XS Max",
            @"iPhone11,8":                               @"iPhone XR",
            @"iPhone12,1":                               @"iPhone 11",
            @"iPhone12,3":                               @"iPhone 11 Pro",
            @"iPhone12,5":                               @"iPhone 11 Pro Max",
            @"iPhone12,8":                               @"iPhone SE (2nd generation)",
            @"iPhone13,1":                               @"iPhone 12 mini",
            @"iPhone13,2":                               @"iPhone 12",
            @"iPhone13,3":                               @"iPhone 12 Pro",
            @"iPhone13,4":                               @"iPhone 12 Pro Max",
            @"iPad2,1":                              @"iPad 2",
            @"iPad2,2":                              @"iPad 2",
            @"iPad2,3":                              @"iPad 2",
            @"iPad2,4":                              @"iPad 2",
            @"iPad3,1":                               @"iPad (3rd generation)",
            @"iPad3,2":                               @"iPad (3rd generation)",
            @"iPad3,3":                               @"iPad (3rd generation)",
            @"iPad3,4":                               @"iPad (3rd generation)",
            @"iPad3,5":                               @"iPad (3rd generation)",
            @"iPad3,6":                               @"iPad (4th generation)",
            @"iPad6,11":                             @"iPad (5th generation)",
            @"iPad6,12":                             @"iPad (5th generation)",
            @"iPad7,5":                               @"iPad (6th generation)",
            @"iPad7,6":                               @"iPad (6th generation)",
            @"iPad7,11":                             @"iPad (7th generation)",
            @"iPad7,12":                             @"iPad (7th generation)",
            @"iPad11,6":                             @"iPad (8th generation)",
            @"iPad11,7":                             @"iPad (8th generation)",
            @"iPad4,1":                               @"iPad Air",
            @"iPad4,2":                               @"iPad Air",
            @"iPad4,3":                               @"iPad Air",
            @"iPad5,3":                               @"iPad Air 2",
            @"iPad5,4":                               @"iPad Air 2",
            @"iPad11,3":                             @"iPad Air (3rd generation)",
            @"iPad11,4":                             @"iPad Air (3rd generation)",
            @"iPad13,1":                             @"iPad Air (4th generation)",
            @"iPad13,2":                             @"iPad Air (4th generation)",
            @"iPad2,5":                          @"iPad mini",
            @"iPad2,6":                               @"iPad mini",
            @"iPad2,7":                               @"iPad mini",
            @"iPad4,4":                               @"iPad mini 2",
            @"iPad4,5":                               @"iPad mini 2",
            @"iPad4,6":                               @"iPad mini 2",
            @"iPad4,7":                               @"iPad mini 3",
            @"iPad4,8":                               @"iPad mini 3",
            @"iPad4,9":                               @"iPad mini 3",
            @"iPad5,1":                               @"iPad mini 4",
            @"iPad5,2":                               @"iPad mini 4",
            @"iPad11,1":                             @"iPad mini (5th generation)",
            @"iPad11,2":                             @"iPad mini (5th generation)",
            @"iPad6,3":                               @"iPad Pro (9.7-inch)",
            @"iPad6,4":                               @"iPad Pro (9.7-inch)",
            @"iPad7,3":                               @"iPad Pro (10.5-inch)",
            @"iPad7,4":                               @"iPad Pro (10.5-inch)",
            @"iPad8,1":                              @"iPad Pro (11-inch) (1st generation)",
            @"iPad8,2":                              @"iPad Pro (11-inch) (1st generation)",
            @"iPad8,3":                              @"iPad Pro (11-inch) (1st generation)",
            @"iPad8,4":                              @"iPad Pro (11-inch) (1st generation)",
            @"iPad8,9":                              @"iPad Pro (11-inch) (2nd generation)",
            @"iPad8,10":                              @"iPad Pro (11-inch) (2nd generation)",
            @"iPad6,7":                               @"iPad Pro (12.9-inch) (1st generation)",
            @"iPad6,8":                               @"iPad Pro (12.9-inch) (1st generation)",
            @"iPad7,1":                               @"iPad Pro (12.9-inch) (2nd generation)",
            @"iPad7,2":                               @"iPad Pro (12.9-inch) (2nd generation)",
            @"iPad8,5":                              @"iPad Pro (12.9-inch) (3rd generation)",
            @"iPad8,6":                              @"iPad Pro (12.9-inch) (3rd generation)",
            @"iPad8,7":                              @"iPad Pro (12.9-inch) (3rd generation)",
            @"iPad8,8":                              @"iPad Pro (12.9-inch) (3rd generation)",
            @"iPad8,11":                             @"iPad Pro (12.9-inch) (4th generation)",
            @"iPad8,12":                             @"iPad Pro (12.9-inch) (4th generation)"
        };
    }
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    if(deviceName){
        return deviceName;
    }else{
        return code;
    }
}

-(NSString *)getMDMDefaultDC{
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:constkManagedMDMConfigurationKey];
    return serverConfig[constkManagedMDMConfigurationDefaultDCConditionalAccessKey];
}

-(NSString *)getMDMToken{
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:constkManagedMDMConfigurationKey];
    return serverConfig[constkManagedMDMConfigurationRestrictLoginConditionalAccessKey];
}

-(NSString *)getManagedMDMLoginID{
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:constkManagedMDMConfigurationKey];
    return serverConfig[constkManagedMDMConfigurationLoginIDKey];
    //return @"kumareshwaran.s@zohocorp.com";
}

-(BOOL)isMangedMDMRestrictedLogin{
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:constkManagedMDMConfigurationKey];
    return [serverConfig[constkManagedMDMConfigurationRestrictLoginKey] boolValue];
    //return YES;
}

-(BOOL)checkIfUnauthorisedManagedMDMAccount{
    if([self getManagedMDMLoginID]){
        ZSSOUser *ZUser = [self getCurrentUser];
        ZSSOProfileData *profile = ZUser.profile;
        NSString *loggedInUserEmail = profile.email;
        return [self checkIfUnauthorisedManagedMDMAccountForEmailID:loggedInUserEmail];
    }
    return NO;
}

-(BOOL)checkIfUnauthorisedManagedMDMSSOAccount{
    if([self getManagedMDMLoginID]){
        NSString *SSO_Zuid =[[ZIAMUtil sharedUtil] getSSOZUIDFromSharedKeychain];
        NSMutableDictionary *SSOUserDetailsDictionary  = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:[[ZIAMUtil sharedUtil] getSSOUserDetailsDataFromSharedKeychain]];
        
        NSArray *userdetailsArray = [SSOUserDetailsDictionary objectForKey:SSO_Zuid];
        
        NSString *loggedInUserEmail = [userdetailsArray objectAtIndex:1];
        return [self checkIfUnauthorisedManagedMDMAccountForEmailID:loggedInUserEmail];
    }
    return NO;
}

-(BOOL)checkIfUnauthorisedManagedMDMAccountForEmailID:(NSString *)loggedInUserEmail{
    NSString *managedMDMUserEmail = [self getManagedMDMLoginID];
    if(managedMDMUserEmail && [self isMangedMDMRestrictedLogin]){
        return ![loggedInUserEmail isEqualToString:managedMDMUserEmail];
    }
    return NO;
}

-(BOOL) isChineseLocale
{
    NSString *locale = [self getDeviceLocale];
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return ([locale containsString:@"zh"] || [countryCode isEqualToString:@"CN"]);
}

-(NSString *) getDeviceLocale
{
    NSString *deviceLang = [NSLocale preferredLanguages][0];
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:deviceLang];
    deviceLang = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
    return deviceLang;
}

-(BOOL) isEmpty:(id) data
{
    if ([self isNull:data])
    {
        return true;
    }
    if([data isKindOfClass:[NSString class]])
    {
        data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return  ([data respondsToSelector:@selector(length)] && [data length] == 0) ||
    ([data respondsToSelector:@selector(count)] && [data count] == 0);
}
-(BOOL) isNull:(id) data
{
    return (data == nil ||
            [data isKindOfClass:[NSNull class]] || ([data isKindOfClass:[NSString class]] && [data isEqualToString:@"null"]));
}
-(void) isJailbroken:(boolBlock)isJailBroken{
#if !SSO_APP__EXTENSION_API_ONLY &&  !(TARGET_IPHONE_SIMULATOR) && !TARGET_OS_UIKITFORMAC && !TARGET_OS_
    dispatch_async(dispatch_get_main_queue(), ^{
        // Excluding the iOS apps running on M1 Mac
        BOOL isiOSAppOnMac = false;
        if (@available(iOS 14.0, *)) {
            isiOSAppOnMac = [NSProcessInfo processInfo].isiOSAppOnMac;
        }
        if(isiOSAppOnMac){
            isJailBroken(NO);
            return;
        }
        
        // Check 1 : existence of files that are common for jailbroken devices
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
            [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
            [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]) {
            isJailBroken(YES);
            return;
        }
        FILE *f = NULL ;
        if ((f = fopen("/bin/bash", "r")) ||
            (f = fopen("/Applications/Cydia.app", "r")) ||
            (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
            (f = fopen("/usr/sbin/sshd", "r")) ||
            (f = fopen("/etc/apt", "r"))) {
            fclose(f);
            isJailBroken(YES);
            return;
        }
        fclose(f);
        // Check 2 : Reading and writing in system directories (sandbox violation)
        NSError *error;
        NSString *stringToBeWritten = @"Jailbreak Test.";
        [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES
                              encoding:NSUTF8StringEncoding error:&error];
        if(error==nil){
            //Device is jailbroken
            isJailBroken(YES);
            return;
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
        }
        
        isJailBroken(NO);
        return;
    });
#else
    isJailBroken(NO);
#endif
}

-(NSMutableDictionary *)getUserInfoFromError:(NSError *)error{
    NSString *errorMessage = [error.userInfo valueForKey:@"error"];
    if (!errorMessage) {
        errorMessage = @"error";
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
    return userInfo;
}
@end