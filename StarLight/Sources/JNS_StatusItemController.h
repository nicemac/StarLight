//
// JNS_StatusItemController.h
// MenuApp
//
// Created by Jonathan Nathan, JNSoftware LLC on 1/12/11.
// Copyright 2011 JNSoftware LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, 
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or 
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Cocoa/Cocoa.h>

// The typedef enums aren't strictly necessary but they help to clarify 
// what's going on in your code. We're also using 1-based indexes because this
// app is rooted in AppleScript which also uses 1-based indexes as opposed to
// Objective-C that uses 0-based indexes.

typedef enum {
	MenuAppDisplayOptionTitleOnly		= 1, 
	MenuAppDisplayOptionIconOnly		= 2, 
	MenuAppDisplayOptionTitleAndIcon	= 3
} MenuAppDisplayOption;

typedef enum {
	MenuAppAnimationOptionNone			= 1, 
	MenuAppAnimationOptionAnimateIcon	= 2, 
	MenuAppAnimationOptionUseSpinner	= 3
} MenuAppAnimationOption;

@interface JNS_StatusItemController : NSObject {
	NSStatusItem *statusItem;
	NSTimer *animationTimer;
	int updateCount;
	NSMenu *menu;
}

- (void)createStatusItemWithMenu:(NSMenu *)_menu;
- (void)showMenu;
- (void)updateDisplay;
- (void)updateAnimation:(MenuAppAnimationOption)animationOption;
- (void)toggleIconAnimation:(BOOL)shouldStart;
- (void)releaseStatusItem;

@end
