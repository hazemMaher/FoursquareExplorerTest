//
//  VenuesViewController.m
//  FoursquareExplorer
//
//  Created by Zomaaa on 8/21/15.
//  Copyright (c) 2015 HazemMaher. All rights reserved.
//

#import "VenuesViewController.h"
#import "Foursquare2.h"

#import "VenueConverter.h"
#import "Venue.h"

#import "VenueTableCell.h"
#import "AppDelegate.h"


@interface VenuesViewController ()
{
    VenueModel * _venueModel ;
}
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeight;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *radiusValue;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation VenuesViewController


#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLocationManager];
    [self initVenueModel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - InitMethods
-(void)initVenueModel
{
    _venueModel = [[VenueModel alloc]init];
    [_venueModel setDelegate:self];
}
-(void)initLocationManager
{
    //Load LocationManager
    self.locationManager = [[[CLLocationManager alloc]init]autorelease];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) {
            //  Ask For Authorization
            [self.locationManager requestWhenInUseAuthorization];
        
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                   [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            // We have authorization. Let's update location.
            [self.locationManager startUpdatingLocation];
        
        } else {
            // Permission is denied .
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No athorization"
            message:@"Please, enable access to your location"
            delegate:self
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Open Settings", nil];
            [alertView show];
        }
    } else {
        // for IOS 7
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Helping Methods

// update the mapView Annotations .
- (void)proccessAnnotations {
    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations:[_venueModel annoationArr]];
}

// remove all the annotations on the map except the current location for user.
- (void)removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    } else {
        for (id <MKAnnotation> annot_ in self.mapView.annotations) {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
    [annForRemove release];
}

// center the map on the user current location
- (void)setupMapForLocatoion:(CLLocation *)newLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.003;
    span.longitudeDelta = 0.003;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}

// when there is a new data , update the TableView & add the annotations for the MapView
-(void)updateViewContent
{
    [self.activityIndicator setHidden:YES];
    [self.tableView reloadData];
    [self proccessAnnotations];
}

// when there is no internetConnection animate the mapView to be smaller and enlarge the TableView
-(void)startAnimatingMapAndTable
{
    CGRect mapFrame = _mapView.frame ;
    CGRect tableFrame = _tableView.frame ;
    
    mapFrame.size.height = 5 ;
    
    tableFrame.origin.y -= _mapView.bounds.size.height - mapFrame.size.height ;
    tableFrame.size.height += _mapView.bounds.size.height - mapFrame.size.height ;
    
    _mapViewHeight.constant = 300 ;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
        
    } completion:nil];
}

#pragma mark - Actions
- (IBAction)radiusValueChanged:(UISlider *)sender {
    
    int radius = roundf(sender.value) ;
    
    [_radiusValue setText:[NSString stringWithFormat:@"%d",radius]];
    
    [_venueModel filterVenuesWithRadius:radius];
    [self updateViewContent];
}

#pragma mark - TableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 ;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_venueModel numberOfRows] ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"VenueCell";
    
    VenueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Venue *venue = [_venueModel venueAtIndex:(int)indexPath.row];
    [cell updateCellWithVenue:venue];
    
    return cell;
}

#pragma mark - LocationManagerDelegate

// when there is an available location for the user start getting the nearby venues and center the map according to user Location
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    
    [_venueModel getVenuesForLocation:newLocation withRadius:800];
    
    [self setupMapForLocatoion:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Location manager did fail with error %@", error);
    [self.locationManager stopUpdatingLocation];
}

// in the first time the user is asked for authorization this methods is called to start updating location to get the user location
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

#pragma mark - MapViewDelegate

// change the standard pin annotation view & show extera information when pin is pressed.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *s = @"ann";
    MKAnnotationView *pin = [[mapView dequeueReusableAnnotationViewWithIdentifier:s]retain];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.canShowCallout = YES;
        pin.image = [UIImage imageNamed:@"pin"];
        pin.calloutOffset = CGPointMake(0, 0);
        
        
    }
    return [pin autorelease];
}

#pragma mark - VenueModel Delegate

-(void)venueModelFinishedWithInternetConntection
{
    [self updateViewContent];
    
}

-(void)venueModelFailedWithNoInternetConnection
{
    [self updateViewContent];
    [self startAnimatingMapAndTable];
}

#pragma mark - Dealloc
-(void)dealloc
{
    [_venueModel release] ;
    [_mapView release];
    [_tableView release];
    [_mapViewHeight release];
    [_activityIndicator release];
    [_radiusValue release];
    
    [super dealloc];
}

@end
