//
//  OpenCVWrapper.h
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject
    + (NSURL*)videoStab:(NSURL*)videoUrl : (NSURL*)result;
@end
