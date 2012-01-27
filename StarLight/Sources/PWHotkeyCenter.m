/*
 Copyright (c) 2009, Matthias Plappert
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
   and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
   and the following disclaimer in the documentation and/or other materials provided with the
   distribution.
 
 * Neither the name of the author nor the names of its contributors may be used to endorse or
   promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//
//  PWHotkeyCenter.m
//  CocoaHotkeys
//
//  Created by Matthias Plappert on 2009/09/07
//

#import "PWHotkeyCenter.h"
#import "PWHotkey.h"

OSStatus PWHotkeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{	
	// Get hotkey id
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	NSInteger uniqueID = hotKeyID.id;
	
	// Get hotkey object
	PWHotkey *hotkey = [[PWHotkeyCenter mainCenter] hotkeyForUniqueID:uniqueID];
	
	// Send notification
	[[NSNotificationCenter defaultCenter] postNotificationName:PWHotkeyNotification object:hotkey];
	return noErr;
}

@implementation PWHotkeyCenter

static PWHotkeyCenter *mainCenter = nil;

+ (void)initialize
{
	if (self == [PWHotkeyCenter class]) {
		EventTypeSpec eventType;
		eventType.eventClass = kEventClassKeyboard;
		eventType.eventKind  = kEventHotKeyPressed;
		
		InstallApplicationEventHandler(NewEventHandlerUPP(PWHotkeyHandler), 1, &eventType, NULL, NULL);
	}
}

#pragma mark -
#pragma mark Singleton implementation

+ (PWHotkeyCenter *)mainCenter
{
    @synchronized (self) {
        if (mainCenter == nil) {
            mainCenter = [[self alloc] init];
        }
    }
    return mainCenter;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (mainCenter == nil) {
            mainCenter = [super allocWithZone:zone];
            return mainCenter;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

+ (void)release
{
    // do nothing
    return;
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Standard class methods

- (id)init
{
	if (self = [super init]) {
		// Create mutable dictionary. This will hold all registered hotkey instances.
		_hotkeys = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_hotkeys release];
	[super dealloc];	 
}

- (BOOL)registerHotkey:(PWHotkey *)hotkey error:(NSError **)error
{
	if (hotkey.uniqueID != PWHotkeyInvalidUniqueID) {
		// Check if this hotkey is already registered
		NSString *uniqueID = [NSString stringWithFormat:@"%d", hotkey.uniqueID];
		if ([_hotkeys objectForKey:uniqueID] == nil) {
			// Hotkey is new, so register it. Start with creating an ID
			EventHotKeyID hotKeyID;
			hotKeyID.signature = 'hkey';
			hotKeyID.id        = hotkey.uniqueID;
			
			// Register hotkey and save reference
			EventHotKeyRef ref;
			OSStatus err = RegisterEventHotKey(hotkey.key, hotkey.flags, hotKeyID, GetApplicationEventTarget(), 0, &ref);
			hotkey.carbonRef = ref;
			
			if (err) {
				// There was an error
				*error = [NSError errorWithDomain:PWHotkeyErrorDomain code:PWHotkeyCarbonSystemError userInfo:nil];
				return NO;
			} else {
				// Everything is okay, save hotkey
				[_hotkeys setObject:hotkey forKey:uniqueID];
				return YES;
			}
		} else {
			// Hotkey is already registered
			*error = [NSError errorWithDomain:PWHotkeyErrorDomain code:PWHotkeyAlreadyExists userInfo:nil];
			return NO;
		}
	} else {
		// Invalid unique ID
		*error = [NSError errorWithDomain:PWHotkeyErrorDomain code:PWHotkeyInvalidID userInfo:nil];
		return NO;
	}
}

- (BOOL)unregisterHotkey:(PWHotkey *)hotkey error:(NSError **)error
{
	// Check if there's an existing hotkey
	NSString *uniqueID = [NSString stringWithFormat:@"%d", hotkey.uniqueID];
	if ([_hotkeys objectForKey:uniqueID]) {
		// Hotkey exists, so we can remove it. So let's do it.
		OSStatus err = UnregisterEventHotKey(hotkey.carbonRef);
		if (err) {
			// There was an error unregistering the hotkey
			*error = [NSError errorWithDomain:PWHotkeyErrorDomain code:PWHotkeyCarbonSystemError userInfo:nil];
			return NO;
		} else {
			// We did unregister the hotkey. Remove it from dictionary
			[_hotkeys removeObjectForKey:uniqueID];
			return YES;
		}
	} else {
		// Unknown hotkey
		*error = [NSError errorWithDomain:PWHotkeyErrorDomain code:PWHotkeyNotFound userInfo:nil];
		return NO;
	}
}

- (void)unregisterAllHotkeys
{
	// Save a copy to make sure that we don't run into problems because we are deleting entries from _hotkeys
	NSDictionary *copy = [[NSDictionary alloc] initWithDictionary:_hotkeys];
	for (NSString *uniqueID in copy) {
		PWHotkey *hotkey = [copy objectForKey:uniqueID];
		[self unregisterHotkey:hotkey error:nil];
	}
	
	// Now release copy
	[copy release];
}
						
#pragma mark -
#pragma mark Accessors
						
- (PWHotkey *)hotkeyForUniqueID:(NSInteger)uniqueID
{
	NSString *uniqueStringID = [NSString stringWithFormat:@"%d", uniqueID];
	return [_hotkeys objectForKey:uniqueStringID];
}

@end
