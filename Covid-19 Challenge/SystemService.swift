//
//  SystemService.swift
//  Covid-19 Challenge
//

import Foundation

class SystemService {
    
    func modelIdentifier() -> String {
        var modelIdentifier: String?
        
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        defer { IOObjectRelease(service) }

        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data, let cString = modelData.withUnsafeBytes({ $0.baseAddress?.assumingMemoryBound(to: UInt8.self) }) {
            modelIdentifier = String(cString: cString)
        }
    
        return modelIdentifier?.replacingOccurrences(of: ",", with: "_", options: .literal, range: nil) ?? "UNDEFINED"
    }
    
    func systemVersion() -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "macOS\(osVersion.majorVersion)_\(osVersion.minorVersion)_\(osVersion.patchVersion)"
    }
    
    func dateInFormat(format: String, date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
