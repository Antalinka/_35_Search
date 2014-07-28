//
//  GRViewController.m
//  _35_Search
//
//  Created by Exo-terminal on 7/1/14.
//  Copyright (c) 2014 Evgenia. All rights reserved.
//

#import "GRViewController.h"
#import "GRStudent.h"
#import "GRTableViewCell.h"
#import "GRSection.h"


typedef enum{
    GRSortArrayDate,
    GRSortArrayFirstName,
    GRSortArrayLastName
}GRSortArray;

@interface GRViewController () <UISearchBarDelegate>

@property(strong, nonatomic)NSArray* studentArray;
@property(strong, nonatomic)NSArray* sectionArray;

@property(assign, nonatomic)NSInteger controlState;

@property(strong, nonatomic)NSThread* thread;

@end

@implementation GRViewController

-(void)loadView{
    
    [super loadView];
    
  }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.color = [UIColor blueColor];
    activityView.center = self.view.center;
    
    [self.view addSubview:activityView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [activityView startAnimating];
        
        int numberOfStudents = arc4random() % 2000 + 5;
        NSMutableArray* tempArray = [NSMutableArray array];
        
        for (int i = 0 ; i < numberOfStudents; i++) {
            
            GRStudent* student = [GRStudent randomStudent];
            [tempArray addObject:student];
            
        }
        
        self.controlState = GRSortArrayDate;
        self.studentArray = [self sortArray:tempArray forType:GRSortArrayDate];
        
        self.sectionArray = [self generationSectionFromArray:self.studentArray withFilter:self.searchBar.text];
        

        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            [activityView stopAnimating];
            
        });
        
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}


-(NSArray*)sortArray:(NSArray*)array forType:(GRSortArray) type{
    
    NSArray* sorted;
    NSSortDescriptor* firstName = [[NSSortDescriptor alloc]initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor* lastName = [[NSSortDescriptor alloc]initWithKey:@"lastName" ascending:YES];
    
    
    switch (type) {
            
        case GRSortArrayDate:
        {
            NSMutableArray* tempArray = [NSMutableArray arrayWithArray:array];
            
            [tempArray sortUsingDescriptors:[NSArray arrayWithObjects:firstName,lastName, nil]];
            sorted = [self sortArray:tempArray];
            
            return sorted;
        }
            break;
            
            
        case GRSortArrayFirstName:
        {
            sorted = [self sortArray:array];
            NSMutableArray* tempArray = [NSMutableArray arrayWithArray:sorted];
            [tempArray sortUsingDescriptors:[NSArray arrayWithObjects:firstName,lastName,nil]];
            
            return tempArray;
            
        }
            break;
            
            
        case GRSortArrayLastName:
        {
            sorted = [self sortArray:array];
            NSMutableArray* tempArray = [NSMutableArray arrayWithArray:sorted];
            [tempArray sortUsingDescriptors:[NSArray arrayWithObjects:lastName,firstName,nil]];
            
            return tempArray;
            
        }
            break;
            
        default:
            break;
    }
    
    return sorted;
}


-(NSArray*)sortArray:(NSArray*)array{
    
    NSDateFormatter* dt = [[NSDateFormatter alloc]init];
    [dt setDateFormat:@"MM"];

    NSArray* sorted = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString* string1 = [dt stringFromDate:[obj1 birthday]];
        NSString* string2 = [dt stringFromDate:[obj2 birthday]];
        
        return [string1 compare:string2];
    }];
    
    return sorted;
    
}

-(void)generationSectionInBackGroundFromArray:(NSArray*)array withFilter:(NSString*)filterString{
    
    if ([self.thread isExecuting]) {
        [self.thread cancel];
    }
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(searchThread) object:nil];
    self.thread.name = @"search";
    [self.thread start];
    
}

-(void)searchThread{
    
    self.sectionArray = [self generationSectionFromArray:self.studentArray withFilter:self.searchBar.text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

-(NSArray*)generationSectionFromArray:(NSArray*)array withFilter:(NSString*)filterString{
    
   NSMutableArray* sectionArray = [NSMutableArray array];
   NSString* currentLetter = nil;
    
   for (GRStudent* student  in array) {
        
        if ([filterString length] > 0 && [student.firstName rangeOfString:filterString].location == NSNotFound  && [student.lastName rangeOfString:filterString].location == NSNotFound) {
            continue;
        }
        
        NSString* firstLetter;

       if (self.controlState == GRSortArrayDate) {
           
           NSDateFormatter* dt = [[NSDateFormatter alloc]init];
           [dt setDateFormat:@"MMM"];
           
           firstLetter = [dt stringFromDate:student.birthday];
       }else if(self.controlState == GRSortArrayFirstName){
           
           firstLetter = [student.firstName substringToIndex:1];
           
       }else if(self.controlState == GRSortArrayLastName){
           
           firstLetter = [student.lastName substringToIndex:1];
           
       }
       
        GRSection* section = nil;
       
        if (![currentLetter isEqualToString:firstLetter]) {
            
            section = [[GRSection alloc]init];
            section.sectionName = firstLetter;
            section.itemsArray = [NSMutableArray array];
            currentLetter = firstLetter;
            
            [sectionArray addObject:section];
            
        }else{
            section = [sectionArray lastObject];
        }
        
        [section.itemsArray addObject:student];
    }
    
    return sectionArray;
}


#pragma mark - UITableViewDataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray* array = [[NSMutableArray alloc]init];
    
    for (GRSection* section in self.sectionArray) {
        [array addObject:section.sectionName];
    }
    
    return array;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [self.sectionArray count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    GRSection* sectionStudent = [self.sectionArray objectAtIndex:section];
    return sectionStudent.sectionName;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    GRSection* sectionStudent = [self.sectionArray objectAtIndex:section];
    
    return [sectionStudent.itemsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GRTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    
    GRSection* sectionStudent = [self.sectionArray objectAtIndex:indexPath.section];
    GRStudent* student = [sectionStudent.itemsArray objectAtIndex:indexPath.row];
    
    cell.name.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    NSString *dateString = [formatter stringFromDate:student.birthday];
    
    cell.birthdayStudent.text = dateString;
    
    return cell;
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self generationSectionInBackGroundFromArray:self.studentArray withFilter:searchText];
}

#pragma mark - Action


- (IBAction)actionSort:(UISegmentedControl *)sender {
    
    self.controlState = sender.selectedSegmentIndex;
    
    self.studentArray = [self sortArray:self.studentArray forType:(GRSortArray)sender.selectedSegmentIndex];
    
    self.sectionArray = [self generationSectionFromArray:self.studentArray withFilter:self.searchBar.text];
    
    [self.tableView reloadData];
    
}




















@end
