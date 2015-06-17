/*******************************************************************************
Copyright (c) Microsoft Open Technologies, Inc. All Rights Reserved.
Licensed under the MIT or Apache License; see LICENSE in the source repository
root for authoritative license information.﻿

**NOTE** This code was generated by a tool and will occasionally be
overwritten. We welcome comments and issues regarding this code; they will be
addressed in the generation tool. If you wish to submit pull requests, please
do so for the templates in that tool.

This code was generated by Vipr (https://github.com/microsoft/vipr) using
the T4TemplateWriter (https://github.com/msopentech/vipr-t4templatewriter).
******************************************************************************/

@class MSSampleContainerItemFetcher;
@class MSSampleContainerItemCollectionFetcher;

#import <core/core.h>
#import "MSSampleContainerModels.h"

/**
* The header for type MSSampleContainerItemCollectionFetcher.
*/

@protocol MSSampleContainerItemCollectionFetcherProtocol<MSOrcCollectionFetcher>

@optional

- (void)readWithCallback:(void (^)(NSArray<MSSampleContainerItem> *items, MSOrcError *error))callback;

- (MSSampleContainerItemCollectionFetcher *)select:(NSString *)params;
- (MSSampleContainerItemCollectionFetcher *)filter:(NSString *)params;
- (MSSampleContainerItemCollectionFetcher *)search:(NSString *)params;
- (MSSampleContainerItemCollectionFetcher *)top:(int)value;
- (MSSampleContainerItemCollectionFetcher *)skip:(int)value;
- (MSSampleContainerItemCollectionFetcher *)expand:(NSString *)value;
- (MSSampleContainerItemCollectionFetcher *)orderBy:(NSString *)params;
- (MSSampleContainerItemCollectionFetcher *)addCustomParametersWithName:(NSString *)name value:(id)value;
- (MSSampleContainerItemCollectionFetcher *)addCustomHeaderWithName:(NSString *)name value:(NSString *)value;

@required

- (instancetype)initWithUrl:(NSString *)urlComponent parent:(id<MSOrcExecutable>)parent;
- (MSSampleContainerItemFetcher *)getById:(NSString *)Id;
- (void)add:(MSSampleContainerItem *)entity callback:(void (^)(MSSampleContainerItem *item, MSOrcError *error))callback;

@end

@interface MSSampleContainerItemCollectionFetcher : MSOrcCollectionFetcher<MSSampleContainerItemCollectionFetcherProtocol>

- (instancetype)initWithUrl:(NSString *)urlComponent parent:(id<MSOrcExecutable>)parent;

@end