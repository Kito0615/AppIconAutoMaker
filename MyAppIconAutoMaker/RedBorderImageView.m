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
        NSArray * fileNames = [NSPropertyListSerialization propertyListFromData:data                                                               mutabilityOption:kCFPropertyListImmutable format:nil errorDescription:&errorDescription];
        NSString * filePath = [fileNames lastObject];
        
        NSLog(@"fileNames : %@", fileNames);
        NSLog(@"file Path:%@", filePath);
        
        NSImage * pic = [[NSImage alloc] initWithContentsOfFile:filePath];
        
        NSLog(@"pic:%@", pic);
        
        [self setImage:pic];
    }
    
    
    /* we accepted the drag operation */
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
