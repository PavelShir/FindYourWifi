//
//  HistoryViewModel.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import Foundation

class HistoryViewModel {
    var sessions: [ScanSession] = []
    var filteredSessions: [ScanSession] = []
    var searchText = "" {
        didSet {
            applyFilters()
        }
    }
    var selectedDate: Date? {
        didSet {
            applyFilters()
        }
    }
    
    var onSessionsUpdated: (([ScanSession]) -> Void)?
    
    func loadSessions() {
        DatabaseService.shared.fetchSessions { [weak self] sessions in
            self?.sessions = sessions
            self?.filteredSessions = sessions
            self?.onSessionsUpdated?(sessions)
        }
    }
    
    private func applyFilters() {
        var filtered = sessions
        
        if !searchText.isEmpty {
            filtered = filtered.filter { session in
                session.bluetoothDevices.contains { device in
                    device.name?.lowercased().contains(searchText.lowercased()) ?? false
                } || session.wifiDevices.contains { device in
                    device.hostname?.lowercased().contains(searchText.lowercased()) ?? false ||
                    device.ipAddress.contains(searchText)
                }
            }
        }
        
        if let date = selectedDate {
            let calendar = Calendar.current
            filtered = filtered.filter { session in
                calendar.isDate(session.timestamp, inSameDayAs: date)
            }
        }
        
        filteredSessions = filtered
        onSessionsUpdated?(filtered)
    }
}
