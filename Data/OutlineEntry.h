//
//  OutlineEntry.h
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 1/25/11.
//  Copyright 2011 Two Dogs Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface OutlineEntry :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSSet* children;
@property (nonatomic, retain) OutlineEntry * parent;

@end


@interface OutlineEntry (CoreDataGeneratedAccessors)
- (void)addChildrenObject:(OutlineEntry *)value;
- (void)removeChildrenObject:(OutlineEntry *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

@end

