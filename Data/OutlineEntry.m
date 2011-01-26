// 
//  OutlineEntry.m
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 1/25/11.
//  Copyright 2011 Two Dogs Software, LLC. All rights reserved.
//

#import "OutlineEntry.h"


@implementation OutlineEntry 

@dynamic creationDate;
@dynamic title;
@dynamic notes;
@dynamic modifiedDate;
@dynamic children;
@dynamic parent;

// copyWithZone is needed because it gets called when our object goes into
// the cell controller and the outlineview. Have not tracked down who is 
// responsible for making this call.
- (id)copyWithZone:(NSZone*)zone
{
	OutlineEntry *copy = [self retain];
	return copy;
}

@end
