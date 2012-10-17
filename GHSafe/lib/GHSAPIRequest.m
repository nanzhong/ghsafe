//
//  GHSAPIRequest.m
//  GHSafe
//
//  Created by Nan Zhong on 12-01-22.
//  Copyright (c) 2012 GHSafe. All rights reserved.
//

#import <objc/message.h>
#import "GHSAPIRequest.h"

@implementation GHSAPIRequest

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        delegateTarget = delegate;
        complete = YES;
    }
    
    return self;
}

- (void)loadObjectsAtResourcePath:(NSString*)resourcePath mapWith:(RKObjectMapping*)mapping onSuccess:(SEL)successSel onFailure:(SEL)failSel
{
    delegateSuccessSelector = successSel;
    delegateFailureSelector = failSel;
    requestMapping = mapping;
    complete = NO;
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:resourcePath objectMapping:mapping delegate:self];
}

- (void)postObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping onSuccess:(SEL)successSel onFailure:(SEL)failSel
{
    delegateSuccessSelector = successSel;
    delegateFailureSelector = failSel;
    requestObject = object;
    requestMapping = mapping;
    complete = NO;
    
    [[RKObjectManager sharedManager] postObject:requestObject mapResponseWith:requestMapping delegate:self];
}

- (void)putObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping onSuccess:(SEL)successSel onFailure:(SEL)failSel
{
    delegateSuccessSelector = successSel;
    delegateFailureSelector = failSel;
    requestObject = object;
    requestMapping = mapping;    
    complete = NO;
    
    [[RKObjectManager sharedManager] putObject:requestObject mapResponseWith:requestMapping delegate:self];
}

- (void)postObject:(NSObject *)object block:(void (^) (RKObjectLoader*))block onSuccess:(SEL)successSel onFailure:(SEL)failSel
{
    delegateSuccessSelector = successSel;
    delegateFailureSelector = failSel;
    requestObject = object;
    [[RKObjectManager sharedManager] postObject:object delegate:self block:block];
}

#pragma mark - RKObjectLoaderDelegate

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    complete = YES;
    //DLog("Received: %@", [objectLoader.response bodyAsString]);
    NSDictionary *errorDict;
    if ([objectLoader.response isUnprocessableEntity]) {
        NSError *parseError;
        errorDict = [objectLoader.response parsedBody:&parseError];
    }
    
    [delegateTarget performSelector:delegateFailureSelector withObject:errorDict];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    complete = YES;
    //DLog("Received: %@", [objectLoader.response bodyAsString]);
    [delegateTarget performSelector:delegateSuccessSelector withObject:objects];
}

- (BOOL)isComplete
{
    return complete;
}


@end
