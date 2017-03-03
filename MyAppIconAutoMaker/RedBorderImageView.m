//
//  DropImageView.m
//  MyAppIconAutoMaker
//
//  Created by AnarL on 12/15/15.
//  Copyright © 2015 AnarL. All rights reserved.
//



#import "RedBorderImageView.h"

@implementation RedBorderImageView

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}


- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSData *data = nil;
    NSString *errorDescription;
    
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    
    /* look for paths in pasteboard */
    if ([[pasteboard types] containsObject:NSFilenamesPboardType])
        data = [pasteboard dataForType:NSFilenamesPboardType];
    
    if (data) {
        NSArray * fileNames = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&errorDescription];
        NSString * filePath = [fileNames lastObject];
        
        NSImage * pic = [[NSImage alloc] initWithContentsOfFile:filePath];
        
        [self setImage:pic];
    }
    
    /* accepted the drag operation */
    return YES;
}

- (void)setRoundCorner:(BOOL)roundCorner
{
    _roundCorner = roundCorner;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.

    [[NSGraphicsContext currentContext] restoreGraphicsState];
    NSBezierPath * bp = [self isRoundCorner] ? [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:NSWidth(dirtyRect) * CORNER_RADIUS_PERCENT yRadius:NSHeight(dirtyRect) * CORNER_RADIUS_PERCENT] : [NSBezierPath bezierPathWithRect:dirtyRect];
    [[NSColor redColor] setStroke];
    [bp stroke];
    [[NSGraphicsContext currentContext] saveGraphicsState];
}

@end
