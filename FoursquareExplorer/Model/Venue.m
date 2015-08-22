//
//  Venue.m
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import "Venue.h"


@implementation Venue

@dynamic name;
@dynamic venueId;
@dynamic longitude;
@dynamic latitude;
@dynamic address;
@dynamic distance;

- (NSString *)title {
    return self.name;
}
- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.floatValue, self.longitude.floatValue);

}

@end
