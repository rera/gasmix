//
//  MainViewController.m
//  GasMix
//
//  Created by David Cabrera on 3/14/14.
//  Copyright (c) 2014 ReraInc. All rights reserved.
//

#import "MainViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize editRatioButton, ratioSegmentedControl, measurementSegmentedControl, oilMeasurementLabel, fuelMeasurementLabel, oilTextField, fuelTextField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // hide app label
    if (self.view.frame.size.height < 568) {
        [self.appLabel setHidden:YES];
    }
    
    // clear numbers
    [self.oilTextField setText:@"0.00"];
    [self.fuelTextField setText:@"0.00"];
    
    // set ratios
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ratios"])
        ratios = [[NSUserDefaults standardUserDefaults] objectForKey:@"ratios"];
    else
        ratios = [[NSMutableArray alloc] initWithArray:@[@"16:1", @"24:1", @"32:1", @"40:1", @"50:1"]];
    
    // initialize values in ratio segment
    [self initRatios];
    
    // select default ratio
    activeRatio = [[NSUserDefaults standardUserDefaults] integerForKey:@"activeRatio"] ?: 0;
    [self.ratioSegmentedControl setSelectedSegmentIndex:activeRatio];
    [self ratioChanged:self];
    
    // set default edit mode to off
    editRatioMode = NO;
    
    // set measurement
    activeMeasurement = [[NSUserDefaults standardUserDefaults] integerForKey:@"activeMeasurement"] ?: 0;
    [self.measurementSegmentedControl setSelectedSegmentIndex:activeMeasurement];
    [self measurementChanged:self];
    
    // add text observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (IBAction)calculateOil:(id)sender {
    NSString* fuel = [self.fuelTextField text];
    fuel = [fuel stringByReplacingOccurrencesOfString:@"." withString:@""];
    [self.fuelTextField setText:[NSString stringWithFormat:@"%.2f", [fuel floatValue]/100.0f]];
    
    double ratio = [[[[ratios objectAtIndex:activeRatio] componentsSeparatedByString:@":"] objectAtIndex:0] doubleValue];
    double currentFuel = [[self.fuelTextField text] doubleValue];
    
    double oil = 0;
    if (activeMeasurement == 0)
        oil = (currentFuel * 128.0f) / ratio;
    else
        oil = (currentFuel * 1000) / ratio;
    
    [self.oilTextField setText:[NSString stringWithFormat:@"%.2f", oil]];
}

- (void)initRatios {
    for (int i = [self.ratioSegmentedControl numberOfSegments]-1; i >= 0; i--)
        [self.ratioSegmentedControl removeSegmentAtIndex:i animated:NO];
    
    for (int j = 0; j < [ratios count]; ++j)
        [self.ratioSegmentedControl insertSegmentWithTitle:[ratios objectAtIndex:j] atIndex:j animated:NO];
}

- (void)changeRatioPrompt {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Ratio (?:1)" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
    alertView.tag = 2;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    [[alertView textFieldAtIndex:0] setDelegate:self];
    [[alertView textFieldAtIndex:0] resignFirstResponder];
    [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alertView textFieldAtIndex:0] becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField* textField = [alertView textFieldAtIndex:0];
    if (buttonIndex == 1) {
        NSScanner *scanner = [NSScanner scannerWithString:textField.text];
        double val;
        [scanner scanDouble:&val];
        
        if([scanner isAtEnd] && val > 0 ){
            [ratios replaceObjectAtIndex:activeRatio withObject:[NSString stringWithFormat:@"%@:1", textField.text]];
            [self initRatios];
            [self.ratioSegmentedControl setSelectedSegmentIndex:activeRatio];
            
            [[NSUserDefaults standardUserDefaults] setObject:ratios forKey:@"ratios"];
            
            [self calculateOil:self];
        }
    }
}

- (void)closeKeyboard:(id)sender {
    [self.fuelTextField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)note {
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    
    [doneButton addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
        [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
        [keyboardView addSubview:doneButton];
        [keyboardView bringSubviewToFront:doneButton];
        
        [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-.02 delay:.0 options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
            self.view.frame = CGRectOffset(self.view.frame, 0, 0);
        } completion:nil];
    });
}

- (IBAction)ratioChanged:(id)sender {
    activeRatio = [self.ratioSegmentedControl selectedSegmentIndex];
    
    if (editRatioMode) {
        [self changeRatioPrompt];
    }
    
    [self calculateOil:self];
    
    [[NSUserDefaults standardUserDefaults] setInteger:activeRatio forKey:@"activeRatio"];
}

- (IBAction)measurementChanged:(id)sender {
    activeMeasurement = [self.measurementSegmentedControl selectedSegmentIndex];
    
    if (activeMeasurement == 0) {
        // us measurements
        [oilMeasurementLabel setText:@"ounces"];
        [fuelMeasurementLabel setText:@"gallons"];
    }
    else {
        // metric measurements
        [oilMeasurementLabel setText:@"milliliters"];
        [fuelMeasurementLabel setText:@"liters"];
    }
    
    [self calculateOil:self];
    
    [[NSUserDefaults standardUserDefaults] setInteger:activeMeasurement forKey:@"activeMeasurement"];
}

- (IBAction)changeEditingMode:(id)sender {
    editRatioMode = !editRatioMode;
    if (editRatioMode) {
        [self.editRatioButton.layer setCornerRadius:4.0f];
        [self.editRatioButton.layer setMasksToBounds:YES];
        self.editRatioButton.backgroundColor = [UIColor whiteColor];
        [self.editRatioButton setTitleColor:[self.tableView backgroundColor] forState:UIControlStateNormal];
    }
    else {
        self.editRatioButton.backgroundColor = [UIColor clearColor];
        [self.editRatioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
