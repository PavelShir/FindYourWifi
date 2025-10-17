//
//  WiFiService.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

protocol WiFiServiceDelegate: AnyObject {
    func wifiService(_ service: WiFiService, didDiscoverDevice device: WiFiDevice)
    func wifiService(_ service: WiFiService, didUpdateDevices devices: [WiFiDevice])
    func wifiService(_ service: WiFiService, didChangeScanning isScanning: Bool)
    func wifiService(_ service: WiFiService, didEncounterError error: Error)
}

class WiFiService {
    weak var delegate: WiFiServiceDelegate?
    
    private(set) var discoveredDevices: [WiFiDevice] = []
    private(set) var isScanning = false
    
    private var scanTimer: Timer?
    private let scanTimeout: TimeInterval = 15.0
    
    func startScanning() {
        discoveredDevices.removeAll()
        isScanning = true
        delegate?.wifiService(self, didChangeScanning: true)
        
        // Демо-сканирование
        DispatchQueue.global().async { [weak self] in
            self?.performScan()
        }
        
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanTimeout, repeats: false) { [weak self] _ in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil
        delegate?.wifiService(self, didChangeScanning: false)
    }
    
    private func performScan() {
        // Симуляция сканирования
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.addDemoDevice(ip: "192.168.1.1", mac: "00:11:22:33:44:55", hostname: "Router")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.addDemoDevice(ip: "192.168.1.100", mac: "AA:BB:CC:DD:EE:FF", hostname: "iPhone")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            self.addDemoDevice(ip: "192.168.1.101", mac: "11:22:33:44:55:66", hostname: "MacBook")
        }
    }
    
    private func addDemoDevice(ip: String, mac: String, hostname: String) {
        let device = WiFiDevice(ipAddress: ip, macAddress: mac, hostname: hostname)
        discoveredDevices.append(device)
        delegate?.wifiService(self, didDiscoverDevice: device)
        delegate?.wifiService(self, didUpdateDevices: discoveredDevices)
    }
}
