//
//  CocoaHotkeys.m
//  CocoaHotkeys
//
//  Created by Matthias Plappert on 07.09.09.
//  Copyright 2009 phapswebsolutions. All rights reserved.
//

#import "CocoaHotkeys.h"

#import "PWHotkeyCenter.h"
#import "PWHotkey.h"

@implementation CocoaHotkeys

+ HotKey2:(unsigned)myHotKey2;
{
		// Get center and create hotkey1 + hotkey2
	PWHotkeyCenter *center = [PWHotkeyCenter mainCenter];
   // PWHotkey *hotkey1 = [[PWHotkey alloc] initWithIdentifier:@"myFirstHotkey" flags:PWHotkeyCommandFlag + PWHotkeyOptionFlag key:myHotKey1];
	PWHotkey *hotkey2 = [[PWHotkey alloc] initWithIdentifier:@"mySecondHotkey" flags:PWHotkeyCommandFlag + PWHotkeyShiftFlag key:myHotKey2]; 
    
	//PWHotkey *hotkey1 = [[PWHotkey alloc] initWithIdentifier:@"myFirstHotkey" flags:PWHotkeyCommandFlag + PWHotkeyOptionFlag key:myHotKey1];
	//PWHotkey *hotkey2 = [[PWHotkey alloc] initWithIdentifier:@"mySecondHotkey" flags:PWHotkeyControlFlag key:myHotKey2]; 
	
	// Register hotkeys
	//[center registerHotkey:hotkey1 error:nil];
	[center registerHotkey:hotkey2 error:nil];
	NSLog(@"HotKeys Created.");
	// Release hotkeys
	//[hotkey1 release];
	[hotkey2 release];
    
    return @"OK";
}


@end
