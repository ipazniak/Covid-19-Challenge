//
//  ZoweManager.swift
//  Covid-19 Challenge
//

import Foundation

class Zowe {
    
    enum ZoweCLIGroups: String {
        case files          // zos-files            | Manage z/OS data sets
        case jobs           // zos-jobs             | Manage z/OS jobs
        case zosmf          // zosmf                | Interact with z/OSMF
    }
    
    enum ZoweCLIGroupZosmf: String {
        case check          // check                | Confirm that z/OSMF is running on a specified system
    }
    
    enum ZoweCLIGroupFiles: String {
        case cre            // create               | Create data sets
        case del            // delete               | Delete a data set or Unix System Services file
        case ls             // list                 | List data sets and data set members (optionally, lists their details and attributes)
        case ul             // upload               | Upload the contents of a file to z/OS data sets
    }
    
    enum ZoweCLIGroupJobs: String {
        case can            // cancel               | Cancel a single job by job ID (this cancels the job if it is running or on input)
        case sub            // submit               | Submit jobs (JCL) contained in data sets
        case vw             // view                 | View details of z/OS jobs on spool/JES queues
    }
    
    enum ZoweCLIGroupZosmfCheck: String {
        case status         // status               | Confirm that z/OSMF is running on a system specified in your profile
    }
    
    enum ZoweCLIGroupFilesCreate: String {
        // create
        case bin            // data-set-binary      | Create executable data sets
        case dsc            // data-set-c           | Create data sets for C code programming
        case classic        // data-set-classic     | Create classic data sets (JCL, HLASM, CBL, etc...)
        case pds            // data-set-partitioned | Create partitioned data sets (PDS)
        case ps             // data-set-sequential  | Create physical sequential data sets (PS)
        case vsam           // data-set-vsam        | Create a VSAM cluster
        case dir            // uss-directory        | Create a UNIX directory
        case file           // uss-file             | Create a UNIX file
        case zfs            // zos-file-system      | Create a z/OS file system
    }
    
    enum ZoweCLIGroupFilesDelete: String {
        // delete
        case ds             // data-set             | Delete a data set or data set member permanently
        case vsam           // data-set-vsam        | Delete a VSAM cluster permanently
        case uss            // uss-file             | Delete a Unix Systems Services (USS) File or directory permanently
        case zfs            // zos-file-system      | Delete a z/OS file system permanently
    }
    
    enum ZoweCLIGroupFilesList: String {
        // list
        case am             // all-members          | List all members of a pds
        case ds             // data-set             | List data sets
        case fs             // file-system          | Listing mounted z/OS filesystems
        case uss            // uss-files            | List USS files
    }
    
    enum ZoweCLIGroupFilesUpload: String {
        // upload
        case dtp            // dir-to-pds           | Upload files from a local directory to a partitioned data set (PDS)
        case dtu            // dir-to-uss           | Upload a local directory to a USS directory
        case ftds           // file-to-data-set     | Upload the contents of a file to a z/OS data set
        case ftu            // file-to-uss          | Upload content to a USS file from local file
        case stds           // stdin-to-data-set    | Upload the content of a stdin to a z/OS data set
    }
    
    enum ZoweCLIGroupJobsCancel: String {
        // cancel
        case job            // job                  | Cancel a single job by job ID
    }
    
    enum ZoweCLIGroupJobsSubmit: String {
        // submit
        case ds             // data-set             | Submit a job contained in a data set
        case lf             // local-file           | Submit a job contained in a local file
        case stdin          // in                   | Submit a job read from standard in
    }
    
    enum ZoweCLIGroupJobsView: String {
        // view
        case jsbj           // job-status-by-jobid  | View status details of a z/OS job
        case sfbi           // spool-file-by-id     | View a spool file from a z/OS job
    }
    
    enum ZoweCLIOptions: String {
        case binary         // --binary
        case directory      // --directory
        case rfj            // --response-format-json
        case vasc           // --view-all-spool-content
        case wfa            // --wait-for-active
        case wfo            // --wait-for-output
    }
    
    private let group: String
    private let action: String
    private let objectType: String
    private let objectName: String?
    private let options: [String]?
    
    private init(group: String, action: String, objectType: String, objectName: String? = nil, options: [ZoweCLIOptions]? = nil) {
        self.group = group
        self.action = action
        self.objectType = objectType
        self.objectName = objectName
        self.options = options?.map { $0.rawValue }
    }
    
    convenience init<T1: RawRepresentable, T2: RawRepresentable>(
        group: ZoweCLIGroups,
        action: T1,
        objectType: T2,
        objectName: String? = nil,
        options: [ZoweCLIOptions]? = nil) {
        self.init(group: group.rawValue,
                  action: action.rawValue as! String,
                  objectType: objectType.rawValue as! String,
                  objectName: objectName,
                  options: options)
    }
    
    func run(onCompletion: (_ success: Bool, _ output: Data) -> Void) {
        //var zoweCLICommand = "zowe \(self.group.rawValue) \(self.action.rawValue) \(self.objectType.rawValue)\((self.objectName != nil) ? " \"\(self.objectName!)\"" : "")"
        let zoweGroup = "zowe \(self.group)"
        let zoweAction = "\(self.action)"
        let zoweObjectType = "\(self.objectType)"
        let zoweObjectName = "\((self.objectName != nil) ? " \(self.objectName!)" : "")"
        var zoweCLI = "\(zoweGroup) \(zoweAction) \(zoweObjectType)\(zoweObjectName)"
        self.options?.forEach { zoweCLI += " --\($0)" }
        
        let pathExportCommand = "export PATH=\"$PATH:\"\(String.Constants.pathToZowe)"
        
        let processId = ProcessInfo.processInfo.processIdentifier
        let pipe = Pipe()
        let subprocess = Process()
        subprocess.arguments = ["-c", "\(pathExportCommand); \(zoweCLI)"]
        subprocess.launchPath = String.Constants.pathToZsh
        subprocess.standardOutput = pipe
        subprocess.standardError = pipe
        
        logJobHasStarted(pId: processId, input: zoweCLI)
        subprocess.launch()
        // Handling timeout in case of no response received
        var timeoutMessage: String?
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.Constants.timeOutApi) {
            if subprocess.isRunning {
                timeoutMessage = "Zowe request timed out. No server response received."
                subprocess.interrupt()
            }
        }
        
        subprocess.waitUntilExit()
        
        let file = pipe.fileHandleForReading
        let outputData = file.readDataToEndOfFile()
        
        let outputStatus = subprocess.terminationStatus == EX_OK ? "Success" : "Failure: \(errorType(for: subprocess.terminationStatus))"
        
        logJobHasFinished(pId: processId, status: outputStatus, input: zoweCLI, output: outputData)
        
        if subprocess.terminationStatus == EX_OK {
            onCompletion(true, outputData)
        } else if outputData.count > 0 {
            onCompletion(false, outputData)
        } else if let timeoutMessage = timeoutMessage {
            onCompletion(false, Data(timeoutMessage.utf8))
        } else {
            onCompletion(false, Data("UNDEFINED".utf8))
        }
    }
    
    private func logJobHasStarted(pId: Int32, input: String) {
        print("\nJob has started")
        print("----------------------")
        print("PID> \(pId)")
        print("INPUT> \(input)")
        print("----------------------\n")
    }
    
    private func logJobHasFinished(pId: Int32, status: String, input: String, output: Data) {
        let outputString = String(data: output, encoding: .utf8)
        
        print("\nJob has finished")
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
