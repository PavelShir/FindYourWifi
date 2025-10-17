//
//  DeviceDetailView.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import SwiftUI

struct DeviceDetailView: View {
    let device: AnyHashable
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if let btDevice = device.base as? BluetoothDevice {
                    bluetoothDetailView(btDevice)
                } else if let wifiDevice = device.base as? WiFiDevice {
                    wifiDetailView(wifiDevice)
                }
            }
            .padding()
        }
        .navigationTitle("Детали устройства")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func bluetoothDetailView(_ device: BluetoothDevice) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            
            Text(device.name ?? "Неизвестное устройство")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 0) {
                detailRow(icon: "number", title: "UUID", value: device.uuid)
                Divider().padding(.leading, 50)
                detailRow(icon: "antenna.radiowaves.left.and.right", title: "RSSI", value: "\(device.rssi) dBm")
                Divider().padding(.leading, 50)
                detailRow(icon: "checkmark.circle", title: "Статус", value: device.status.rawValue)
                Divider().padding(.leading, 50)
                detailRow(icon: "clock", title: "Обнаружено", value: formatDate(device.discoveredAt))
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            signalStrengthCard(rssi: device.rssi)
        }
    }
    
    private func wifiDetailView(_ device: WiFiDevice) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.green.opacity(0.3), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "wifi")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .padding(.top, 20)
            
            Text(device.hostname ?? "Неизвестное устройство")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 0) {
                detailRow(icon: "network", title: "IP-адрес", value: device.ipAddress)
                Divider().padding(.leading, 50)
                
                if let mac = device.macAddress {
                    detailRow(icon: "barcode", title: "MAC-адрес", value: mac)
                    Divider().padding(.leading, 50)
                }
                
                if let hostname = device.hostname {
                    detailRow(icon: "desktopcomputer", title: "Имя хоста", value: hostname)
                    Divider().padding(.leading, 50)
                }
                
                detailRow(icon: "clock", title: "Обнаружено", value: formatDate(device.discoveredAt))
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func signalStrengthCard(rssi: Int) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Сила сигнала")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(rssi: rssi, bar: index))
                            .frame(width: 40, height: CGFloat(30 + index * 15))
                        
                        Text("\(index * 20)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(signalQuality(rssi: rssi))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func barColor(rssi: Int, bar: Int) -> Color {
        let strength = min(max(rssi + 100, 0), 100)
        let barThreshold = bar * 20
        
        if strength > barThreshold {
            return strength > 80 ? .green : strength > 60 ? .yellow : strength > 40 ? .orange : .red
        }
        return .gray.opacity(0.3)
    }
    
    private func signalQuality(rssi: Int) -> String {
        switch rssi {
        case -50...0: return "Отличный сигнал"
        case -60..<(-50): return "Хороший сигнал"
        case -70..<(-60): return "Средний сигнал"
        case -80..<(-70): return "Слабый сигнал"
        default: return "Очень слабый сигнал"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
