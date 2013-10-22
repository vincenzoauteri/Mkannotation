//
//  HGMovingAnnotationView.m
//  HGMovingAnnotationSample
//
//  Created by Rotem Rubnov on 14/3/2011.
//	Copyright (C) 2011 100 grams software
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "HGMovingAnnotationView.h"
#import "HGMovingAnnotation.h"
#import <QuartzCore/QuartzCore.h>

#define POSITIONKEY @"positionAnimation"
#define BOUNDSKEY @"boundsAnimation"

@interface HGMovingAnnotationView()
- (void) setPosition : (id) pos;
@property MKMapRect oldMapRect;
@end


@implementation HGMovingAnnotationView

@synthesize mapView; 

- (id) initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
		self.canShowCallout = YES;
		self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//		UIImageView *icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol.png"]] autorelease];
//		icon.bounds = CGRectMake(0, 0, 32, 32);
//		self.leftCalloutAccessoryView = icon;
	}
	return self;
}


- (void) setAnnotation:(id <MKAnnotation>)anAnnotation
{
	if (anAnnotation) {
		if (!observingMovement) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMoveAnnotation:) name:kObjectMovedNotification object:anAnnotation]; 
			observingMovement = YES;
		}
	}
	else {
		[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	}
   
	[super setAnnotation : anAnnotation]; 

}


- (void) didMoveAnnotation : (NSNotification*) notification 
{
//	if ([self.layer animationForKey:POSITIONKEY] != nil) {
//		//attempt to add animation while another is still running. ignore this and let the previous animation finish.
//		return;
//	}
	
	HGMovingAnnotation *movingObject = (HGMovingAnnotation *)[notification object]; 
	lastReportedLocation = movingObject.currentLocation;
    //[[self mapView] layoutSubviews];
    
	[self performSelectorOnMainThread:@selector(setPosition:) withObject:[NSValue valueWithPointer:&lastReportedLocation] waitUntilDone:YES];
}

- (void) setPosition : (id) posValue;
{
    //extract the mapPoint from this dummy (wrapper) CGPoint struct
    MKMapPoint mapPoint = *(MKMapPoint*)[(NSValue*)posValue pointerValue];
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    
    CGPoint toPos = [self.mapView convertCoordinate:coord toPointToView:self.mapView];
    NSLog(@"Coodrs %f %f",toPos.x,toPos.y);
    
   // self.mapView.center = self.center;
    //self.mapView.visibleMapRect = MKMapRectMake(lastReportedLocation.x,lastReportedLocation.y,self.mapView.frame.size.width,self.mapView.frame.size.height);
    
    

    if (MKMapRectContainsPoint(self.mapView.visibleMapRect, mapPoint ) && MKMapRectEqualToRect(self.oldMapRect,self.mapView.visibleMapRect)) {
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        animation.fromValue = [NSValue valueWithCGPoint:self.center];
        animation.toValue = [NSValue valueWithCGPoint:toPos];
        animation.duration = 0.8;
        animation.delegate = self;
        animation.fillMode = kCAFillModeForwards;
        //[self.layer removeAllAnimations];
        [self.layer addAnimation:animation forKey:POSITIONKEY];
        
        //NSLog(@"setPosition ANIMATED %x from (%f, %f) to (%f, %f)", self, self.center.x, self.center.y, toPos.x, toPos.y);
    }
    
 
    self.center = toPos;
    self.oldMapRect = self.mapView.visibleMapRect;
    
    
}




@end
