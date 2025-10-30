//
//  HistoryView.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import SwiftUI

class HistoryCoordinator: ObservableObject {
    @Published var sessions: [ScanSession] = []
    @Published var filteredSessions: [ScanSession] = []
    @Published var searchText = "" {
        didSet {
            applyFilters()
        }
    }
    @Published var selectedDate: Date? {
        didSet {
            applyFilters()
        }
    }
    
    private let viewModel = HistoryViewModel()
    
    init() {
        viewModel.onSessionsUpdated = { [weak self] sessions in
            self?.sessions = sessions
            self?.filteredSessions = sessions
        }
    }
    
    func loadSessions() {
        viewModel.loadSessions()
    }
    
    private func applyFilters() {
        viewModel.searchText = searchText
        viewModel.selectedDate = selectedDate
        filteredSessions = viewModel.filteredSessions
    }
}

struct HistoryView: View {
    @StateObject private var coordinator = HistoryCoordinator()
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск по имени устройства", text: $coordinator.searchText)
                        .textFieldStyle(.plain)
                    
                    if !coordinator.searchText.isEmpty {
                        Button(action: { coordinator.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                HStack {
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(coordinator.selectedDate != nil ? formatDate(coordinator.selectedDate!) : "Фильтр по дате")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if coordinator.selectedDate != nil {
                        Button("Сбросить") {
                            coordinator.selectedDate = nil
                        }
                        .font(.subheadline)
                    }
                }
            }
            .padding()
            
            if coordinator.filteredSessions.isEmpty {
                emptyStateView
            } else {
                List(coordinator.filteredSessions) { session in
                    SessionRow(session: session)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("История")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { coordinator.loadSessions() }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $coordinator.selectedDate)
        }
        .onAppear {
            coordinator.loadSessions()
        }
    }
}

    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("История пуста")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Начните сканирование, чтобы увидеть историю")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }


struct SessionRow: View {
    let session: ScanSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: sessionIcon)
                    .foregroundColor(sessionColor)
                
                Text(session.scanType.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text(session.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(session.timestamp, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                if !session.bluetoothDevices.isEmpty {
                    Label("\(session.bluetoothDevices.count) BT", systemImage: "antenna.radiowaves.left.and.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if !session.wifiDevices.isEmpty {
                    Label("\(session.wifiDevices.count) WiFi", systemImage: "wifi")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var sessionIcon: String {
        switch session.scanType {
        case .bluetooth: return "antenna.radiowaves.left.and.right"
        case .wifi: return "wifi"
        case .both: return "network"
        }
    }
    
    private var sessionColor: Color {
        switch session.scanType {
        case .bluetooth: return .blue
        case .wifi: return .green
        case .both: return .purple
        }
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Environment(\.dismiss) var dismiss
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Выберите дату", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Фильтр по дате")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}
