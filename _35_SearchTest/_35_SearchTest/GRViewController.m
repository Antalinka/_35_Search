//
//  GRViewController.m
//  _35_SearchTest
//
//  Created by Exo-terminal on 7/1/14.
//  Copyright (c) 2014 Evgenia. All rights reserved.
//

#import "GRViewController.h"
#import "NSString+Random.h"
#import "GRSection.h"

@interface GRViewController ()

@property(strong, nonatomic) NSArray* namesArray;
@property(strong, nonatomic) NSArray* sectionsArray;
@property(strong, nonatomic) NSOperation* currentOperation;

@end

@implementation GRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray* array = [NSMutableArray array];
    
    for (int i = 0; i < 100; i++) {
        [array addObject:[[NSString randomAlphanumericStringWithLength]capitalizedString]];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"self" ascending:YES];
    
    [array sortUsingDescriptors:@[sortDescriptor]];
    
    self.namesArray = array;
    
    
//    self.sectionsArray = [self generationSectionFromArray:self.namesArray withFilter:self.searchBar.text];
//    [self.tableView reloadData];
    
    [self generateSectionInBackGroundInArray:self.namesArray withFilter:self.searchBar.text];
}

-(void) generateSectionInBackGroundInArray:(NSArray*)array withFilter:(NSString*)filterString{
    [self.currentOperation cancel];
    
    __weak GRViewController* weakSelf = self;
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSArray* sectionArray = [weakSelf generationSectionFromArray:array withFilter:filterString];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.sectionsArray = sectionArray;
            [weakSelf.tableView reloadData];
            
            self.currentOperation = nil;
            
        });
    }];
    
//    NSQueue;
    
    [self.currentOperation start];
}

-(NSArray*)generationSectionFromArray:(NSArray*)array withFilter:(NSString*)filterString{
    
    NSMutableArray* sectionArray = [NSMutableArray array];
    
    NSString* currentLetter = nil;
    
    for (NSString* string  in array) {
        
        if ([filterString length] > 0 && [string rangeOfString:filterString].location == NSNotFound) {
            continue;
        }
        
        NSString* firstLetter = [string substringToIndex:1];
        
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
        
        [section.itemsArray addObject:string];
    }
    
    NSLog(@"%@", sectionArray);

    return sectionArray;
}


#pragma  mark - UITableViewDataSource


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray* array = [[NSMutableArray alloc]init];
    
    for (GRSection* section in self.sectionsArray) {
        [array addObject:section.sectionName];
    }
    
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [self.sectionsArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [[self.sectionsArray objectAtIndex:section]sectionName];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    GRSection* mySection = [self.sectionsArray objectAtIndex:section];
    
    return [mySection.itemsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
       cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    GRSection* section = [self.sectionsArray objectAtIndex:indexPath.section];
    NSString* name =[section.itemsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = name;
    
    
    
    return cell ;
    
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
    
//    self.sectionsArray = [self generationSectionFromArray:self.namesArray withFilter:searchText];
//    [self.tableView reloadData];
    
    [self generateSectionInBackGroundInArray:self.namesArray withFilter:searchText];

}















@end
