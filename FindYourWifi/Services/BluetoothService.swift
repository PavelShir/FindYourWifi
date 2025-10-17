//
//  BluetoothService.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import CoreBluetooth

protocol BluetoothServiceDelegate: AnyObject {
    func bluetoothService(_ service: BluetoothService, didDiscoverDevice device: BluetoothDevice)
    func bluetoothService(_ service: BluetoothService, didUpdateDevices devices: [BluetoothDevice])
    func bluetoothService(_ service: BluetoothService, didChangeScanning isScanning: Bool)
    func bluetoothService(_ service: BluetoothService, didEncounterError error: Error)
}

class BluetoothService: NSObject {
    weak var delegate: BluetoothServiceDelegate?
    
    private(set) var discoveredDevices: [BluetoothDevice] = []
    private(set) var isScanning = false
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [UUID: (peripheral: CBPeripheral, rssi: NSNumber)] = [:]
    private var scanTimer: Timer?
    private let scanTimeout: TimeInterval = 15.0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        
        discoveredDevices.removeAll()
        discoveredPeripherals.removeAll()
        isScanning = true
        delegate?.bluetoothService(self, didChangeScanning: true)
        
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanTimeout, repeats: false) { [weak self] _ in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil
        delegate?.bluetoothService(self, didChangeScanning: false)
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth готов к использованию")
        } else if central.state == .poweredOff {
            let error = NSError(domain: "BluetoothService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bluetooth выключен"])
            delegate?.bluetoothService(self, didEncounterError: error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        discoveredPeripherals[peripheral.identifier] = (peripheral, RSSI)
        
        let device = BluetoothDevice(peripheral: peripheral, rssi: RSSI)
        
        if let index = discoveredDevices.firstIndex(where: { $0.uuid == device.uuid }) {
            discoveredDevices[index] = device
        } else {
            discoveredDevices.append(device)
            delegate?.bluetoothService(self, didDiscoverDevice: device)
        }
        
        delegate?.bluetoothService(self, didUpdateDevices: discoveredDevices)
    }
}

extension BluetoothService: CBPeripheralDelegate {
    // Реализация делегатов для подключения к устройствам
}
