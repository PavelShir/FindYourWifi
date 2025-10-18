//
//  WiFiDevice.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

struct WiFiDevice: Identifiable, Hashable {
    let id: UUID
    let ipAddress: String
    let macAddress: String?
    let hostname: String?
    let discoveredAt: Date
    
    init(ipAddress: String, macAddress: String? = nil, hostname: String? = nil, discoveredAt: Date = Date()) {
        self.id = UUID()
        self.ipAddress = ipAddress
        self.macAddress = macAddress
        self.hostname = hostname
        self.discoveredAt = discoveredAt
    }
    
    init(id: UUID, ipAddress: String, macAddress: String? = nil, hostname: String? = nil, discoveredAt: Date) {
        self.id = id  
        self.ipAddress = ipAddress
        self.macAddress = macAddress
        self.hostname = hostname
        self.discoveredAt = discoveredAt
    }
}
