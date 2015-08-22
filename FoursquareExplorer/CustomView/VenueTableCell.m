//
//  VenueTableCell.m
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import "VenueTableCell.h"

@implementation VenueTableCell


-(void)updateCellWithVenue:(Venue *)venue
{
    [self.textLabel setText:venue.name];
    
    if (venue.address) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@",
                                     venue.distance,
                                     venue.address];
    } else {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@m",
                                     venue.distance];
    }
    
}

@end
