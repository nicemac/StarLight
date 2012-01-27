//
//  ChannelXML.h
//  StarLight
//
//  Concept by Todd Bruss, Conversion by Joe Turner on 4/21/11.
//  Copyright 2011 NiceMac. All rights reserved.
//  Copyright 2011 Iced Cocoa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChannelXML : NSObject {
    
}

+ (id) loadOutputDevices;

+ (NSArray *)channelXML:(NSData *)channelData starsList:(NSArray *)starsList subscriber:(BOOL)sirSubscriber adult:(BOOL)allowAdultContent;

@end
