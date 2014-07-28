//
//  GRViewController.h
//  _35_Search
//
//  Created by Exo-terminal on 7/1/14.
//  Copyright (c) 2014 Evgenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRViewController : UITableViewController

- (IBAction)actionSort:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
