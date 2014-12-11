//
//  ViewControllerMap.h
//  mapBYme
//
//  Created by Subramani B R on 6/20/14.
//  Copyright (c) 2014 Subramani B R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPoint.h"
@interface ViewControllerMap : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCentre;
    CLLocation *currentLocation;
    int distance;
    BOOL firstTime;


}
- (IBAction)atmAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *atmBtn;
@property (strong, nonatomic) IBOutlet MKMapView *map;
- (IBAction)barAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *barBtn;
- (IBAction)temAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *temBtn;

@end
