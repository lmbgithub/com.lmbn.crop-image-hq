//
//  LabelTransformer.m
//  hq-crop-image
//
//  Created by luis on 11/12/14.
//  Copyright (c) 2014 LMBN. All rights reserved.
//

#import "LabelTransformer.h"

@implementation LabelTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if (value == nil) return nil;
    
    if ( ![value respondsToSelector: @selector(doubleValue)])
    {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -doubleValue.",
         [value class]];
    }
    
    double val =  0.4 + ([value doubleValue]/100.0f)*0.6;
    return [NSString stringWithFormat:@"( %2.2lf )", val];
}

@end
