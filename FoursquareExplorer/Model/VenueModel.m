//
//  VenueModel.m
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import "VenueModel.h"
#import "AppDelegate.h"
#import "VenueConverter.h"
#import "Foursquare2.h"

@interface VenueModel()
{
    NSArray * _nearbyVenues ;
    NSMutableArray * _filteredVenues ;
}
@property (nonatomic,strong)NSManagedObjectContext * managedObjectContext ;
@property (nonatomic,strong)NSPersistentStoreCoordinator * persistentStoreCoordinator ;

@end

@implementation VenueModel

#pragma mark - Init
-(instancetype)init
{
    if (self = [super init]) {
        AppDelegate * appDelegate = [[UIApplication sharedApplication]delegate];
        _managedObjectContext = appDelegate.managedObjectContext ;
        _persistentStoreCoordinator = appDelegate.persistentStoreCoordinator ;
    }
    
    return self ;
}

#pragma mark - Get all Venues
-(void)getVenuesForLocation:(CLLocation *)location withRadius:(int)radius
{
    //get all the data from Foursquare
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(800)
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      
                                      if (success) {
                                          //when there is internetConnection delete all records in CoreData then save the new data and inform the delegate to update the view
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          [self deleteAllVenues];
                                          _nearbyVenues = [[VenueConverter convertToObjects:venues inManagedObjectContext:_managedObjectContext]retain];
                                          _filteredVenues = [[NSMutableArray arrayWithArray:_nearbyVenues]retain];
                                          
                                          [self saveVenues];
                                          
                                          [self.delegate venueModelFinishedWithInternetConntection];
                                      }else
                                      {
                                          //when there is no internetConnection load the data saved in CoreData and inform the delegate to update the view
                                          [self loadVenuesLocally];
                                          _filteredVenues = [[NSMutableArray arrayWithArray:_nearbyVenues]retain];
                                          
                                          [self.delegate venueModelFailedWithNoInternetConnection];
                                      }
                                      
                                      
                                  }];
}

#pragma mark - Helping Methods
-(NSInteger)numberOfRows
{
    return _filteredVenues.count ;
}
-(Venue *)venueAtIndex:(int)index
{
    return [_filteredVenues objectAtIndex:index];
}
-(NSArray *)annoationArr
{
    return _filteredVenues ;
}

-(void)filterVenuesWithRadius:(int)radius
{
    _filteredVenues = [[NSMutableArray arrayWithArray:_nearbyVenues]retain];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distance <= %d",radius];
    [_filteredVenues filterUsingPredicate:predicate];
    
}

#pragma mark - CoreData Operations
-(void)deleteAllVenues
{
    
    NSPersistentStore *store = [_persistentStoreCoordinator.persistentStores lastObject];
    NSError *error = nil;
    NSURL *storeURL = store.URL;
    [_persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}
-(void)saveVenues
{
    
    NSError *error = nil;
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
-(void)loadVenuesLocally
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:_managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    
    NSError *error = nil;
    _nearbyVenues = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error]retain];
    
    if (_nearbyVenues == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [fetchRequest release];
    
}
-(void)dealloc
{
    [super dealloc];
    [_nearbyVenues release];
    [_filteredVenues release];
}


@end
