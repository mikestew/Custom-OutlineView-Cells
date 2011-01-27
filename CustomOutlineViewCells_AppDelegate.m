//
//  CustomOutlineViewCells_AppDelegate.m
//  CustomOutlineViewCells
//
//  Created by Mike Stewart on 1/24/11.
//  Copyright Two Dogs Software, LLC 2011 . All rights reserved.
//

#import "CustomOutlineViewCells_AppDelegate.h"
#import "OutlineEntry.h"
#import "CustomCell.h"
#import "CustomCellController.h"

@implementation CustomOutlineViewCells_AppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
	// Set up some dummy data to display parent/child
	// Production app would not need this.
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"OutlineEntry" inManagedObjectContext:[self managedObjectContext]]];
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if ([results count] == 0) {
		[self createSampleData];
	}
}

- (void) addOutlineItem:sender {
	// Supports the button in the UI to add an outline item
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	OutlineEntry *outlineItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
									inManagedObjectContext:context];
	[outlineItem setTitle:@"New Item"];
	[outlineItem setNotes:@"Some random notes"];
	[outlineItem setCreationDate:[NSDate date]];
	[outlineItem release];
}

/**
 * Boilerplate template code
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"CustomOutlineViewCells"];
}

/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}

/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}

- (void) createSampleData {

	OutlineEntry *parentItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];
	[parentItem setTitle:@"Characters"];
	[parentItem setNotes:@"The crew-members of the Pequod are carefully drawn stylizations of human types and habits; critics have often described the crew as a 'self-enclosed universe'."];
	[parentItem setCreationDate:[NSDate date]];
	
	OutlineEntry *childItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];
	[childItem setTitle:@"Ishmael"];
	[childItem setNotes:@"The name has come to symbolize orphans, exiles, and social outcasts — in the opening paragraph of Moby-Dick, Ishmael tells the reader that he has turned to the sea out of a feeling of alienation from human society. In the last line of the book, Ishmael also refers to himself symbolically as an orphan. Maintaining the Biblical connection and emphasising the representation of outcasts, Ishmael is also the son of Abraham and the slave girl Hagar, before Isaac is born. In Genesis 21:10 Abraham's wife, Sarah, has Hagar and Ishmael exiled into the desert. Ishmael has a rich literary background (he has previously been a schoolteacher), which he brings to bear on his shipmates and events that occur while at sea."];
	[childItem setCreationDate:[NSDate date]];
	[childItem setParent:parentItem];
	[childItem release];

	childItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];
	[childItem setTitle:@"Elijah"];
	[childItem setNotes:@"The character Elijah (named for the Biblical prophet, Elijah, who is also referred to in the King James Bible as Elias), on learning that Ishmael and Queequeg have signed onto Ahab's ship, asks, 'Anything down there about your souls?'"];
	[childItem setCreationDate:[NSDate date]];
	[childItem setParent:parentItem];
	[childItem release];

	childItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];
	[childItem setTitle:@"Ahab"];
	[childItem setNotes:@"Ahab is the tyrannical captain of the Pequod who is driven by a monomaniacal desire to kill Moby Dick, the whale that maimed him on the previous whaling voyage. Despite the fact that he's a Quaker, he seeks revenge in defiance of his religion's well-known pacifism. Ahab's name comes directly from the Bible (see 1 Kings 16:28)."];
	[childItem setCreationDate:[NSDate date]];
	[childItem setParent:parentItem];
	[childItem release];

	childItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];
	[childItem setTitle:@"Moby Dick"];
	[childItem setNotes:@"He is a giant, albino sperm whale and the main antagonist of the novel. He had bitten off Ahab's leg, and Ahab swore revenge. The cetacean also attacked the Rachel and killed the captain's son. Although the novel is named for him, he only appears at the end of it and kills the entire crew with the exception of Ishmael. Unlike the other characters, the reader does not have access to Moby Dick's thoughts and motivations, but the whale is still an integral part of the novel. Moby Dick is sometimes considered to be a symbol of a number of things, among them God, nature, fate, the ocean, and the very universe itself."];
	[childItem setCreationDate:[NSDate date]];
	[childItem setParent:parentItem];
	[childItem release];


	childItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];

	[childItem setTitle:@"Mates"];
	[childItem setNotes:@"The three mates of the Pequod are all from New England."];
	[childItem setCreationDate:[NSDate date]];
	[childItem setParent:parentItem];
	
	OutlineEntry *grandChildItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];

	[grandChildItem setTitle:@"Starbuck"];
	[grandChildItem setNotes:@"Starbuck is alone among the crew in objecting to Ahab's quest, declaring it madness to want revenge on an animal, which lacks reason. Starbuck advocates continuing the more mundane pursuit of whales for their oil. But he lacks the support of the crew in his opposition to Ahab, and is unable to persuade them to turn back. Despite his misgivings, he feels himself bound by his obligations to obey the captain."];
	[grandChildItem setCreationDate:[NSDate date]];
	[grandChildItem setParent:childItem];

	grandChildItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];

	[grandChildItem setTitle:@"Stubb"];
	[grandChildItem setNotes:@"Stubb, the second mate of the Pequod, is from Cape Cod, and always seems to have a pipe in his mouth and a smile on his face."];
	[grandChildItem setCreationDate:[NSDate date]];
	[grandChildItem setParent:childItem];
	[childItem release];
	[grandChildItem release];


	parentItem = [NSEntityDescription insertNewObjectForEntityForName:@"OutlineEntry" 
								inManagedObjectContext:managedObjectContext];
	[parentItem setTitle:@"Themes"];
	[parentItem setNotes:@"Moby-Dick is a symbolic work, but also includes chapters on natural history. Major themes include obsession, religion, idealism, courage versus pragmatism, revenge, racism, sanity, hierarchical relationships, and politics. All of the members of the crew↓ have biblical-sounding, improbable, or descriptive names, and the narrator deliberately avoids specifying the exact time of the events (such as the giant whale disappearing into the dark abyss of the ocean) and some other similar details. These together suggest that the narrator — and not just Melville — is deliberately casting his tale in an epic and allegorical mode."];
	[parentItem setCreationDate:[NSDate date]];

	[parentItem release];
	[childItem release];
}

@end
