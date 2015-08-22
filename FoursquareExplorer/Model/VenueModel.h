//
//  VenueModel.h
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Venue.h"

@protocol VenueModelDelegate ;

@interface VenueModel : NSObject

@property(nonatomic, assign) id<VenueModelDelegate>delegate ;

// retrieve the nearby venues within the desired radius and location whether its locally or server side.
// parse the nearby venues
// inform the delegate to update its View
- (void)getVenuesForLocation:(CLLocation *)location withRadius:(int)radius ;

//return the number of rows
-(NSInteger)numberOfRows ;

//return the venue at a specific index
-(Venue *)venueAtIndex:(int)index ;

//return the annotation array to be drawn on the map
-(NSArray *)annoationArr ;

// filter the nearby venues by radius
-(void)filterVenuesWithRadius:(int)radius ;

@end


@protocol VenueModelDelegate

// is called when there is internetConnection and data retrieved successfully from foursquare.
-(void)venueModelFinishedWithInternetConntection ;

// is called when there is no internetConnection and the data retrieved succesfully from Local Database
-(void)venueModelFailedWithNoInternetConnection ;

@end