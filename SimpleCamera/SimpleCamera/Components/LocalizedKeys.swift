//
//  LocalizedKeys.swift
//  SimpleCamera
//
//  Created by Biro, Zsolt on 12/02/2018.
//  Copyright © 2018 Biro, Zsolt. All rights reserved.
//

import UIKit

///Contains the localized keys from *Localizable.string* file.
enum LocalizedKeys: String {
    case camera
    case titleError
    case okButton
    case cancelButton
    case videoPlayerError
    case noCamerasAvailable
    case timeLapseBuildError
    case referenceFrameError
    case motionServiceError
    case videoName
    case videoExt
    case photoSaveError
    case lightFont
    case boldFont
    case onionEffectLayerError
    case titleWarning
    case albumCreateError
    case photoAlbumName
    case stabVideoName
    case videoStabilizerError
	
	var localized: String {
		switch self {
		default: return NSLocalizedString(self.rawValue, tableName: nil, bundle: Bundle.main, value: "", comment: "")
		}
	}
}
