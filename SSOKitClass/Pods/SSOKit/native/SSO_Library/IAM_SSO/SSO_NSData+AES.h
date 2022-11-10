//
//  SSO_NSData+AES.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 8/4/15.
//  Copyright © 2015 Zoho. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key;
- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv;

@end
