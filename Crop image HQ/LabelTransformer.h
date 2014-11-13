//
//  LabelTransformer.h
//  hq-crop-image
//
//  Created by luis on 11/12/14.
//  Copyright (c) 2014 LMBN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LabelTransformer : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;


@end
