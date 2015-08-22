//
//  Venue.h
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface Venue : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * venueId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * distance;

@end
