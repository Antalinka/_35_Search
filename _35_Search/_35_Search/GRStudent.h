//
//  GRStudent.h
//  _35_Search
//
//  Created by Exo-terminal on 7/1/14.
//  Copyright (c) 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRStudent : NSObject

@property(strong, nonatomic)NSString* firstName;
@property(strong, nonatomic)NSString* lastName;
@property(strong, nonatomic)NSDate* birthday;

+(GRStudent*) randomStudent;

@end
