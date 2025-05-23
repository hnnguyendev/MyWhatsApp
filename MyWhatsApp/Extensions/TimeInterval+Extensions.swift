//
//  TimeInterval+Extensions.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 17/11/24.
//

import Foundation

extension TimeInterval {
    var formatElapsedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static var stubTimeInterval: TimeInterval {
        return TimeInterval()
    }
}
