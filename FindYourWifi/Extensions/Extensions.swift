//
//  Extensions.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

extension Date {
    func toString(format: String = "dd.MM.yyyy HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String {
    var isValidIP: Bool {
        let parts = self.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        for part in parts {
            guard let num = Int(part), num >= 0, num <= 255 else {
                return false
            }
        }
        return true
    }
}
