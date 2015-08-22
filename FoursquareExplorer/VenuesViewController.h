//
//  VenuesViewController.h
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "VenueModel.h"

@interface VenuesViewController : UIViewController < UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,MKMapViewDelegate,VenueModelDelegate>

@end
