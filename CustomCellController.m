//
//  CustomCellController.m
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 01/22/2011.
//  Copyright 2011 Two Dogs Software, LLC
//
//  Based on work by, and portions copyright:
//  Steven Streeting on 07/08/2010.
//  Copyright 2010 Torus Knot Software Ltd. 
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following condition:
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CustomCellController.h"
#import "OutlineEntry.h" // The Core Data entity backing the cell

@implementation CustomCellController

@synthesize detailView;
@synthesize node;
@synthesize detailTitle;
@synthesize textColour;

// The main thing here is that the node ivar gets set so we know which
// item we're working with. Otherwise, just standard init.
-(id)initWithNode:(OutlineEntry *)n
{
	if ((self = [super init]))
    {
		node = n;
        if (![NSBundle loadNibNamed: @"CustomOutlineViewCells" owner: self])
        {
            self = nil;
        }
    }
    	
    return self;
}

-(void)showViews:(NSView*)parent frame:(NSRect)cellFrame highlight:(BOOL)highlight
{
	if (highlight)
		[self setValue:[NSColor whiteColor] forKey:@"textColour"];
	else
		[self setValue:[NSColor blackColor] forKey:@"textColour"];	
	
	// Logic for the idea of nested views, in the case of implementing group
	// views that contain individual items.
	NSView* nestedView;
	nestedView = detailView;
	
    [nestedView setFrame: cellFrame];
	
    if ([nestedView superview] != parent)
		[parent addSubview: nestedView];
}

-(void)hideViews
{
	[detailView removeFromSuperview];
}

@end
