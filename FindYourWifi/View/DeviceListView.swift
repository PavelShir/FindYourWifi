//
//  DeviceListView.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import SwiftUI

class DeviceListCoordinator: ObservableObject {
    @Published var devices: [AnyHashable] = []
    @Published var isScanning = false
    @Published var scanProgress: Double = 0.0
    
    private var bluetoothVM: BluetoothScanViewModel?
    private var wifiVM: WiFiScanViewModel?
    private var scanTimer: Timer?
    
    var selectedSegment: Int = 0
    
    func setupBluetoothViewModel() {
        let vm = BluetoothScanViewModel()
        
        vm.onDevicesUpdated = { [weak self] devices in
            self?.devices = devices.map { AnyHashable($0) }
        }
        
        vm.onScanningChanged = { [weak self] isScanning in
            self?.isScanning = isScanning
        }
        
        self.bluetoothVM = vm
    }
    
    func setupWiFiViewModel() {
        let vm = WiFiScanViewModel()
        
        vm.onDevicesUpdated = { [weak self] devices in
            self?.devices = devices.map { AnyHashable($0) }
        }
        
        vm.onScanningChanged = { [weak self] isScanning in
            self?.isScanning = isScanning
        }
        
        self.wifiVM = vm
    }
    
    func startScanning() {
        isScanning = true
        scanProgress = 0.0
        
        // Анимация прогресса
        scanTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.scanProgress += 0.0067 // 15 секунд
            
            if self.scanProgress >= 1.0 {
                timer.invalidate()
                self.isScanning = false
                self.saveSession()
            }
        }
        
        if selectedSegment == 0 {
            bluetoothVM?.startScanning()
        } else {
            wifiVM?.startScanning()
        }
    }
    
    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isScanning = false
        
        if selectedSegment == 0 {
            bluetoothVM?.stopScanning()
        } else {
            wifiVM?.stopScanning()
        }
    }
    
    func saveSession() {
        if selectedSegment == 0 {
            bluetoothVM?.saveSession()
        } else {
            wifiVM?.saveSession()
        }
    }
}

struct DeviceListView: View {
    @StateObject private var coordinator = DeviceListCoordinator()
    @State private var selectedSegment = 0
    @State private var selectedDevice: AnyHashable?
    
    var onDeviceSelected: ((AnyHashable) -> Void)?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Picker("Тип сканирования", selection: $selectedSegment) {
                    Text("Bluetooth").tag(0)
                    Text("Wi-Fi").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedSegment) { newValue in
                    coordinator.selectedSegment = newValue
                    coordinator.devices = []
                }
                
                if coordinator.isScanning {
                    ScanProgressView(
                        isScanning: .constant(coordinator.isScanning),
                        progress: coordinator.scanProgress,
                        foundDevicesCount: coordinator.devices.count
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    deviceListContent
                }
            }
            .navigationTitle("Устройства")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if coordinator.isScanning {
                            coordinator.stopScanning()
                        } else {
                            coordinator.startScanning()
                        }
                    }) {
                        Image(systemName: coordinator.isScanning ? "stop.circle" : "arrow.clockwise")
                            .imageScale(.large)
                    }
                }
            }
        }
        .onAppear {
            coordinator.setupBluetoothViewModel()
            coordinator.setupWiFiViewModel()
            coordinator.selectedSegment = selectedSegment
        }
    }
    
    @ViewBuilder
    private var deviceListContent: some View {
        if coordinator.devices.isEmpty {
            emptyStateView
        } else {
            List {
                ForEach(coordinator.devices, id: \.self) { device in
                    if selectedSegment == 0, let btDevice = device.base as? BluetoothDevice {
                        BluetoothDeviceRow(device: btDevice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedDevice = device
                                onDeviceSelected?(device)
                            }
                    } else if selectedSegment == 1, let wifiDevice = device.base as? WiFiDevice {
                        WiFiDeviceRow(device: wifiDevice)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedDevice = device
                                onDeviceSelected?(device)
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedSegment == 0 ? "antenna.radiowaves.left.and.right.slash" : "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Устройства не найдены")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Начать сканирование") {
                coordinator.startScanning()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct BluetoothDeviceRow: View {
    let device: BluetoothDevice
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name ?? "Неизвестное устройство")
                    .font(.headline)
                
                Text("UUID: \(device.uuid.prefix(8))...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    signalStrengthIndicator(rssi: device.rssi)
                    Text("RSSI: \(device.rssi) dBm")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                statusBadge(status: device.status)
                
                Text(device.discoveredAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func signalStrengthIndicator(rssi: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(signalColor(rssi: rssi, bar: index))
                    .frame(width: 3, height: CGFloat(6 + index * 3))
            }
        }
    }

private func signalColor(rssi: Int, bar: Int) -> Color {
    let strength = min(max(rssi + 100, 0), 100)
    let barThreshold = bar * 25
    
    if strength > barThreshold {
        return strength > 75 ? .green : strength > 50 ? .yellow : .orange
    }
    return .gray.opacity(0.3)
}

private func statusBadge(status: BluetoothDevice.ConnectionStatus) -> some View {
    Text(status.rawValue)
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor(status).opacity(0.2))
        .foregroundColor(statusColor(status))
        .cornerRadius(4)
}

private func statusColor(_ status: BluetoothDevice.ConnectionStatus) -> Color {
    switch status {
    case .connected: return .green
    case .connecting: return .orange
    case .disconnected: return .gray
    }
}
}

struct WiFiDeviceRow: View {
let device: WiFiDevice

var body: some View {
    HStack(spacing: 15) {
        Image(systemName: "wifi")
            .font(.title2)
            .foregroundColor(.green)
            .frame(width: 40)
        
        VStack(alignment: .leading, spacing: 4) {
            Text(device.hostname ?? "Неизвестное устройство")
                .font(.headline)
            
            Text("IP: \(device.ipAddress)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let mac = device.macAddress {
                Text("MAC: \(mac)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        
        Spacer()
        
        Text(device.discoveredAt, style: .time)
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    .padding(.vertical, 4)
}
}
