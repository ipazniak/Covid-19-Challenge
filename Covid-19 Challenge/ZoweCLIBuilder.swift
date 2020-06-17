//
//  ZoweCLIBuilder.swift
//  Covid-19 Challenge
//

import Foundation

class ZoweCLIBuilder {
    
    private let group: String
    private let action: String
    private let objectType: String
    private let objectName: String
    private let options: String
    private let stdinPipe: String
    
    init<T1: RawRepresentable, T2: RawRepresentable>(
        group: ZoweCLI.Groups,
        action: T1,
        objectType: T2,
        objectName: String? = nil,
        options: [ZoweCLI.Options]? = nil,
        stdinPipe: String? = nil) {
        self.group = group.rawValue
        self.action = action.rawValue as! String
        self.objectType = objectType.rawValue as! String
        self.objectName = (objectName != nil) ? " \(objectName!)" : ""
        self.options = (options != nil) ? options!.map {" --\($0.rawValue.replacingOccurrences(of: "_", with: "-"))"}.joined() : ""
        self.stdinPipe = (stdinPipe != nil) ? "echo \"\(stdinPipe!)\" | " : ""
    }
    
    func run() -> (success: Bool, data: Data) {
        let zoweCLI = "\(stdinPipe)zowe \(group) \(action) \(objectType)\(objectName)\(options)"
        
        let pathExportCommand = "export PATH=\"$PATH:\"\(String.Constants.pathToZowe)"
        
        let processId = ProcessInfo.processInfo.processIdentifier
        let pipe = Pipe()
        let subprocess = Process()
        subprocess.arguments = ["-c", "\(pathExportCommand); \(zoweCLI)"]
        subprocess.launchPath = String.Constants.pathToZsh
        subprocess.standardOutput = pipe
        subprocess.standardError = pipe
        
        logTaskHasStarted(pId: processId, input: zoweCLI)
        subprocess.launch()
        // Handling timeout in case of no response received
        var timeoutMessage: String?
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.Constants.timeOut90Sec) {
            if subprocess.isRunning {
                timeoutMessage = "Zowe request timed out. No server response received."
                subprocess.interrupt()
            }
        }
        
        subprocess.waitUntilExit()
        
        let file = pipe.fileHandleForReading
        let outputData = file.readDataToEndOfFile()
        
        let outputStatus = subprocess.terminationStatus == EX_OK ? "Success" : "Failure: \(errorType(for: subprocess.terminationStatus))"
        
        logTaskHasFinished(pId: processId, status: outputStatus, input: zoweCLI, output: outputData)
        
        if subprocess.terminationStatus == EX_OK {
            return (true, outputData)
        } else if outputData.count > 0 {
            return (false, outputData)
        } else if let timeoutMessage = timeoutMessage {
            return (false, Data(timeoutMessage.utf8))
        } else {
            return (false, Data("UNDEFINED".utf8))
        }
    }
    
    private func logTaskHasStarted(pId: Int32, input: String) {
        print("\nTask has started")
        print("----------------------")
        print("PID> \(pId)")
        print("INPUT> \(input)")
        print("----------------------\n")
    }
    
    private func logTaskHasFinished(pId: Int32, status: String, input: String, output: Data) {
        let outputString = String(data: output, encoding: .utf8)
        
        print("\nTask has finished")
        print("----------------------")
        print("PID> \(pId)")
        print("STATUS> \(status)")
        print("INPUT> \(input)")
        print("OUTPUT> \(outputString ?? "")")
        print("----------------------\n")
    }
    
    private func errorType(for terminationStatus: Int32) -> String {
        var errorType: String
        
        switch terminationStatus {
        case EX_USAGE: // 64
            errorType = "EX_USAGE: command line usage error"
        case EX_DATAERR: // 65
            errorType = "EX_DATAERR: data format error"
        case EX_NOINPUT: // 66
            errorType = "EX_NOINPUT: cannot open input"
        case EX_NOUSER: // 67
            errorType = "EX_NOUSER: addressee unknown"
        case EX_NOHOST: // 68
            errorType = "EX_NOHOST: host name unknown"
        case EX_UNAVAILABLE: // 69
            errorType = "EX_UNAVAILABLE: service unavailable"
        case EX_SOFTWARE: // 70
            errorType = "EX_SOFTWARE: internal software error"
        case EX_OSERR: // 71
            errorType = "EX_OSERR: system error (e.g., can't fork)"
        case EX_OSFILE: // 72
            errorType = "EX_OSFILE: critical OS file missing"
        case EX_CANTCREAT: // 73
            errorType = "EX_CANTCREAT: can't create (user) output file"
        case EX_IOERR: // 74
            errorType = "EX_IOERR: input/output error"
        case EX_TEMPFAIL: // 75
            errorType = "EX_TEMPFAIL: temp failure; user is invited to retry"
        case EX_PROTOCOL: // 76
            errorType = "EX_PROTOCOL: remote error in protocol"
        case EX_NOPERM: // 77
            errorType = "EX_NOPERM: permission denied"
        case EX_CONFIG: // 78
            errorType = "EX_CONFIG: configuration error"
        default:
            errorType = "UNKNOWN error type: \(terminationStatus)"
        }
        
        return errorType
    }
    
}
