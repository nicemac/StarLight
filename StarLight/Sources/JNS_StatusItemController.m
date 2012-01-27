//
// JNS_StatusItemController.m
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

#import "JNS_StatusItemController.h"

static NSFont *menuBarFont = nil;
static NSDictionary *attributes = nil;

@implementation JNS_StatusItemController

// Since this really is a singleton, let's set some static values we'll use later.

+ (void)initialize {
	static BOOL isInitialzed = NO;
	if (!isInitialzed) {
		menuBarFont = [[NSFont menuBarFontOfSize:12.0] retain];
		attributes = [[NSDictionary alloc] initWithObjectsAndKeys:menuBarFont, NSFontAttributeName, [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName, nil];
		isInitialzed = YES;
	}
}

// Init
- (id)init { 
	if (self == [super init]) {
	} 
	return self; 
}

- (void)dealloc {
	[self releaseStatusItem];
	[super dealloc];
}


// Actually create the status item and assign the menu.
- (void)createStatusItemWithMenu:(NSMenu *)_menu {
	menu = [_menu retain];
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:menu];
	[statusItem setEnabled:YES];
	[self updateDisplay];
}

// Actually create the status item and assign the menu.
- (void)showMenu{
    [statusItem popUpStatusItemMenu:[statusItem menu]];
}

// Allows updating the title and/or icon as desired.
- (void)updateDisplay {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	MenuAppDisplayOption displayOption = (MenuAppDisplayOption)[standardUserDefaults integerForKey:@"title_display"];
	NSString *title = [standardUserDefaults stringForKey:@"menu_title"];
	NSString *iconPath = [standardUserDefaults stringForKey:@"icon_path"];
    NSString *iconAltPath = [standardUserDefaults stringForKey:@"icon_altpath"];

	NSAttributedString *titleAttributedString = [[[NSAttributedString alloc] initWithString:title attributes:attributes] autorelease];

	if (displayOption == MenuAppDisplayOptionTitleOnly) {
		if (!animationTimer) [statusItem setImage:nil];
		[statusItem setLength:NSVariableStatusItemLength];
		[statusItem setAttributedTitle:titleAttributedString];
		[statusItem setToolTip:nil];

	} else {
		if (!animationTimer) {
			NSImage *image = [[[NSImage alloc] initWithContentsOfFile:iconPath] autorelease];
			if (!image) image = [NSImage imageNamed:NSImageNameActionTemplate];
            
            NSImage *altimage = [[[NSImage alloc] initWithContentsOfFile:iconAltPath] autorelease];
			if (!altimage) altimage = [NSImage imageNamed:NSImageNameActionTemplate];
            
			[statusItem setImage:image];
            [statusItem setAlternateImage:altimage];

            //[statusItem setAlternateImage:statusHighlightImage];
		}

		if (displayOption == MenuAppDisplayOptionIconOnly) {
			[statusItem setLength:NSSquareStatusItemLength];
			[statusItem setAttributedTitle:nil];
			[statusItem setToolTip:title];
			
		} else if (displayOption == MenuAppDisplayOptionTitleAndIcon) {
			[statusItem setLength:NSVariableStatusItemLength];
			[statusItem setAttributedTitle:titleAttributedString];
			[statusItem setToolTip:nil];
		}
	}
}

// Allows the menu icon to animate (or not) or to use a spinning progress indicator 
// for better performance. Use the icon animation to get a more customized display.
- (void)updateAnimation:(MenuAppAnimationOption)animationOption {
	if (animationOption == MenuAppAnimationOptionNone) {
		if ([statusItem view]) [statusItem setView:nil];
		[statusItem setHighlightMode:YES];
		[statusItem setMenu:menu];
		[self toggleIconAnimation:NO];

	} else if (animationOption == MenuAppAnimationOptionAnimateIcon) {
		if ([statusItem view]) [statusItem setView:nil];
		[statusItem setHighlightMode:YES];
		[statusItem setMenu:menu];
		[self toggleIconAnimation:YES];

	} else if (animationOption == MenuAppAnimationOptionUseSpinner) {
		[self toggleIconAnimation:NO];
		NSProgressIndicator *progressIndicator = [[[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0.0, 4.0, 16.0, 16.0)] autorelease];
		[progressIndicator setControlSize:NSSmallControlSize];
		[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
		[progressIndicator setUsesThreadedAnimation:YES];
		[progressIndicator setDisplayedWhenStopped:YES];
		[progressIndicator startAnimation:nil];
		float titleWidth = 0.0;
		NSTextField *titleTextField = nil;
		NSString *title = [statusItem title];
		if (title && [title length]) {
			titleWidth = [title sizeWithAttributes:attributes].width + 8.0;
			titleTextField = [[[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, titleWidth, 22.0)] autorelease];
			[titleTextField setFont:menuBarFont];
			[titleTextField setStringValue:title];
			[titleTextField setDrawsBackground:NO];
			[titleTextField setBezeled:NO];
		}
		float progressIndicatorXOrigin = 7.0;
		NSView *view = [[[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 22.0 + titleWidth, 22.0)] autorelease];
		if (titleTextField) {
			[view addSubview:titleTextField];
			[titleTextField setFrameOrigin:NSMakePoint(22.0, -2.0)];
			progressIndicatorXOrigin = 5.0;
		}
		[view addSubview:progressIndicator];
		[progressIndicator setFrameOrigin:NSMakePoint(progressIndicatorXOrigin, 4.0)];
		[statusItem setView:view];
	}
}

// Creates a timer to cycle through a set of images for the icon to create an animation
// decrease the interval to speed up the animation. Since we have 12 images for our
// animation in this demo app, we use a duration of (1.0 / 12.0) so that one full revolution
// of our icons will take 1 second.
- (void)toggleIconAnimation:(BOOL)shouldStart {
	if (animationTimer) {
		[animationTimer invalidate];
		[animationTimer release];
		animationTimer = nil;
	}
	[self updateDisplay];
	if (shouldStart) {
		updateCount = 2;
		[statusItem setImage:[[[NSImage imageNamed:@"updateImage_1"] copy] autorelease]];
		animationTimer = [[NSTimer scheduledTimerWithTimeInterval:(1.0 / 12.0) target:self selector:@selector(updateIcon:) userInfo:nil repeats:YES] retain];
	}
}

// The method actually called by the timer to cycle to the next image in the sequence.
- (void)updateIcon:(NSTimer *)timer {
	[statusItem setImage:[[[NSImage imageNamed:[NSString stringWithFormat:@"updateImage_%d", updateCount]] copy] autorelease]];
	updateCount++;
	if (updateCount > 12) updateCount = 1;
}

// Get rid of the menu when we're done. removeStatusItem: is key so that the space allocated for
// the title & icon in the menubar is immediately reclaimed. Most apps fail to do this and leave
// an unsightly gap in the menubar until another application becomes active. Let's be a good Cocoa
// citizen and not do that.
- (void)releaseStatusItem {  
	if (animationTimer) {
		[animationTimer invalidate];
		[animationTimer release];
		animationTimer = nil;
	}
	if (menu) [menu release]; menu = nil;
	if (statusItem) {
		[[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
		[statusItem release]; 
		statusItem = nil; 
	}
}

@end
