/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * Licensed under the Apache License, Version 2.0.
 * See License.txt in the project root for license information.
 ******************************************************************************/

#import "MSOJsonParser.h"
#import "Property.h"
#import <objc/runtime.h>

@interface MSOJsonParser()

@property (nonatomic, strong) NSMutableArray *arrayToReturn;
@property (nonatomic, strong) NSArray *jsonArray;
@property (nonatomic, strong) NSDictionary *metadataValues;
@property (nonatomic, strong) NSMutableArray *properties;
@property (nonatomic, strong) NSMutableString *jsonResult;
@end

@implementation MSOJsonParser

-(id)initWithMetadataValues : (NSDictionary*)values{
    self.metadataValues = values;
    return self;
}

-(NSString*)toJsonString : (id)object{
    
    @try {
        self.jsonResult = [[NSMutableString alloc] initWithString:@"{"];
        
        self.jsonResult = [self getString :object];
        
        NSString *subString = [self.jsonResult substringWithRange:NSMakeRange(0, [self.jsonResult length] -1)];
        NSMutableString * result =  [[NSMutableString alloc] initWithString:subString];
        
        if([result length] == 0){return nil;}
        
        [result appendString:@"}"];
        
        return result;
    }
    @catch (NSException *exception) {
        NSLog(@"Warning: object is not present for parsing '%@'", exception.description);
        return nil;
    }
    @finally {
        
    }
}

/*
 -(NSString*)toJsonString:(id)object Property:(NSString*)name{
 
 NSMutableString *jsonResult = [[NSMutableString alloc] initWithString:@"{"];
 
 [jsonResult appendFormat:@"\"%@\" : \"%@\"", name, object];
 [jsonResult appendString:@"}"];
 
 return jsonResult;
 }*/

-(NSString*)getMetadataKey : (NSString*) propertyName{
    for(NSString* key in [self.metadataValues allKeys]){
        
        NSString* value = [self.metadataValues objectForKey:key];
        if([value isEqualToString:propertyName])
            return key;
    }
    
    return propertyName;
}

-(NSString*)toJsonString:(id)object Property:(NSString*)name{
    
    if([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]])
    {
        NSMutableString *jsonResult = [[NSMutableString alloc] init];
        
        [jsonResult appendFormat:@"\"%@\"",object];
        
        return jsonResult;
    }
    
    return [self toJsonString:object];
}

-(NSString *)dictionaryToJsonString:(NSDictionary *)dictionary {
    
    NSMutableString *jsonResult = [NSMutableString stringWithString:@"{"];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]])
        {
            
            [jsonResult appendFormat:@"\"%@\" : \"%@\",",key, object];
        }
        else if([object isKindOfClass:NSClassFromString(@"MSOrcParentReferencedArray")]) {
            
            [jsonResult appendFormat:@"\"%@\" : %@,",key, [self toJsonStringValue:[object array]]];
        }
        else if([object isKindOfClass:[NSArray class]]) {
            
            [jsonResult appendFormat:@"\"%@\" : %@,",key, [self toJsonStringValue:object ]];
        }
        else{
            [jsonResult appendFormat:@"\"%@\" : %@,", key, [self toJsonString:object]];
        }
    }
    
    [jsonResult replaceCharactersInRange:NSMakeRange(jsonResult.length-1, 1) withString:@""];
    [jsonResult appendString:@"}"];
    
    return jsonResult;
}

//TODO: Future Refactor
- (NSString *)toJsonStringValue:(id)object{
    
    self.jsonResult  = [NSMutableString string];
    
    if ([object isKindOfClass:[NSString class]]) {
        //TODO: Future Refactor
    }
    else if ([object isKindOfClass:[NSArray class]]){
        
        if([object count] > 0){
            
            [self.jsonResult  appendString:@"["];
            
            for (NSObject* element in object) {
                
                [self.jsonResult appendString:@"{"];
                self.jsonResult = [self getString:element];
                
                NSString *subString = [self.jsonResult substringWithRange:NSMakeRange(0, [self.jsonResult length] -1)];
                __strong NSMutableString * result =  [[NSMutableString alloc] initWithString:subString];
                
                self.jsonResult = result;
                
                [self.jsonResult appendString:@"},"];
            }
            
            NSString *subString = [self.jsonResult substringWithRange:NSMakeRange(0, [self.jsonResult length] -1)];
            NSMutableString * result =  [[NSMutableString alloc] initWithString:subString];
            self.jsonResult = result;
            
            [self.jsonResult appendString:@"]"];
        }
    }
    
    return self.jsonResult;
}

-(NSMutableString *)getString : (id)object{
    
    NSArray*properties = [self getPropertiesFor:[object class]];
    
    for (Property* property in properties) {
        if(![property isEnum] && ([property isComplexType] || [object isKindOfClass:[NSObject class]])){
            if([property isString] || [property isNumber]){
                NSString * name = [self getMetadataKey:property.Name];
                NSString * value = [object valueForKey:property.getPrivateKey];
                
                BOOL isNil= [value isKindOfClass:NSNull.class];
                
                if(!isNil && value != nil){
                    if([value containsString:@"\""]){
                        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                    }
                    [self.jsonResult appendString:[NSString stringWithFormat:@"\"%@\" : \"%@\",", name, value]];
                }
            }
            else if([property isDate]){
                
                NSDate* value = [object valueForKey:property.getPrivateKey];
                
                if(![value isKindOfClass:NSNull.class] && value != nil){
                    
                    @try {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        // [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
                        
                        
                        NSString *date = [[[dateFormatter stringFromDate:value] substringToIndex:19] stringByAppendingString:@"Z"];
                        
                        [self.jsonResult appendFormat:@"\"%@\" : \"%@\",", property.Name, date];
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Warning: could not parse property '%@'", property.Name);
                    }
                    @finally {
                        
                    }
                }
            }
            else if([property isCollection] || [property isCustomArray]){
                
                NSArray * array = [property isCustomArray] ? [[object valueForKey:property.getPrivateKey] array]
                :[object valueForKey:property.getPrivateKey];
                
                if([array count] > 0){
                    
                    [self.jsonResult appendFormat:@"\"%@\" : [", property.Name];
                    
                    for (NSDictionary* dicc in array) {
                        [self.jsonResult appendString:@"{"];
                        self.jsonResult = [self getString:dicc];
                        
                        NSString *subString = [self.jsonResult substringWithRange:NSMakeRange(0, [self.jsonResult length] -1)];
                        __strong NSMutableString * result =  [[NSMutableString alloc] initWithString:subString];
                        
                        self.jsonResult = result;
                        
                        [self.jsonResult appendString:@"},"];
                    }
                    
                    NSString *subString = [self.jsonResult substringWithRange:NSMakeRange(0, [self.jsonResult length] -1)];
                    NSMutableString * result =  [[NSMutableString alloc] initWithString:subString];
                    self.jsonResult = result;
                    
                    [self.jsonResult appendString:@"],"];
                }
            }
            else if([property isNSData]){
                NSData* value = [object valueForKey:property.getPrivateKey];
                if(value != nil){
                    [self.jsonResult appendFormat:@"\"%@\" : \"%@\",", property.Name, [value base64EncodedStringWithOptions:0]];
                }
            }
            else if([property isStream]){
                
            }
            else{
                id complexType = [object valueForKey:property.getPrivateKey];
                
                if(complexType != nil && [self propertiesAreNotNull:complexType : NSClassFromString(property.SubStringType)]){
                    
                    [self.jsonResult appendFormat:@"\"%@\" : {", property.Name];
                    [self getString:complexType];
                    
                    NSString *subString = [self.jsonResult substringWithRange:NSMakeRange(0, [self.jsonResult length] -1)];
                    __strong NSMutableString * result =  [[NSMutableString alloc] initWithString:subString];
                    self.jsonResult = result;
                    
                    [result appendString:@"},"];
                    self.jsonResult = result;
                }
            }
            
        }else{
            @try {
                NSString * result;
                
                if(property.isBoolean){
                    NSInteger value = [[object valueForKey:property.getPrivateKey] integerValue];
                    
                    result = value ? @"true" : @"false";
                    if(result != nil){
                        [self.jsonResult appendFormat:@"\"%@\" : \"%@\",", property.Name, result];
                    }
                }
                else if(property.isEnum) {
                    result = [object valueForKey:property.getPrivateKey];
                    if(result != nil){
                        [self.jsonResult appendFormat:@"\"%@\" : \"%@\",", property.Name, result];
                    }
                }
                else {
                    result = [object valueForKey:property.getPrivateKey];
                    if(result != nil){
                        [self.jsonResult appendFormat:@"\"%@\" : %@,", property.Name, result];
                    }
                }
                
                
            }
            @catch (NSException *exception) {
                NSLog(@"Warning: could not parse property '%@'", property.Name);
            }
            @finally {
                
            }
            
        }
    }
    return self.jsonResult;
}

- (id)parseWithData:(NSData*)data forType:(Class)type selector:(NSArray *)keys{
    
    @try {
        id parseResult;
        
        
        self.properties = [self getPropertiesFor:type];
        
        NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:nil];
        
        if(keys != nil){
            NSArray *jsonResult;
            
            for (NSString* key in keys) {
                jsonResult = [jsonArray valueForKey:key];
            }
            
            parseResult = [self parseArrayData:jsonResult type:type];
        }
        else{
            parseResult = [self parseObjectData:(NSDictionary*)jsonArray Type:type];
        }
        
        
        return parseResult;
    }
    @catch (NSException *exception) {
        NSLog(@"Warning: could not parse object - %@", exception.description);
        return nil;
    }
    @finally {
        
    }
}

-(id)parseObjectData : (NSDictionary*) data Type:(Class)type{
    
    id returnType = [[type alloc] init];
    
    for (Property* property in self.properties) {
        [self setValueFor:property Data:data Return:returnType];
    }
    
    return returnType;
}

-(NSMutableArray*)parseArrayData:(NSArray *)data type:(Class)type{
    
    self.arrayToReturn = [NSMutableArray array];
    
    for (NSDictionary *dictionary in data) {
        if([dictionary count] > 0)
            [self.arrayToReturn addObject:[self parseObjectData:dictionary Type:type]];
    }
    
    return self.arrayToReturn;
}

- (NSMutableArray *)getPropertiesFor : (Class)type {
    NSMutableArray *result = [NSMutableArray array];
    
    Class class = type;
    
    do {
        unsigned int count, i;
        objc_property_t *properties = class_copyPropertyList(class, &count);
        
        for (i = 0; i < count; i++) {
            
            Property * property = [[Property alloc]initWith:properties[i]];
            
            if(property != nil)
                [result addObject:property];
        }
        
        free(properties);
        class = [class superclass];
    } while ([class superclass]);
    
    return result;
}

- (void)setValueFor:(Property *) property Data : (NSDictionary*) data Return : (id)returnType{
    
    if ([property isComplexType]) {
        
        if([property isString]){
            NSString* name = [self getMetadataKey:property.Name];
            @try {
                NSString* value = [data valueForKey:name];
                
                if(![value isKindOfClass:NSNull.class] && value != nil)
                    [returnType setValue:value forKeyPath:property.getPrivateKey];
            }
            @catch (NSException *exception) {
                NSLog(@"Warning: could not parse property '%@'", property.Name);
            }
            @finally {
                
            }
            
        }
        else if([property isNumber]){
            NSString* value = [data valueForKeyPath:property.Name];
            [returnType setInteger:[value integerValue] forKey:property.getPrivateKey];
        }
        else if([property isDate]){
            
            NSString* value = [data valueForKeyPath:property.Name];
            if(![value isKindOfClass:NSNull.class] && value != nil){
                
                @try {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
                    
                    NSDate *date = [dateFormatter dateFromString:value];
                    [returnType setValue:date forKeyPath:property.getPrivateKey];
                }
                @catch (NSException *exception) {
                    NSLog(@"Warning: could not parse property '%@'", property.Name);
                }
                @finally {
                    
                }
            }
        }
        else if([property isNSData]){
            NSString* content = [data valueForKey:property.Name];
            
            if(content != nil && ![content isKindOfClass:NSNull.class]) {
                
                NSData *value = [[NSData alloc] initWithBase64EncodedString:content options:0];
                
                [returnType setValue:value forKeyPath:property.getPrivateKey];
            }
        }
        else if([property isStream]){
            
        }
        else if([property isCollection]){
            [self setValueForCollection:property :data :returnType];
        }
        else{
            [self setValueForComplexType:property :data :returnType];
        }
    }
    else{
        [self setValueForPrimitiveType:property :data :returnType];
    }
}

-(void)setValueForPrimitiveType :(Property*)property : (NSDictionary*)data :(id)returnType{
    
    NSString * value = [data valueForKeyPath:property.Name];
    
    if([value isKindOfClass:NSNull.class] || value == nil) return;
    
    @try {
        
        if([property isEnum]) {
            
            NSString* method = [[NSString alloc] initWithFormat:@"set%@String:", property.Name];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [returnType performSelector: NSSelectorFromString (method) withObject:value];
#pragma clang diagnostic pop
        }
        else{
            [returnType setValue:value forKeyPath:property.getPrivateKey];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Warning: could not parse property '%@'", property.Name);
    }
    @finally {
    }
}

-(void)setValueForCollection :(Property *)property :(NSDictionary*)data :(id)returnType{
    id object = [data valueForKeyPath:property.Name];
    
    if([object isKindOfClass:NSNull.class] || object == nil) return;
    
    NSArray * newData = object;
    
    id returnData = [returnType valueForKey:property.getPrivateKey];
    Class type = NSClassFromString([property getCollectionEntity:returnData]);
    
    if(type == nil){
        
        NSString* value;
        
        if([newData count] != 0 && [[newData objectAtIndex:0] isKindOfClass:NSDictionary.class]){
            for (NSDictionary* dicc in newData) {
                value= [dicc valueForKey:property.Name];
                
                if(![value isKindOfClass:NSNull.class] && value != nil){
                    [returnData addObject:value];
                }
            }
            
        }
        else{
            for (NSString* v in newData) {
                value= v;
                
                if(![value isKindOfClass:NSNull.class] && value != nil){
                    [returnData addObject:value];
                }
            }
        }
        
        if([returnData count] >0)
            [returnType setValue:returnData forKeyPath:property.getPrivateKey];
        
        
    }
    else{
        NSArray * array = [self getPropertiesFor:type];
       // NSMutableArray* returnData = [NSMutableArray array];
        
        for (NSDictionary* dicc in newData) {
            
            id entity = [[type alloc] init];
            for (Property* property in array) {
                
                [self setValueFor:property Data:dicc Return:entity];
            }
            
            if([self propertiesAreNotNull:entity :type]){
                
                [returnData addObject:entity];
                [returnType setValue:returnData forKeyPath:property.getPrivateKey];
            }
        }
    }
}

-(BOOL)propertiesAreNotNull : (id)complexType : (Class)type{
    
    BOOL result = false;
    
    if(![complexType isKindOfClass:type]) return false;
    
    NSArray*properties = [self getPropertiesFor:type];
    
    for (Property* property in properties) {
        
        NSString * name = [self getMetadataKey:property.Name];
        NSString * value = [complexType valueForKey:property.getPrivateKey];
        
        BOOL isNil= [value isKindOfClass:NSNull.class];
        
        if(!isNil && value != nil && ![name containsString:@"@odata"]){
            return true;
        }
    }
    
    return result;
}

-(void)setValueForComplexType :(Property*)property : (NSDictionary*)data :(id)returnType{
    
    Class type = NSClassFromString(property.SubStringType);
    
    if (type == nil) {//Enum
        NSString* value = [data valueForKeyPath:property.Name];
        
        if(value != nil){
            [returnType setValue:value forKeyPath:property.getPrivateKey];
        }
    }
    else{
        id entity = [[type alloc] init];
        
        NSDictionary *newData = [data valueForKeyPath:property.Name];
        
        if (newData != nil && ![newData isKindOfClass:NSNull.class]) {
            
            NSArray * array = [self getPropertiesFor:type];
            
            for (Property* property in array) {
                [self setValueFor:property Data:newData Return:entity];
            }
            
            [returnType setValue:entity forKeyPath:property.getPrivateKey];
        }
    }
}
@end