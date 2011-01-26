//
//  CustomOutlineViewCells_AppDelegate.h
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 1/24/11.
//  Copyright Two Dogs Software, LLC 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomOutlineViewCells_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (void) addOutlineItem:sender;
@end
