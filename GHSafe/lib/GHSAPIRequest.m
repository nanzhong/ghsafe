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

- (void)postObject:(NSObject*)object mapWith:(RKObjectMapping*)mapping acceptResponseWith:(id)target onSuccess:(SEL)successSel onFailure:(SEL)failSel
{
    delegateTarget = target;
    delegateSuccessSelector = successSel;
    delegateFailureSelector = failSel;
    requestObject = object;
    requestMapping = mapping;
    
    DLog(@"%@", requestMapping);
    
    [[RKObjectManager sharedManager] postObject:requestObject mapResponseWith:requestMapping delegate:self];
}

#pragma mark - RKObjectLoaderDelegate

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    DLog("Received: %@", [objectLoader.response bodyAsString]);
    NSDictionary *errorDict;
    if ([objectLoader.response isUnprocessableEntity]) {
        NSError *parseError;
        errorDict = [objectLoader.response parsedBody:&parseError];
    }
    
    [delegateTarget performSelector:delegateFailureSelector withObject:errorDict];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    DLog("Received: %@", [objectLoader.response bodyAsString]);
    [delegateTarget performSelector:delegateSuccessSelector withObject:objects];
}


@end
