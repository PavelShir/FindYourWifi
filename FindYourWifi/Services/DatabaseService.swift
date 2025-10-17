//
//  DatabaseService.swift
//  FindYourWifi
//
//  Created by Павел Широкий on 17.10.2025.
//

import CoreData

class DatabaseService {
    static let shared = DatabaseService()
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "FindYourWifi")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    func saveSession(_ session: ScanSession, completion: ((Bool) -> Void)? = nil) {
        let context = container.viewContext
        
        context.perform {
            let sessionEntity = ScanSessionEntity(context: context)
            sessionEntity.id = session.id
            sessionEntity.timestamp = session.timestamp
            sessionEntity.scanType = session.scanType.rawValue
            
            for device in session.bluetoothDevices {
                let deviceEntity = BluetoothDeviceEntity(context: context)
                deviceEntity.id = device.id
                deviceEntity.name = device.name
                deviceEntity.uuid = device.uuid
                deviceEntity.rssi = Int16(device.rssi)
                deviceEntity.discoveredAt = device.discoveredAt
                deviceEntity.status = device.status.rawValue
                sessionEntity.addToBluetoothDevices(deviceEntity)
            }
            
            for device in session.wifiDevices {
                let deviceEntity = WiFiDeviceEntity(context: context)
                deviceEntity.id = device.id
                deviceEntity.ipAddress = device.ipAddress
                deviceEntity.macAddress = device.macAddress
                deviceEntity.hostname = device.hostname
                deviceEntity.discoveredAt = device.discoveredAt
                sessionEntity.addToWifiDevices(deviceEntity)
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion?(true)
                }
            } catch {
                print("Error saving session: \(error)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }
    
    func fetchSessions(predicate: NSPredicate? = nil, completion: @escaping ([ScanSession]) -> Void) {
        let context = container.viewContext
        
        context.perform {
            let request: NSFetchRequest<ScanSessionEntity> = ScanSessionEntity.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            do {
                let results = try context.fetch(request)
                let sessions = results.compactMap { self.convertToSession($0) }
                DispatchQueue.main.async {
                    completion(sessions)
                }
            } catch {
                print("Error fetching sessions: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    private func convertToSession(_ entity: ScanSessionEntity) -> ScanSession? {
        guard let id = entity.id,
              let timestamp = entity.timestamp,
              let scanTypeString = entity.scanType,
              let scanType = ScanSession.ScanType(rawValue: scanTypeString) else {
            return nil
        }
        
        let bluetoothDevices = (entity.bluetoothDevices?.allObjects as? [BluetoothDeviceEntity])?.compactMap { deviceEntity -> BluetoothDevice? in
            guard let id = deviceEntity.id,
                  let uuid = deviceEntity.uuid,
                  let discoveredAt = deviceEntity.discoveredAt,
                  let statusString = deviceEntity.status,
                  let status = BluetoothDevice.ConnectionStatus(rawValue: statusString) else {
                return nil
            }
            return BluetoothDevice(
                id: id,
                name: deviceEntity.name,
                uuid: uuid,
                rssi: Int(deviceEntity.rssi),
                status: status,
                discoveredAt: discoveredAt
            )
        } ?? []
        
        let wifiDevices = (entity.wifiDevices?.allObjects as? [WiFiDeviceEntity])?.compactMap { deviceEntity -> WiFiDevice? in
            guard let id = deviceEntity.id,
                  let ipAddress = deviceEntity.ipAddress,
                  let discoveredAt = deviceEntity.discoveredAt else {
                return nil
            }
            return WiFiDevice(
                id: id,
                ipAddress: ipAddress,
                macAddress: deviceEntity.macAddress,
                hostname: deviceEntity.hostname,
                discoveredAt: discoveredAt
            )
        } ?? []
        
        return ScanSession(
            id: id,
            timestamp: timestamp,
            bluetoothDevices: bluetoothDevices,
            wifiDevices: wifiDevices,
            scanType: scanType
        )
    }
    
    func deleteSession(id: UUID, completion: ((Bool) -> Void)? = nil) {
        let context = container.viewContext
        
        context.perform {
            let request: NSFetchRequest<ScanSessionEntity> = ScanSessionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try context.fetch(request)
                results.forEach { context.delete($0) }
                try context.save()
                DispatchQueue.main.async {
                    completion?(true)
                }
            } catch {
                print("Error deleting session: \(error)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }
    
    func clearAllHistory(completion: ((Bool) -> Void)? = nil) {
        let context = container.viewContext
        
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ScanSessionEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                DispatchQueue.main.async {
                    completion?(true)
                }
            } catch {
                print("Error clearing history: \(error)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }
}
