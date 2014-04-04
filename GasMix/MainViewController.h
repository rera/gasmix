//
//  MainViewController.h
//  GasMix
//
//  Created by David Cabrera on 3/14/14.
//  Copyright (c) 2014 ReraInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSegmentedControl.h"

@interface MainViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate> {
    bool editRatioMode;
    int activeRatio;
    NSMutableArray *ratios;
    int activeMeasurement;
    id keyboardObserver;
}

@property (strong, nonatomic) IBOutlet UIButton *editRatioButton;
@property (strong, nonatomic) IBOutlet MBSegmentedControl *ratioSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *measurementSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *oilMeasurementLabel;
@property (strong, nonatomic) IBOutlet UILabel *fuelMeasurementLabel;
@property (strong, nonatomic) IBOutlet UITextField *oilTextField;
@property (strong, nonatomic) IBOutlet UITextField *fuelTextField;
@property (strong, nonatomic) IBOutlet UILabel *appLabel;


@end
