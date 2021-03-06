/*******************************************************************************
**NOTE** This code was generated by a tool and will occasionally be
overwritten. We welcome comments and issues regarding this code; they will be
addressed in the generation tool. If you wish to submit pull requests, please
do so for the templates in that tool.

This code was generated by Vipr (https://github.com/microsoft/vipr) using
the T4TemplateWriter (https://github.com/msopentech/vipr-t4templatewriter).

Copyright (c) Microsoft Open Technologies, Inc. All Rights Reserved.
Licensed under the Apache License 2.0; see LICENSE in the source repository
root for authoritative license information.﻿
******************************************************************************/


#import "MSSampleServiceFetchers.h"

@implementation MSSampleServiceClient

- (instancetype)initWithUrl:(NSString *)url dependencyResolver:(id<MSOrcDependencyResolver>)resolver {

    return [super initWithUrl:url dependencyResolver:resolver];
}

- (MSSampleServiceSampleEntityCollectionFetcher *)services {

	return [[MSSampleServiceSampleEntityCollectionFetcher alloc] initWithUrl:@"services" parent:self];
}

- (MSSampleServiceSampleEntityFetcher *)me {

	return [[MSSampleServiceSampleEntityFetcher alloc] initWithUrl:@"Me" parent:self];
}

@end
