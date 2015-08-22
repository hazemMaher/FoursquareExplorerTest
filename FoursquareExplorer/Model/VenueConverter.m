//
//  FSConverter.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import "VenueConverter.h"
#import "Venue.h"


@implementation VenueConverter

+ (NSArray *)convertToObjects:(NSArray *)venues inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:venues.count];
    
    for (NSDictionary *v  in venues) {
        Venue *ann = [NSEntityDescription insertNewObjectForEntityForName:@"Venue"
            inManagedObjectContext:managedObjectContext];
        
        ann.name = v[@"name"];
        ann.venueId = v[@"id"];

        ann.address = v[@"location"][@"address"];
        ann.distance = v[@"location"][@"distance"];
        ann.latitude = [NSNumber numberWithDouble:[v[@"location"][@"lat"] doubleValue]]  ;
        ann.longitude =[NSNumber numberWithDouble:[v[@"location"][@"lng"] doubleValue]] ;
        
        [objects addObject:ann];
    }
    
    return objects;
}

@end
