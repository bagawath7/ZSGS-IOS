//
//  SSONetworkManager.h
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 07/02/17.
//  Copyright © 2017 Zoho. All rights reserved.
//

#define SSO_HTTPHeaders @"SSO_HTTPHeaders"
#import <Foundation/Foundation.h>

/*!
 @typedef SSOInternalError
 @brief Types of error handled in every API calls.
 */
typedef NS_ENUM(NSInteger, SSOInternalError) {
    SSO_ERR_JSONPARSE_FAILED,
    SSO_ERR_JSON_NIL,
    SSO_ERR_SERVER_ERROR,
    SSO_ERR_CONNECTION_FAILED,
    SSO_ERR_NOTHING_WAS_RECEIVED

};

@interface SSONetworkManager : NSObject

+(SSONetworkManager*)sharedManager;

-(void)sendPOSTRequestForURL:(NSString*)urlString
                  parameters:(NSDictionary*)params
                successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed;

-(void)sendGETRequestForURL:(NSString*)urlString
                 parameters:(NSDictionary*)params
               successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
               failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed;

-(void)sendGETRequestForURL:(NSString*)urlString
                 parameters:(NSDictionary*)params
       successBlockWithData:(void (^)(NSData* data, NSHTTPURLResponse *httpResponse))success
               failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed;
-(void)sendJSONPOSTRequestForURL:(NSString*)urlString
  parameters:(NSDictionary*)params
successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                    failureBlock:(void (^)(SSOInternalError errorType, NSError* errorInfo))failed;


-(void)sendJSONPUTRequestForURL:(NSString*)urlString
                     parameters:(NSDictionary*)params
                   successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                   failureBlock:(void (^)(SSOInternalError errorType, id errorInfo))failed;
@end
