//
//  OutlineDelegate.m
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 1/24/11.
//  Copyright 2011 Two Dogs Software, LLC. All rights reserved.
//

#import "OutlineDelegate.h"
#import "Group.h"
#import "OutlineEntry.h"
#import "CustomCell.h"
#import "CustomCellController.h"

@implementation TDSOutlineDelegate

#pragma mark -
#pragma mark OutlineView datasource/delegate
- (void) awakeFromNib {
	// Use a dictionary to hold the custom 
	// view controllers to swap in and out
	cellViewControllers = 
		[[NSMutableDictionary alloc] init];
	CustomCell* cell = [[CustomCell alloc] init];
	[cell setEditable:YES];
	
	// Swap out the default NSCell with our own
	[[[myOutlineView tableColumns] 
		objectAtIndex:0] 
		setDataCell:cell];
}

- (void)outlineView:(NSOutlineView *)oview 
	willDisplayCell:(id)cell 
	forTableColumn:(NSTableColumn *)tableColumn 
	item:(id)item
{
	// Display the specific view for our cell.
	// The item we get is an NSTreeControllerTreeNode, 
	// but can be cast to our NSManagedObject
	OutlineEntry* node = [item representedObject];
	
	CustomCellController *cellCtrl = 
		[cellViewControllers objectForKey:node];
	
	if (!cellCtrl)
	{
		cellCtrl = 
			[[CustomCellController alloc] initWithNode:node];
		
		[cellViewControllers setObject:cellCtrl forKey:node];
	}
	
	CustomCell *mycell = (CustomCell *)cell;
	
	[mycell setController: cellCtrl];
}

-(void)hideViewsForItem:(OutlineEntry*)node
{
	CustomCellController *cellCtrl = [cellViewControllers objectForKey:node];
	if (cellCtrl)
	{
		[cellCtrl hideViews];
	}
	
	for (OutlineEntry* child in node.children)
		[self hideViewsForItem:child];
}
-(void)removeItems:(OutlineEntry*)node
{
	for (OutlineEntry* child in node.children)
		[self removeItems:child];
	
	CustomCellController *cellCtrl = [cellViewControllers objectForKey:node];
	if (cellCtrl)
	{
		[cellCtrl hideViews];
		[cellViewControllers removeObjectForKey:node];
	}
}

-(void)outlineViewItemDidCollapse:(NSNotification*)notification
{
	OutlineEntry* node = [[[notification userInfo] 
						   objectForKey:@"NSObject"] 
						   representedObject];
	
	// The collapsed item is the parent of 
	// the nodes that disappear
	for (OutlineEntry* child in node.children)
		[self hideViewsForItem:child];	
}

#pragma OutlineView Data Source
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (!item)
		return [[outlineItemsTree arrangedObjects] count];
	else
	{
		OutlineEntry* node = item;
		return [[node children] count];
	}
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	OutlineEntry* node = [item representedObject];
	return node;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	OutlineEntry* node = item;
	return [[node children] count];
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item)
	{
		OutlineEntry* node = item;
		return [[node children] objectAtIndex:index];
	}
	else
		return [[outlineItemsTree arrangedObjects] objectAtIndex:index];
}
// OutlineView Data Source

-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	return 75;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn*)col item:(id)item
{
	return YES;
}

-(void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	// required to set the value when editing
	OutlineEntry* node = item;
	
	[node setTitle: object];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	if ([[fieldEditor string] length] == 0)
	{
		// don't allow empty node names
		return NO;
	}
	else
	{
		return YES;
	}
}

@end
