//
//  ScanSession.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

struct ScanSession: Identifiable {
    let id: UUID
    let timestamp: Date
    let bluetoothDevices: [BluetoothDevice]
    let wifiDevices: [WiFiDevice]
    let scanType: ScanType
    
    enum ScanType: String {
        case bluetooth = "Bluetooth"
        case wifi = "Wi-Fi"
        case both = "Все устройства"
    }
}
