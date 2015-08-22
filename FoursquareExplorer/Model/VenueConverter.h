//
//  FSConverter.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VenueConverter : NSObject

// accepts a complete array of venues and parse them to Venue objects
+ (NSArray *)convertToObjects:(NSArray *)venues inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext ;
@end
