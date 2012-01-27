//
//  ChannelLogos.m
//  StarLight
//
//  Created by goodtime on 4/24/11.
//  Copyright 2011 NiceMac. All rights reserved.
//

#import "ChannelLogos.h"

@implementation ChannelLogos 
@synthesize responseData, channelKey, appSupport;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ usleep:(unsigned)delay
{
    usleep(delay);
    return @"uslept";
}


+ getLogos:(NSDictionary *)chArray appSupport:(NSString *)appSupport
{
    
        //NSLog(@"appSupport = %@", appSupport);

    for (NSDictionary *currentChannel in chArray)
    {
        
        NSString *logoURL = [currentChannel objectForKey:@"medLogo"];
        NSString *chKey = [currentChannel objectForKey:@"chKey"];

        
        // only way I could call an instance method
       [[[[self alloc] init] autorelease] requestLogos:logoURL myKey:chKey myFolder: appSupport];  

    
        //[returnURL release];
        // just a placeholder return so the (id) can be autoreleased
        // returnsURL and may change if redirected (Don't really use the return for anything)
        //NSLog(@"returnURL = %@", returnURL);
    }
    return @"done";

}

- (id)requestLogos:(NSString *)logoURL myKey:(NSString *)chKey myFolder:(NSString *)supFldr
{
    appSupport = [[NSString stringWithString: supFldr] autorelease];
    channelKey = [[NSString stringWithString: chKey] autorelease];
    responseData = [[NSMutableData data] autorelease];
    baseURL = [[NSURL URLWithString: logoURL] autorelease];
    NSURLRequest *request =
    [NSURLRequest requestWithURL:baseURL];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];

    return logoURL;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{

    baseURL = [[request URL] autorelease];


    //NSLog(@"my Request = %@", request);
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    // Don't show error, we can always redownload the missing logos
    // when the channel list needs to be updated
    // [[NSAlert alertWithError:error] runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"Connection Desc = %@", [connection description]);
    //NSLog(@"channelKey = %@", channelKey);
    //NSLog(@"appSupport = %@", appSupport);

    NSString *myFolder = [NSString stringWithFormat:@"%@StarLight/Logos/%@.png", appSupport, channelKey];

    [responseData writeToFile:myFolder atomically:true];
    //downloadData's writeToFile_atomically_(downloadPath, false)
    
    [responseData release];
    [channelKey release];
    [appSupport release];
}
@end