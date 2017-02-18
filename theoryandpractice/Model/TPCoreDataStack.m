//
//  TPCoreDataStack.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "TPCoreDataStack.h"
#import <UIKit/UIKit.h>

static NSString *const modelName = @"Model";
static NSString *const storeFile = @"model.sqlite";

@implementation TPCoreDataStack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)defaultDataSource
{
    static id __defaultDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultDataSource = [[[self class] alloc] init];
        
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"mom"];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:storeFile];
        
        [__defaultDataSource setupCoreDataStackWithType:NSSQLiteStoreType modelURL:modelURL storeURL:storeURL];
    });
    return __defaultDataSource;
}

- (void)setupCoreDataStackWithType:(NSString *)storeType modelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL
{
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    NSError *error = nil;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:options error:&error];
    if (!store) {
        NSLog(@"Error: %@, %@", error.localizedDescription, error.userInfo);
        abort();
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
}

- (void)updateBadgeNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
    
    if([defaults boolForKey:@"badgesDisabled"]){
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        
    }else{
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Content"];
        request.predicate = [NSPredicate predicateWithFormat:@"isRead = NO OR isRead = nil"];
        NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    }
    
}


@end
