//
//  NSString+Random.h
//  _35_SearchTest
//
//  Created by Exo-terminal on 7/1/14.
//  Copyright (c) 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Random)

+ (NSString *)randomAlphanumericStringWithLength;
+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;
@end
