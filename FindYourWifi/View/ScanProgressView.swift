//
//  ScanProgressView.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import SwiftUI

struct ScanProgressView: View {
    @Binding var isScanning: Bool
    let progress: Double
    let foundDevicesCount: Int
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 15)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)
                
                VStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            
            VStack(spacing: 12) {
                Text("Сканирование...")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Найдено устройств: \(foundDevicesCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
