//
//  main.m
//  StarLight
//
//  Created by goodtime on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

id scriptFile;

int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    [pool drain];
    return NSApplicationMain(argc, (const char **) argv);
    
}