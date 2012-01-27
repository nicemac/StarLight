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
//  PWHotkey.m
//  CocoaHotkeys
//
//  Created by Matthias Plappert on 2009/09/07
//

#import "PWHotkey.h"

@implementation PWHotkey

- (id)initWithIdentifier:(NSString *)identifier flags:(PWHotkeyFlags)flags key:(NSUInteger)key
{
	if (self = [super init]) {
		// Save values
		_identifier = [identifier copy];
		_flags      = flags;
		_key        = key;
		
		// This is unique for every possible key combination. You can create several hotkey instances
		// for one hotkey but registration will fail.
		_uniqueID = _flags + _key;
	}
	return self;
}

- (id)init
{
	if (self = [self initWithIdentifier:nil flags:PWHotkeyNoFlag key:PWHotkeyNoKey]) {
		// Do not use this! Use initWithIdentifier:flags:key: instead!
	}
	return self;
}

- (void)dealloc
{
	[_identifier release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (NSString *)identifier
{
	return _identifier;
}

- (PWHotkeyFlags)flags
{
	return _flags;
}

- (NSInteger)key
{
	return _key;
}

- (NSInteger)uniqueID
{
	return _uniqueID;
}

- (void)setCarbonRef:(EventHotKeyRef)carbonRef
{
	_carbonRef = carbonRef;
}

- (EventHotKeyRef)carbonRef
{
	return _carbonRef;
}

@end
