//
//  UIApplication+Extensions.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 18/11/24.
//

import Foundation
import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication
            .shared
            .sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
