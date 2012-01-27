//
//  XMLReader.h
//
//  Created by Troy on 9/18/10.
//  Copyright 2010 Troy Brant. All rights reserved.
//
// Debugging and corrections by Todd Bruss  4/9/11
// Copyright 2011 NiceMac LLC. All rights reserved.

#import <Foundation/Foundation.h>



@interface XMLReader : NSObject <NSXMLParserDelegate>  
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError **errorPointer;
 
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end
