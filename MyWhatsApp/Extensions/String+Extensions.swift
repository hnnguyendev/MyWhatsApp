//
//  String+Extensions.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 5/11/24.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
