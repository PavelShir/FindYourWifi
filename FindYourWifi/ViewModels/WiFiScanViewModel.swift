//
//  WiFiScanViewModel.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

class WiFiScanViewModel: WiFiServiceDelegate {
    var devices: [WiFiDevice] = []
    var isScanning = false
    
    var onDevicesUpdated: (([WiFiDevice]) -> Void)?
    var onScanningChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let wifiService: WiFiService
    
    init(wifiService: WiFiService = WiFiService()) {
        self.wifiService = wifiService
        self.wifiService.delegate = self
    }
    
    func startScanning() {
        wifiService.startScanning()
    }
    
    func stopScanning() {
        wifiService.stopScanning()
    }
    
    func saveSession() {
        let session = ScanSession(
            id: UUID(),
            timestamp: Date(),
            bluetoothDevices: [],
            wifiDevices: devices,
            scanType: .wifi
        )
        DatabaseService.shared.saveSession(session) { success in
            print("Session saved: \(success)")
        }
    }
    
    // MARK: - WiFiServiceDelegate
    
    func wifiService(_ service: WiFiService, didDiscoverDevice device: WiFiDevice) {
        // Обрабатывается в didUpdateDevices
    }
    
    func wifiService(_ service: WiFiService, didUpdateDevices devices: [WiFiDevice]) {
        self.devices = devices
        onDevicesUpdated?(devices)
    }
    
    func wifiService(_ service: WiFiService, didChangeScanning isScanning: Bool) {
        self.isScanning = isScanning
        onScanningChanged?(isScanning)
    }
    
    func wifiService(_ service: WiFiService, didEncounterError error: Error) {
        onError?(error)
    }
}
