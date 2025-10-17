//
//  BluetoothScanViewModel.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

class BluetoothScanViewModel: BluetoothServiceDelegate {
    var devices: [BluetoothDevice] = []
    var isScanning = false
    
    var onDevicesUpdated: (([BluetoothDevice]) -> Void)?
    var onScanningChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let bluetoothService: BluetoothService
    
    init(bluetoothService: BluetoothService = BluetoothService()) {
        self.bluetoothService = bluetoothService
        self.bluetoothService.delegate = self
    }
    
    func startScanning() {
        bluetoothService.startScanning()
    }
    
    func stopScanning() {
        bluetoothService.stopScanning()
    }
    
    func saveSession() {
        let session = ScanSession(
            id: UUID(),
            timestamp: Date(),
            bluetoothDevices: devices,
            wifiDevices: [],
            scanType: .bluetooth
        )
        DatabaseService.shared.saveSession(session) { success in
            print("Session saved: \(success)")
        }
    }

    
    // MARK: - BluetoothServiceDelegate
    
    func bluetoothService(_ service: BluetoothService, didDiscoverDevice device: BluetoothDevice) {
        // Обрабатывается в didUpdateDevices
    }
    
    func bluetoothService(_ service: BluetoothService, didUpdateDevices devices: [BluetoothDevice]) {
        self.devices = devices
        onDevicesUpdated?(devices)
    }
    
    func bluetoothService(_ service: BluetoothService, didChangeScanning isScanning: Bool) {
        self.isScanning = isScanning
        onScanningChanged?(isScanning)
    }
    
    func bluetoothService(_ service: BluetoothService, didEncounterError error: Error) {
        onError?(error)
    }
}
