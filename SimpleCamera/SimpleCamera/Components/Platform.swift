//
//  Platform.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

/// Struct which determines if the app running on a ios simulator, or device.
struct Platform {
    ///Returns *true* if the app running on a ios simulator, *false* if runs on a device.
    static let isSimulator: Bool = {
        var isSim = false
        
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        
        return isSim
    }()
}
