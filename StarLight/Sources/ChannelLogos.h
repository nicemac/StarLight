//
//  ChannelLogos.h
//  StarLight
//
//  Created by goodtime on 4/24/11.
//  Copyright 2011 NiceMac. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChannelLogos : NSObject


{ 
    
    NSMutableData* responseData;
    NSString* channelKey;
    NSString* appSupport;


@private
	//NSMutableData *responseData;
	NSURL *baseURL; 


}
@property (retain) NSMutableData *responseData;
@property (retain) NSString *channelKey;
@property (readonly) NSString *appSupport;

+ usleep:(unsigned)delay;

+ getLogos:(NSDictionary *)chArray appSupport:(NSString *)appSupport;
- (id)requestLogos:(NSString *)logoURL myKey:(NSString *)chKey myFolder:(NSString *)supFldr;
    @end
