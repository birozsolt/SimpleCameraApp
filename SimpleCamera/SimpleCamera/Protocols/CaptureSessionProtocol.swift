//
//  CaptureSessionProtocol.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 31/10/2017.
//  Copyright © 2017 Biro, Zsolt. All rights reserved.
//

protocol CaptureSessionProtocol {
    
    /**
     Prepare the videoPreviewLayer for showing the camera input
     */
    func beginSession()
    
    /**
     Starting the capture session
     */
    func startSession()
    
    /**
     Stoping the capture session
     */
    func stopSession()
}
