//
//  SSOKeyPairUtil.h
//  IAM_SSO
//
//  Created by Kumareshwaran  on 22/12/14.
//  Copyright (c) 2014 Zoho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define privatekeyTag			"com.zoho.privateKey"

#define kChosenDigestLength		CC_SHA1_DIGEST_LENGTH
static const uint8_t privateKeyIdentifier[]		= privatekeyTag;


@interface SSOKeyPairUtil : NSObject

- (void)setIdentifierForPublicKey:(NSString *)pubIdentifier
                       privateKey:(NSString *)privIdentifier
                  serverPublicKey:(NSString *)servPublicIdentifier;
- (void)generateKeyPairRSA;
- (NSString *)getPublicKeyAsBase64ForJavaServer;
- (NSData *)getSignatureBytes:(NSData *)plainText;
- (SecKeyRef)getPrivateKeyRef;
-(NSData*) PKCSSignBytesSHA1withRSA:(NSData*) plainData;
- (NSString *)encryptUsingPrivateKeyWithData:(NSData*)data;
- (NSString *)decryptUsingPrivateKeyWithData:(NSData*)data;
- (NSString *)encryptUsingPublicKeyWithData:(NSData*)data;
@end

