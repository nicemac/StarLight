//
//  ChannelXML.m
//  StarLight
//
//  Objective-C Conversion by Joe Turner
//  Original ASOC Version & additional Objective-C code by Todd Bruss
//  Copyright 2011 Iced Cocoa. All rights reserved.
//  Copyright 2011 NiceMac. All rights reserved.
//

#import "ChannelXML.h"
#import "CoreAudio/CoreAudio.h"

@implementation ChannelXML

// adapted from stackoverflow.com
+ (id) loadOutputDevices
{
    AudioObjectPropertyAddress  propertyAddress;
    AudioObjectID               *deviceIDs;
    UInt32                      propertySize;
    NSInteger                   numDevices;
    
    NSMutableArray *audioList = [NSMutableArray array];

    [audioList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"0", @"deviceID",
                          @"Default Audio", @"deviceName", 
                          nil]];
    
    propertyAddress.mSelector = kAudioHardwarePropertyDevices;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    if (AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &propertySize) == noErr) {
        numDevices = propertySize / sizeof(AudioDeviceID);
        deviceIDs = (AudioDeviceID *)calloc(numDevices, sizeof(AudioDeviceID));
        
        if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &propertySize, deviceIDs) == noErr) {
            AudioObjectPropertyAddress      deviceAddress;
            
            for (NSInteger idx=0; idx<numDevices; idx++) {
                CFStringRef     myDeviceName;
                
                propertySize = sizeof(myDeviceName);
                deviceAddress.mSelector = kAudioObjectPropertyName;
                deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
                deviceAddress.mElement = kAudioObjectPropertyElementMaster;
                if (AudioObjectGetPropertyData(deviceIDs[idx], &deviceAddress, 0, NULL, &propertySize, &myDeviceName) == noErr) {
                    
                    NSString *myDevice = [NSString stringWithFormat:@"%u", deviceIDs[idx]];
                    
                    [audioList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       myDevice, @"deviceID",
                                       myDeviceName, @"deviceName", 
                                       nil]];
                    
                   // NSLog(@"DeviceID: %u Name: %@", deviceIDs[idx], myDeviceName);
                    
                    CFRelease(myDeviceName);
                }
            }
        }
        
        free(deviceIDs);
    }
    
    return audioList;
}

+ (NSArray *)channelXML:(NSData *)channelData starsList:(NSArray *)starsList subscriber:(BOOL)sirSubscriber adult:(BOOL)allowAdultContent {
    NSMutableArray *chList = [NSMutableArray array];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:channelData options:NSXMLDocumentTidyXML error:NULL];
    NSArray *catXML = [document nodesForXPath:@"./lineup-response/lineup/categories" error:NULL];
    
    // NSLog(@"%@", catXML);
    
    
    NSLog(@"starsList: %@", starsList);
    
    
    //NSLog(@"begin channel repeat loop");
    
    for (NSXMLElement *category in catXML) {
        NSString *currentCat = [[[category elementsForName:@"name"] objectAtIndex:0] stringValue];
        
        // NSLog(@"%@", currentCat);
        
        NSArray *genres = [category nodesForXPath:@"./genres" error:NULL];
        for (NSXMLElement *genre in genres) {
            NSArray *names = [genre elementsForName:@"name"];
            if ([names count] == 0)
                continue;
            
            NSString *currentGenre = [[names objectAtIndex:0] stringValue];
            
            //  NSLog(@"\t%@", currentGenre);
            
            NSArray *channels = [genre nodesForXPath:@"./channels" error:NULL];
            for (NSXMLElement *channel in channels) {
                NSArray *availables = [channel elementsForName:@"isAvailable"];
                if ([availables count] == 0)
                    continue;
                
                BOOL isAvailable = [[[availables objectAtIndex:0] stringValue] boolValue];
                if (!isAvailable)
                    continue;
                
                NSArray *matures = [channel elementsForName:@"isMature"];
                if ([matures count] == 0)
                    continue;
                BOOL isMature = [[[matures objectAtIndex:0] stringValue] boolValue];
                if (isMature && !allowAdultContent)
                    continue;
                
                NSArray *siriusChannelNumbers = [channel elementsForName:@"siriusChannelNo"];
                if ([siriusChannelNumbers count] == 0)
                    continue;
                NSString *channelNumber = [[siriusChannelNumbers objectAtIndex:0] stringValue];
                
                NSInteger sirInt = [channelNumber intValue];
                NSString *sirNo = [NSString stringWithFormat:@"%03d",sirInt];
                
                NSArray *xmChannelNumbers = [channel elementsForName:@"xmChannelNo"];
                if ([xmChannelNumbers count] == 0)
                    continue;
                NSString *channelNumber2 = [[xmChannelNumbers objectAtIndex:0] stringValue];
                
                NSInteger xmInt = [channelNumber2 intValue];
                NSString *xmNo = [NSString stringWithFormat:@"%03d",xmInt];
                
                NSArray *channelNames = [channel elementsForName:@"name"];
                if ([channelNames count] == 0)
                    continue;
                NSString *chName = [[channelNames objectAtIndex:0] stringValue];
                
                NSArray *channelKeys = [channel elementsForName:@"channelKey"];
                if ([channelKeys count] == 0)
                    continue;
                NSString *chKey = [[channelKeys objectAtIndex:0] stringValue];
                
                NSArray *displayNames = [channel elementsForName:@"displayName"];
                if ([displayNames count] == 0)
                    continue;
                NSString *shortDesc = [[displayNames objectAtIndex:0] stringValue];
                
                NSArray *logos = [channel nodesForXPath:@"./logos/url" error:NULL];
                if ([logos count] == 0)
                    continue;
                NSString *medLogo = [[logos objectAtIndex:1] stringValue];
                
                // 
                //tell class "NSPredicate" of current application
                //set myPred to predicateWithFormat_("stars == 1")
                //end
                
                // tell class "NSMutableArray" of current application
                // set starsList to arrayWithArray_(theList)
                // starsList's filterUsingPredicate_(myPred)
                // end
                
                NSMutableArray *starSearch = [NSMutableArray arrayWithArray:starsList];
                
                NSPredicate *myPredicate = [NSPredicate
                                            predicateWithFormat:@"(chKey == %@) AND (sirNo == %@)", chKey, (sirSubscriber ? sirNo : xmNo)];
                
                [starSearch filterUsingPredicate:myPredicate];
                
                // NSInteger xmInt = [channelNumber2 intValue];
                
                
                NSInteger stars = 1;
                
                if ([starSearch count] == 0)
                    stars = 0;
                else
                    stars = 1;
                
                
                // NSLog(@"starSearch: %@", starSearch);
                
                //  NSLog(@"        %@", chName);
                
                
                // Make the Dictionary Mutable to Favorites (stars) can be rewritable
                [chList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:stars], @"stars",
                                   currentCat, @"cat",
                                   currentGenre, @"gen",
                                   (sirSubscriber ? sirNo : xmNo), @"sirNo",
                                   chName, @"chName",
                                   [NSNumber numberWithBool:isMature], @"isMature",
                                   chKey, @"chKey",
                                   shortDesc, @"shortDesc",
                                   medLogo, @"medLogo", nil]];
            }
        }
    }
    
    //NSLog(@"finished triple repeat loop");
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sirNo" ascending:YES selector:@selector(localizedCompare:)];
    NSArray *descriptors = [NSArray arrayWithObject:sort];
    NSArray *returning = [chList sortedArrayUsingDescriptors:descriptors];
    [document release];
    [sort release];
    
    return returning;    
}

@end
