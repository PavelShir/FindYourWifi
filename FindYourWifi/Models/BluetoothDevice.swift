//
//  BluetoothDevice.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation
import CoreBluetooth

struct BluetoothDevice: Identifiable, Hashable {
    let id: UUID
    let name: String?
    let uuid: String
    let rssi: Int
    var status: ConnectionStatus
    let discoveredAt: Date
    
    enum ConnectionStatus: String {
        case disconnected = "Отключено"
        case connecting = "Подключение..."
        case connected = "Подключено"
    }
    
    init(peripheral: CBPeripheral, rssi: NSNumber, discoveredAt: Date = Date()) {
        self.id = UUID()
        self.name = peripheral.name
        self.uuid = peripheral.identifier.uuidString
        self.rssi = rssi.intValue
        self.status = .disconnected
        self.discoveredAt = discoveredAt
    }
    
    init(id: UUID, name: String?, uuid: String, rssi: Int, status: ConnectionStatus, discoveredAt: Date) {
        self.id = id
        self.name = name
        self.uuid = uuid
        self.rssi = rssi
        self.status = status
        self.discoveredAt = discoveredAt
    }
}

