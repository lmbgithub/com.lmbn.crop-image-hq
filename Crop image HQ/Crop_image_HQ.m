//
//  Crop_image_HQ.m
//  Crop image HQ
//
//  Created by luis on 11/12/14.
//  Copyright (c) 2014 LMBN. All rights reserved.
//

#import "Crop_image_HQ.h"
#import <OSAKit/OSAKit.h>
#import <QuartzCore/CoreImage.h>

@implementation Crop_image_HQ

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:[input count]];
    
    // check amount of items
    if ( ![input isKindOfClass:[NSArray class]] )
    {
        NSArray *objsArray = [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:errOSASystemError],
                              [NSString stringWithFormat:
                               @"ERROR: there is no input files"], nil];
        
        NSArray *keysArray = [NSArray arrayWithObjects:OSAScriptErrorNumber,
                              OSAScriptErrorMessage, nil];
        
        *errorInfo = [NSDictionary dictionaryWithObjects:objsArray
                                                 forKeys:keysArray];
        return nil;
    }
    
    NSEnumerator *enumerate = [input objectEnumerator];
    NSString *path;
    
    double tw = [[self.parameters valueForKey:@"width"] doubleValue] ;
    double th = [[self.parameters valueForKey:@"height"] doubleValue] ;
    
    double quality = 0.0f;
    
    quality = 0.4 + ([[self.parameters valueForKey:@"jpgQuality"] doubleValue]/100.0f)*0.6;
    
    typedef enum {
        NO_SCALE = 0,
        SCALE_TO_WIDTH,
        SCALE_TO_HEIGHT,
        SCALE_TO_BIGGEST_SIDE
    } ScaleBehavior;
    
    ScaleBehavior sb = (ScaleBehavior)[[self.parameters valueForKey:@"scaleBehavior"] intValue];
    
    NSLog(@"tw: %f, th: %f, q:%f, s:%d , %d", tw, th, quality, (int)sb , (sb == SCALE_TO_HEIGHT));
    
    while (path = [enumerate nextObject]) {
        
        CGImageRef        myImage = NULL;
        CGImageSourceRef  myImageSource;
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        // open the files
        myImageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        
        if (myImageSource == NULL){
            [returnArray addObject:[NSString stringWithFormat: @"ERROR: Could not open file %@", path]];
            continue;
        }
        
        myImage = CGImageSourceCreateImageAtIndex(myImageSource,
                                                  0,
                                                  NULL);
        
        CFRelease(myImageSource);
        
        if ( myImage == NULL ){
            [returnArray addObject:[NSString stringWithFormat: @"ERROR: Could not open file %@", path]];
            continue;
        }
        
        double width  = CGImageGetWidth(myImage);
        double height = CGImageGetHeight(myImage);
        
        NSLog(@"file: %@ : w: %f, h: %f", path, width, height);
        
        if ( sb == NO_SCALE )
        {
            tw = MIN(width, tw);
            th = MIN(height, th);
        }
        else
        {
            double scaleRatio = 0.0, w = 0, h = 0, r = 0.0;
            if ( sb == SCALE_TO_WIDTH )
            {
                scaleRatio = tw/width;
                w = tw;
                h = floor(scaleRatio*height);
            }
            else if ( sb == SCALE_TO_HEIGHT )
            {
                scaleRatio = th/height;
                w = floor(scaleRatio*width);
                h = th;
            }
            else if ( sb == SCALE_TO_BIGGEST_SIDE )
            {
                r    = width/height;
                scaleRatio = tw/th;
                
                if ( r <= scaleRatio && r >= 1.0 )
                {
                    scaleRatio = tw/width;
                    w = tw;
                    h = floor(scaleRatio*height);
                }
                else if (  r >= scaleRatio && scaleRatio >= 1.0 )
                {
                    scaleRatio = th/height;
                    w = floor(scaleRatio*width);
                    h = th;
                }
                else if (  r <= 1.0 && scaleRatio >= 1.0 )
                {
                    scaleRatio = tw/width;
                    w = tw;
                    h = floor(scaleRatio*height);
                }
                else if (  r >= 1.0 && scaleRatio <= 1.0 )
                {
                    scaleRatio = th/height;
                    w = floor(scaleRatio*width);
                    h = th;
                }
                else if ( r >= scaleRatio && r < 1.0 )
                {
                    scaleRatio = th/height;
                    w = floor(scaleRatio*width);
                    h = th;
                }
                else if ( r <= scaleRatio && scaleRatio < 1.0  )
                {
                    scaleRatio = tw/width;
                    w = tw;
                    h = floor(scaleRatio*height);
                }
            }
            
            NSLog(@"ratio: %lf , s: %lf , w: %lf, h: %lf",r, scaleRatio, w, h );
            
            CGColorSpaceRef colorspace = CGImageGetColorSpace(myImage);
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         w,
                                                         h,
                                                         CGImageGetBitsPerComponent(myImage),
                                                         CGImageGetBytesPerRow(myImage)/width*w,
                                                         colorspace,
                                                         CGImageGetBitmapInfo(myImage));
            
            if( context == NULL )
            {
                [returnArray addObject:[NSString stringWithFormat: @"Error: failed to treat the file %@", path]];
                
                CGImageRelease(myImage);
                continue;
            }
            
            // draw image to context
            CGContextDrawImage(context, CGContextGetClipBoundingBox(context), myImage);
            
            // extract resulting image from context
            CGImageRef imgRef = CGBitmapContextCreateImage(context);
            CGImageRelease(myImage);
            CGContextRelease(context);
            
            myImage = imgRef;
            
            width  = w;
            height = h;
            
            NSLog(@"Scale : w: %f, h: %f", w, h);
            
        }
        
        double x = floor(( width - tw ) / 2.0);
        double y = floor(( height - th ) / 2.0);
        
        x = ( x < 0.0 )?0.0:x;
        y = ( y < 0.0 )?0.0:y;
        
        CGRect clippedRect  = CGRectMake(x , y , tw , th);
        
        NSLog(@"Crop : x: %f, y: %f, w: %f, h: %f\n\n", x, y, tw, th);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect( myImage , clippedRect);
        CGImageRelease(myImage);
        
        // save files
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)url,
                                                                            kUTTypeJPEG,
                                                                            1, NULL);
        if (!destination) {
            [returnArray addObject:[NSString stringWithFormat: @"Failed to write image to %@", path]];
            CGImageRelease(imageRef);
            continue;
        }
        
        NSDictionary *jfifProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id) kCFBooleanTrue, kCGImagePropertyJFIFIsProgressive,
                                        nil];
        
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble: quality ],
                                    kCGImageDestinationLossyCompressionQuality,
                                    jfifProperties, kCGImagePropertyJFIFDictionary,
                                    nil];
        
        CGImageDestinationAddImage(destination, imageRef, (__bridge CFDictionaryRef)properties);
        
        if (!CGImageDestinationFinalize(destination)) {
            [returnArray addObject:[NSString stringWithFormat: @"Failed to write image to %@", path]];
            CFRelease(destination);
            CGImageRelease(imageRef);
            continue;
        }
        
        [returnArray addObject:path];
        
        CFRelease(destination);
        CGImageRelease(imageRef);
    }
    
    NSLog(@"LOG: %@", returnArray);
    
    return returnArray;
}

@end
