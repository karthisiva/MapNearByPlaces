//
//  ViewControllerMap.m
//  mapBYme
//
//  Created by Subramani B R on 6/20/14.
//  Copyright (c) 2014 Subramani B R. All rights reserved.
//

#import "ViewControllerMap.h"
#define API_KEY @"AIzaSyBTJdWiRJ7atLQRcOZMhSfgLYZdzXiZOc4"

@interface ViewControllerMap ()

@end

@implementation ViewControllerMap

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //Define our reuse indentifier.
    static NSString *identifier = @"MapPoint";
    
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.leftCalloutAccessoryView=detailButton;

            annotationView.image=[UIImage imageNamed:@"red_point.png"];


        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
//        annotationView.animatesDrop = NO;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    NSLog(@"calloutAccessoryControlTapped: annotation = %@", view.annotation);
    
    
    
    
}
//set the region for current location

//- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
//{
//    
//    //Zoom back to the user location after adding a new set of annotations.
//    
//    //Get the center point of the visible map.
//    CLLocationCoordinate2D centre = [mv centerCoordinate];
//    
//    MKCoordinateRegion region;
//    
//    //If this is the first launch of the app then set the center point of the map to the user's location.
//    if (firstTime) {
//        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
//        firstTime=NO;
//    }else {
//        //Set the center point to the visible region of the map and change the radius to match the search radius passed to the Google query string.
//        region = MKCoordinateRegionMakeWithDistance(centre,distance,distance);
//    }
//    
//    //Set the visible region of the map.
//    [mv setRegion:region animated:YES];
//    
//}


- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    [self zoomToFitMapAnnotations:self.map];
}
- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}
//set region of current location distance calculation

//This delegate method will be called every time the user changes the map by zooming or by scrolling around to a new position.

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    //Get the east and west points on the map so we calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.map.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set our current distance instance variable.
    distance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set our current centre point on the map instance variable.
    currentCentre = self.map.centerCoordinate;
}
//current location delegate.....
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil) {
        
        NSLog(@"%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
        
    }
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    NSLog(@"Current identifier: %@", [[NSBundle mainBundle] bundleIdentifier]);

    [super viewDidLoad];
    self.title=@"Places";
    self.map.delegate=self;
    [self.map setShowsUserLocation:YES];
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
      [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager startUpdatingLocation];
    firstTime=YES;

    // Do any additional setup after loading the view from its nib.
}
-(void) Places: (NSString *)type
{
    
NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [NSString stringWithFormat:@"%i", distance], type, API_KEY];
    NSURL *request=[NSURL URLWithString:url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: request];
        [self performSelectorOnMainThread:@selector(reterive:) withObject:data waitUntilDone:YES];
    });
}

-(void)reterive:(NSData *)responseData
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:NSJSONReadingAllowFragments
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    [self annotationShow:places];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)atmAction:(id)sender
{
    UIButton *title=(UIButton *)sender;
    NSString *string=[title.currentTitle lowercaseString];
    [self Places:string];
}
- (IBAction)barAction:(id)sender
{
    UIButton *title=(UIButton *)sender;
    NSString *string=[title.currentTitle lowercaseString];
    [self Places:string];

}
- (IBAction)temAction:(id)sender
{
    UIButton *title=(UIButton *)sender;
    NSString *string=[title.currentTitle lowercaseString];
    [self Places:string];

}
- (void)annotationShow:(NSArray *)data
{
    //Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in self.map.annotations)
    {
        if ([annotation isKindOfClass:[MapPoint class]])
        {
            [self.map removeAnnotation:annotation];
        }
    }
    
    
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++)
    {
        
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        
        //There is a specific NSDictionary object that gives us location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        
        
        //Get our name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        //Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        //Create a new annotiation.
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        
                [self.map addAnnotation:placeObject];
    }
}



@end
