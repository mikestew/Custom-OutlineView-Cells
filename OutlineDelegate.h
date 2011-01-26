//
//  OutlineDelegate.h
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 1/24/11.
//  Copyright 2011 Two Dogs Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDSOutlineDelegate : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource> {
	IBOutlet NSTreeController *outlineItemsTree;
	IBOutlet NSOutlineView *myOutlineView;
	NSMutableDictionary* cellViewControllers;
}

@end
