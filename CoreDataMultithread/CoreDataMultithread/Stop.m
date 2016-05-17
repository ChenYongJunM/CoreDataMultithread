//
//  Stop.m
//  CoreDataImport
//
//  Created by Wild Yaoyao on 14/12/7.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "Stop.h"


@implementation Stop

@dynamic identifier;
@dynamic latitude;
@dynamic longitude;
@dynamic name;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@ - %@ (%f, %f)>", self.class, self, self.identifier, self.name, self.latitude.doubleValue, self.longitude.doubleValue];
}

@end
