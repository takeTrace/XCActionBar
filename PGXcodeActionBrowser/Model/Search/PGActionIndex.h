//
//  PGActionIndex.h
//  PGXcodeActionBrowser
//
//  Created by Pedro Gomes on 11/03/2015.
//  Copyright (c) 2015 Pedro Gomes. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@protocol PGActionProvider;
@protocol PGActionIndex <NSObject>

- (id<NSCopying>)registerProvider:(id<PGActionProvider>)provider;
- (void)deregisterProvider:(id<NSCopying>)providerToken;

- (void)updateWithCompletionHandler:(PGGeneralCompletionHandler)completionHandler;

- (NSArray *)lookup:(NSString *)str;

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface PGActionIndex : NSObject <PGActionIndex>

@end
