//
//  SSOKeyPairUtil.m
//  IAM_SSO
//
//  Created by Kumareshwaran  on 22/12/14.
//  Copyright (c) 2014 Zoho. All rights reserved.
//

#import "SSOKeyPairUtil.h"
#import "ZIAMUtilConstants.h"
#import <CommonCrypto/CommonDigest.h>
const size_t kSecAttrKeySizeInBitsLength = 2024;

@interface SSOKeyPairUtil (){
@private
    NSData * publicTag;
    NSData * privateTag;
    NSData * serverPublicTag;
    NSOperationQueue * cryptoQueue;
}

@property (strong, nonatomic) NSString * publicIdentifier;
@property (strong, nonatomic) NSString * privateIdentifier;
@property (strong, nonatomic) NSString * serverPublicIdentifier;


@property (nonatomic,readonly) SecKeyRef publicKeyRef;
@property (nonatomic,readonly) SecKeyRef privateKeyRef;
@property (nonatomic,readonly) SecKeyRef serverPublicRef;

@property (nonatomic,readonly) NSData   * publicKeyBits;
@property (nonatomic,readonly) NSData   * privateKeyBits;
@end

@implementation SSOKeyPairUtil
@synthesize publicKeyRef, privateKeyRef, serverPublicRef;

- (void)setIdentifierForPublicKey:(NSString *)pubIdentifier
                       privateKey:(NSString *)privIdentifier
                  serverPublicKey:(NSString *)servPublicIdentifier {
    
    self.publicIdentifier       = pubIdentifier;
    self.privateIdentifier      = privIdentifier;
    self.serverPublicIdentifier = servPublicIdentifier;
    
    // Tag data to search for keys.
    publicTag       = [self.publicIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    privateTag      = [self.privateIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    serverPublicTag = [self.serverPublicIdentifier dataUsingEncoding:NSUTF8StringEncoding];
}
- (void)generateKeyPairRSA {
    OSStatus sanityCheck = noErr;
    publicKeyRef = NULL;
    privateKeyRef = NULL;
    
    [self deleteAsymmetricKeys];
    
    // Container dictionaries.
    NSMutableDictionary * privateKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * publicKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * keyPairAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set top level dictionary for the keypair.
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:kSecAttrKeySizeInBitsLength] forKey:(__bridge id)kSecAttrKeySizeInBits];
    [keyPairAttr setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
    
    // Set the private key dictionary.
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [privateKeyAttr setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
    // See SecKey.h to set other flag values.
    
    // Set the public key dictionary.
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [publicKeyAttr setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
    // See SecKey.h to set other flag values.
    
    // Set attributes to top level dictionary.
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    //[keyPairAttr setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
    
    // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
    sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
    if(sanityCheck != noErr && publicKeyRef == NULL && privateKeyRef == NULL){
        DLog(@"Something really bad went wrong with generating the key pair.");
    }
    //LOGGING_FACILITY( sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL, @"Something really bad went wrong with generating the key pair." );
    
    //PublicKey *publicKey = [[KeyMaster getPublicKey] retain];
    // PrivateKey *privateKey = [[PrivateKey alloc]init:[self privateKeyRef]];
    
    
}
+(NSData*) privateKeyTag {
    static NSData* priKey = nil;
    if (priKey == nil) {
        priKey = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
    }
    return priKey;
}


+(SecKeyRef) privateKeyRef {
    static SecKeyRef priKey = nil;
    if (priKey == nil) {
        OSStatus sanityCheck = noErr;
        NSData* privateTag = [self privateKeyTag];
        NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
        
        // Set the private key query dictionary.
        [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        
        // Get the key.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&priKey);
        
        if (sanityCheck != noErr)
        {
            priKey = NULL;
        }
        
        //[queryPrivateKey release];
    }
    return priKey;
}
#pragma mark - Deletion

- (void)deleteAsymmetricKeys {
    
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey        = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * queryPrivateKey       = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * queryServPublicKey    = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Set the server public key query dictionary.
    [queryServPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryServPublicKey setObject:serverPublicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryServPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Delete the private key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    if(sanityCheck != noErr || sanityCheck != errSecItemNotFound){
        DLog(@"Error removing private key, OSStatus == %ld.", (long)sanityCheck);
    }
    // LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing private key, OSStatus == %ld.", (long)sanityCheck );
    
    // Delete the public key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    if(sanityCheck != noErr || sanityCheck != errSecItemNotFound){
        DLog(@"Error removing public key, OSStatus == %ld.", (long)sanityCheck);
    }
    //LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing public key, OSStatus == %ld.", (long)sanityCheck );
    
    // Delete the server public key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryServPublicKey);
    if(sanityCheck != noErr || sanityCheck != errSecItemNotFound){
        DLog(@"Error removing server public key, OSStatus == %ld.", (long)sanityCheck);
    }
    //LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing server public key, OSStatus == %ld.", (long)sanityCheck );
    
    
    if (publicKeyRef) CFRelease(publicKeyRef);
    if (privateKeyRef) CFRelease(privateKeyRef);
    if (serverPublicRef) CFRelease(serverPublicRef);
}


- (NSData *)readKeyBits:(NSData *)tag keyType:(CFTypeRef)keyType {
    
    OSStatus sanityCheck = noErr;
    CFTypeRef  _publicKeyBitsReference = NULL;
    
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:tag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)keyType forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&_publicKeyBitsReference);
    
    if (sanityCheck != noErr) {
        _publicKeyBitsReference = NULL;
    }
    
    publicKeyRef = (SecKeyRef)_publicKeyBitsReference;
    
    return (__bridge NSData*)_publicKeyBitsReference;
    
}

- (NSData *)publicKeyBits {
    return [self readKeyBits:publicTag keyType:kSecAttrKeyTypeRSA];
}

- (NSData *)privateKeyBits {
    return [self readKeyBits:privateTag keyType:kSecAttrKeyTypeRSA];
}

- (NSData *)serverPublicBits {
    return [self readKeyBits:serverPublicTag keyType:kSecAttrKeyTypeRSA];
}
- (NSString *)getPublicKeyAsBase64ForJavaServer {
    // NSData* data = [@"0HA" dataUsingEncoding:NSUTF8StringEncoding];
    //DLog(@"NSData: %@",data);
    //return @"hi";
    return [self getKeyForJavaServer:[self publicKeyBits]];
}
- (NSString *)getKeyForJavaServer:(NSData*)keyBits {
    
    static const unsigned char _encodedRSAEncryptionOID[15] = {
        
        /* Sequence of length 0xd made up of OID followed by NULL */
        0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
        
    };
    
    // That gives us the "BITSTRING component of a full DER
    // encoded RSA public key - We now need to build the rest
    
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringEncLength;
    
    // When we get to the bitstring - how will we encode it?
    
    if  ([keyBits length ] + 1  < 128 )
        bitstringEncLength = 1 ;
    else
        bitstringEncLength = (int)(([keyBits length ] +1 ) / 256 ) + 2 ;
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 2 + bitstringEncLength +
    [keyBits length];
    size_t j = encodeLength(&builder[1], i);
    [encKey appendBytes:builder length:j +1];
    
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID
                 length:sizeof(_encodedRSAEncryptionOID)];
    
    // Now add the bitstring
    builder[0] = 0x03;
    j = encodeLength(&builder[1], [keyBits length] + 1);
    builder[j+1] = 0x00;
    [encKey appendBytes:builder length:j + 2];
    
    // Now the actual key
    [encKey appendData:keyBits];
    
    // base64 encode encKey and return
    return [encKey base64EncodedStringWithOptions:0];
    
}

size_t encodeLength(unsigned char * buf, size_t length) {
    
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j) {
        buf[i - j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i + 1;
}


- (NSString *)decryptUsingPrivateKeyWithData:(NSData*)data{
    return [self rsaDecryptWithData:data usingPublicKey:NO];
}

- (NSString *)rsaDecryptWithData:(NSData*)data usingPublicKey:(BOOL)yes{
    NSData *wrappedSymmetricKey = data;
    //  SecKeyRef key = [self getPrivateKeyReference:@"privateKey"];
    
    //    key = [self getPrivateKeyRef]; // reejo remove
    SecKeyRef key = [self getPrivateKeyRef];
    
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    size_t keyBufferSize = [wrappedSymmetricKey length];
    
    
    
    NSMutableData *bits = [NSMutableData dataWithLength:keyBufferSize];
    OSStatus sanityCheck = SecKeyDecrypt(key,
                                         kSecPaddingPKCS1,
                                         (const uint8_t *) [wrappedSymmetricKey bytes],
                                         cipherBufferSize,
                                         [bits mutableBytes],
                                         &keyBufferSize);
    
    if (sanityCheck != 0) {
        //NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:sanityCheck userInfo:nil];
        // DLog(@"Error: %@", [error description]);
        
    }
    
    NSAssert(sanityCheck == noErr, @"Error decrypting, OSStatus == %ld.", (long)sanityCheck);
    
    [bits setLength:keyBufferSize];
    
    return [[NSString alloc] initWithData:bits
                                 encoding:NSUTF8StringEncoding];
}
- (SecKeyRef)getPrivateKeyRef {
    OSStatus sanityCheck = noErr;
    SecKeyRef privateKeyReference = NULL;
    
    if (privateKeyRef == NULL) {
        NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
        
        // Set the private key query dictionary.
        [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        
        // Get the key.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyReference);
        
        if (sanityCheck != noErr)
        {
            privateKeyReference = NULL;
        }
        
        // [queryPrivateKey release];
    } else {
        privateKeyReference = privateKeyRef;
    }
    
    return privateKeyReference;
}
- (SecKeyRef)getPublicKeyRef {
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyReference = NULL;
    
    if (publicKeyRef == NULL) {
        NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
        
        // Set the public key query dictionary.
        [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        
        // Get the key.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyReference);
        
        if (sanityCheck != noErr)
        {
            publicKeyReference = NULL;
        }
        
        //[queryPublicKey release];
    } else {
        publicKeyReference = publicKeyRef;
    }
    
    return publicKeyReference;
}



- (NSString *)encryptUsingPrivateKeyWithData:(NSData*)data{
    return [self rsaEncryptWithData:data usingPublicKey:NO server:NO];
}
- (NSString *)encryptUsingPublicKeyWithData:(NSData*)data{
    return [self rsaEncryptWithData:data usingPublicKey:YES server:NO];
}
- (NSString *)rsaEncryptWithData:(NSData*)data usingPublicKey:(BOOL)yes server:(BOOL)isServer{
    SecKeyRef key;
    if(yes){
        key = [self getPublicKeyRef];
    }else{
        key = [self getPrivateKeyRef];
    }
    
    
    
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = data;
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:0];
    
    for (int i=0; i<blockCount; i++) {
        
        int bufferSize = (int)MIN(blockSize,[plainTextBytes length] - i * blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyEncrypt(key,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == noErr){
            NSData *encryptedBytes = [NSData dataWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
            
        }else{
            
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    
    return [encryptedData base64EncodedStringWithOptions:0];
}

- (NSData *)getSignatureBytes:(NSData *)plainText {
    OSStatus sanityCheck = noErr;
    NSData * signedHash = nil;
    
    uint8_t * signedHashBytes = NULL;
    size_t signedHashBytesSize = 0;
    
    SecKeyRef privateKey = NULL;
    
    privateKey = [self getPrivateKeyRef];
    if(privateKey){
        signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    }else{
        DLog(@"PrivateKey is null");
        return nil;
    }
    // Malloc a buffer to hold signature.
    signedHashBytes = malloc( signedHashBytesSize * sizeof(uint8_t) );
    memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
    
    // Sign the SHA1 hash.
    sanityCheck = SecKeyRawSign(    privateKey,
                                kSecPaddingPKCS1,
                                (const uint8_t *)[[self getHashBytes:plainText] bytes],
                                kChosenDigestLength,
                                (uint8_t *)signedHashBytes,
                                &signedHashBytesSize
                                );
    if(sanityCheck != noErr){
        DLog(@"Problem signing the SHA1 hash, OSStatus == %d.", sanityCheck);
    }
    //LOGGING_FACILITY1( sanityCheck == noErr, @"Problem signing the SHA1 hash, OSStatus == %d.", sanityCheck );
    
    // Build up signed SHA1 blob.
    signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
    
    if (signedHashBytes) free(signedHashBytes);
    
    return signedHash;
}
- (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, kChosenDigestLength);
    
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], (int)[plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];
    
    if (hashBytes) free(hashBytes);
    
    return hash;
}
-(NSData*) PKCSSignBytesSHA1withRSA:(NSData*) plainData
{
    SecKeyRef privateKey = [self getPrivateKeyRef];
    size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    uint8_t* signedHashBytes = malloc(signedHashBytesSize);
    memset(signedHashBytes, 0x0, signedHashBytesSize);
    
    size_t hashBytesSize = kChosenDigestLength;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA1([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
        free(hashBytes);
        return nil;
    }
    
    SecKeyRawSign(privateKey,
                  kSecPaddingPKCS1,
                  hashBytes,
                  hashBytesSize,
                  signedHashBytes,
                  &signedHashBytesSize);
    
    NSData* signedHash = [NSData dataWithBytes:signedHashBytes
                                        length:(NSUInteger)signedHashBytesSize];
    
    if (hashBytes)
        free(hashBytes);
    if (signedHashBytes)
        free(signedHashBytes);
    
    return signedHash;
}
- (BOOL)verifySignature:(NSData *)plainText secKeyRef:(SecKeyRef)publicKey signature:(NSData *)sig {
    size_t signedHashBytesSize = 0;
    OSStatus sanityCheck = noErr;
    
    SecKeyRef pub = NULL;
    
    pub = [self getPublicKeyRef];
    
    // Get the size of the assymetric block.
    signedHashBytesSize = SecKeyGetBlockSize(pub);
    
    sanityCheck = SecKeyRawVerify(  publicKey,
                                  kSecPaddingNone,
                                  (const uint8_t *)[[self getHashBytes:plainText] bytes],
                                  kChosenDigestLength,
                                  (const uint8_t *)[sig bytes],
                                  signedHashBytesSize
                                  );
    
    return (sanityCheck == noErr) ? YES : NO;
}


@end
