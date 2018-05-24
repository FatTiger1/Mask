//
//  BaseEntity.m
//  CloudClassRoom
//
//  Created by rgshio on 2017/5/10.
//  Copyright © 2017年 like. All rights reserved.
//

#import "BaseEntity.h"

@implementation BaseEntity

MJExtensionCodingImplementation

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if (oldValue == nil) {
        return @"";
    }
    
    return oldValue;
}

@end
