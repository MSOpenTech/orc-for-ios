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

#import "MSSampleContainerModels.h"

/**
 * The implementation file for type MSSampleContainerAnotherEntity.
 */

@implementation MSSampleContainerAnotherEntity

@synthesize odataType = _odataType;
@synthesize SomeString = _SomeString;

- (instancetype)init {
    
    if (self = [super init]) {
        
        _odataType = @"#Microsoft.SampleService.AnotherEntity";
        [self valueChanged:_odataType forProperty:@"_odataType"];
    }
    
    return self;
}


- (void)setSomeString:(NSString *)  SomeString;
{
    _SomeString =  SomeString;
    [self valueChanged:SomeString forProperty:@"SomeString"];
}

- (void)set:(NSString *)  SomeString;
{
    _SomeString =  SomeString;
    [self valueChanged:SomeString forProperty:@"SomeString"];
}

@end