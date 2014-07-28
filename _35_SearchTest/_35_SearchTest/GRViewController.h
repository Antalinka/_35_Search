//
//  GRViewController.h
//  _35_SearchTest
//
//  Created by Exo-terminal on 7/1/14.
//  Copyright (c) 2014 Evgenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRViewController : UITableViewController <UISearchBarDelegate>

@property(weak,nonatomic) IBOutlet UISearchBar* searchBar;

@end
