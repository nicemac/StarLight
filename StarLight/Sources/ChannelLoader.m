//
//  ChannelLoader.m
//  ObjCtest
//
//  Created by goodtime on 4/23/11.
//  Copyright 2011 NiceMac. All rights reserved.
//

#import "ChannelLoader.h"

@implementation ChannelLoader

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


+ (NSArray *)test:(NSData *)data
{
    NSError *error;
    NSXMLDocument *document =
    [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyXML error:&error];
    
    // Deliberately ignore error: with most HTML it will be filled numerous
    // "tidy" warnings.
    
    NSXMLElement *rootNode = [document rootElement];
    //NSLog(@"my rootNode = %@", rootNode);
    
    NSString *catQueryString = 
    @"//lineup-response/lineup/categories";
    
    NSString *genreQueryString = 
    @"./genres";
    
    NSString *channelQueryString = 
    @"./channels";
    
    NSArray *myCategories = [rootNode nodesForXPath:catQueryString error:&error];
    
    NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity:120];
    
    
    for (NSXMLElement *cNode in myCategories)
        
    {
        NSString *myCat = [ [[cNode elementsForName:@"name"] objectAtIndex:0] stringValue];
        // NSLog(@"myCat = %@", myCat);
        
        NSArray *myGenres = [cNode nodesForXPath:genreQueryString error:&error];
        // NSLog(@"myGenres = %@", myGenres);
        
        //NSLog(@"my myCategories = %@", myCategories);
        
        for (NSXMLElement *gNode in myGenres)
        {
            NSString *myGenre = [ [[gNode elementsForName:@"name"] objectAtIndex:0] stringValue];
            // NSLog(@"myGenre = %@", myGenre);
            
            NSArray *myChannels = [gNode nodesForXPath:channelQueryString error:&error];
            //  NSLog(@"myChannels = %@", myChannels);
            
            for (NSXMLElement *myNode in myChannels)
            {
                NSString *isAvailable = [ [[myNode elementsForName:@"isAvailable"] objectAtIndex:0] stringValue];
                
                // NSLog(@"isAvailable = %@", isAvailable);
                
                // Convert isAvailable string to Boolean :)
                BOOL availBool = [isAvailable boolValue];
                
                if (availBool == 1)
                {
                    NSString *myName = [ [[myNode elementsForName:@"name"] objectAtIndex:0] stringValue];
                    
                    NSString *chKey = [ [[myNode elementsForName:@"channelKey"] objectAtIndex:0] stringValue];
                    
                    NSString *sirNum = [ [[myNode elementsForName:@"siriusChannelNo"] objectAtIndex:0] stringValue];
                    
                    // add leading zeros to the Sirius Channel Number
                    NSInteger sirInt = [sirNum intValue];
                    NSString *sirNo = [NSString stringWithFormat:@"%03d",sirInt];
                    
                    NSString *logos = [[[myNode nodesForXPath:@"./logos/url" error:&error]objectAtIndex:1] stringValue];
                    
                    NSString *shortDesc = [ [[myNode elementsForName:@"displayName"] objectAtIndex:0] stringValue];
                    
                    [channels addObject:
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      sirNo, @"sirNo",
                      chKey, @"chKey",
                      logos, @"medLogo",
                      shortDesc, @"shortDesc",
                      myName, @"chName",
                      myGenre, @"gen",
                      myCat, @"cat",
                      nil]];
                }                
            }
        } 
        
    }
    
    //NSLog(@"channels = %@", channels);
        
    [channels release];
    [document release];
    
    return channels;
}
@end