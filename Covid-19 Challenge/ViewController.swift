//
//  ViewController.swift
//  Covid-19 Challenge
//

import Cocoa

class Covid19ViewController: NSViewController {
    
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet var loadingStatusLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    var proceedFlag: Bool = true
    
    // MARK: - Life Cycle Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Launch API service and then launch Zowe commands sequence upon API response received
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.retrieveApiData(from: String.Constants.covidApi) { [weak self] csvToUpload in
                self?.zoweSequenceLaunch(with: csvToUpload)
            }
        }
    }
    
    // MARK: - Business Logic Handling
    
    /// The method launches Zowe CLI commands in the given sequence
    /// - Parameter csvToUpload: CSV data to upload to the sequential data set
    private func zoweSequenceLaunch(with csvToUpload: String) {
        zoweCheckConnection()
        zoweCreateDataSet(dataSetName: String.Constants.dataSetPS, dataSetType: .ps)
        zoweUpload(dataSetName: String.Constants.dataSetPS, stdinPipe: csvToUpload)
        zoweUpload(dataSetName: String.Constants.dataSetCBL, dataSetMember: String.Constants.dataSetMemberCBL, stdinPipe: String.COBOL.source)
        zoweUpload(dataSetName: String.Constants.dataSetJCL, dataSetMember: String.Constants.dataSetMemberJCL, stdinPipe: String.JCL.source)
        if let jobId = zoweSubmitJob(dataSetName: String.Constants.zId, dataSetMember: String.Constants.dataSetMemberJCL) {
            zoweViewJobSpoolFile(jobId: jobId, spoolFileId: 103)
            zoweDeleteJob(jobId: jobId)
        }
        zoweDeleteDataSet(dataSetName: String.Constants.dataSetPS)
    }
    
    /// The method launches an asynchronous API task to obtain Covid-19 latest statistics data for all US states in JSON format
    /// - Parameters:
    ///   - address: API URL address to obtain data from
    ///   - onCompletion: The list of instructions to perform upon data retrieval completion
    private func retrieveApiData(from address: String, onCompletion: @escaping (_ csv: String) -> Void) {
        startLoadingStatus(with: .loading_JSON_data_from_API)
        
        ApiManager().load(url: address, httpMethod: .get) { [weak self] (success: Bool, response: Data?) in
            if success, let responseUnwrapped = response {
                // Convert JSON data to CSV data
                let csv = responseUnwrapped.jsonDataToCsv() { error in self?.displayErrorPrompt(title: "API JSON Parse Error", message: error) }
                
                self?.stopLoadingStatus()
                onCompletion(csv)
            } else {
                self?.displayErrorPrompt(title: "API Data Retrieval Error")
            }
        }
    }
    
    /// The method launches Zowe CLI check command of the following format:
    /// zowe zosmf check status --rfj
    private func zoweCheckConnection() {
        guard proceedFlag else { return }
        startLoadingStatus(with: .checking_Zowe_connection_status)
            
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.zosmf,
            action: ZoweCLI.Groups.Zosmf.check,
            objectType: ZoweCLI.Groups.Zosmf.Check.status,
            options: [.rfj])
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .zosmf)
        
        stopLoadingStatus()
    }
    
    /// The method launches Zowe CLI create command of the following format:
    /// zowe files create data-set-sequential Z99998.PS --rfj
    /// - Parameters:
    ///   - dataSetName: Data set name parameter, for example: Z99998.PS
    ///   - dataSetType: Data set type parameter, for example: PDS, PS, VSAM etc
    private func zoweCreateDataSet(dataSetName: String, dataSetType: ZoweCLI.Groups.Files.Create) {
        guard proceedFlag else { return }
        startLoadingStatus(with: .performing_Zowe_create_dataSet_command)
        
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.files,
            action: ZoweCLI.Groups.Files.cre,
            objectType: dataSetType,
            objectName: dataSetName,
            options: [.rfj])
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .files)
        
        stopLoadingStatus()
    }
    
    /// The method launches Zowe CLI upload stdin-to-data-set command of the following format:
    /// zowe files upload stdin-to-data-set "Z99998.JCL(COVID19J)" --rfj
    /// - Parameters:
    ///   - dataSetName: Data set name parameter, for example: Z99998.JCL
    ///   - dataSetMember: Data set member parameter (can be omitted), for example: COVID19J
    ///   - stdinPipe: Data to pass to stdin for Zowe upload command
    private func zoweUpload(dataSetName: String, dataSetMember: String? = nil, stdinPipe: String) {
        guard proceedFlag else { return }
        startLoadingStatus(with: .performing_Zowe_upload_command)
        
        let objectName = "\"\(dataSetName)\((dataSetMember != nil) ? "(\(dataSetMember!))" : "")\""
        
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.files,
            action: ZoweCLI.Groups.Files.ul,
            objectType: ZoweCLI.Groups.Files.Upload.stds,
            objectName: objectName,
            options: [.rfj],
            stdinPipe: stdinPipe)
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .files)
        
        stopLoadingStatus()
    }
    
    /// The method launches Zowe CLI delete data-set command of the following format:
    /// zowe files delete data-set "Z99998.PS" --for-sure --rfj
    /// - Parameter dataSetName: Data set name parameter, for example: Z99998.PS
    private func zoweDeleteDataSet(dataSetName: String) {
        let objectName = "\"\(dataSetName)\""
        
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.files,
            action: ZoweCLI.Groups.Files.del,
            objectType: ZoweCLI.Groups.Files.Delete.ds,
            objectName: objectName,
            options: [.for_sure, .rfj])
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .files)
    }
    
    /// The method launches Zowe CLI submit job command of the following format:
    /// zowe jobs submit data-set "Z99998.JCL(COVID19J)" --wfo --rfj
    /// - Parameters:
    ///   - dataSetName: Data set name parameter, for example: Z99998.JCL
    ///   - dataSetMember: Data set member parameter (can be omitted), for example: COVID19J
    /// - Returns: Value of jobId to use for viewing job results or deleting the job
    private func zoweSubmitJob(dataSetName: String, dataSetMember: String) -> String? {
        guard proceedFlag else { return nil }
        startLoadingStatus(with: .performing_Zowe_submit_job_command)
        
        let objectName = "\"\(dataSetName).JCL(\(dataSetMember))\""
        
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.jobs,
            action: ZoweCLI.Groups.Jobs.sub,
            objectType: ZoweCLI.Groups.Jobs.Submit.ds,
            objectName: objectName,
            options: [.wfo, .rfj])
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .jobs, zoweAction: .sub)
        
        stopLoadingStatus()
        
        var jobId: String?
        if let response = responseObject, let dataDict = response.data as? [String: Any], let jobIdField = dataDict["jobid"] as? String {
            jobId = jobIdField
        }
        
        return jobId
    }
    
    /// The method launches Zowe CLI view spool-file-by-id command of the following format:
    /// zowe jobs view spool-file-by-id JOB00256 103 --rfj
    /// - Parameters:
    ///   - jobId: Value of jobId to use for viewing job results, for example: JOB00256
    ///   - spoolFileId: Value of spoolFileId to use for viewing job results, for example: 103
    private func zoweViewJobSpoolFile(jobId: String, spoolFileId: Int) {
        guard proceedFlag else { return }
        startLoadingStatus(with: .performing_Zowe_view_job_spool_file)
        
        let objectName = jobId + " " + String(spoolFileId)
        
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.jobs,
            action: ZoweCLI.Groups.Jobs.vw,
            objectType: ZoweCLI.Groups.Jobs.View.sfbi,
            objectName: objectName,
            options: [.rfj])
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .jobs, zoweAction: .vw)
        
        stopLoadingStatus()
        
        if let response = responseObject, let dataField = response.data as? String {
            updateOutputTextView(with: dataField)
        }
    }
    
    /// The method launches Zowe CLI delete job command of the following format:
    /// zowe jobs delete job JOB00256 --rfj
    /// - Parameter jobId: Value of jobId to use for deleting the job, for example: JOB00256
    private func zoweDeleteJob(jobId: String) {
        guard proceedFlag else { return }
        
        let zoweCommand = ZoweCLIBuilder(
            group: ZoweCLI.Groups.jobs,
            action: ZoweCLI.Groups.Jobs.del,
            objectType: ZoweCLI.Groups.Jobs.Delete.job,
            objectName: jobId,
            options: [.rfj])
        
        let responseTuple: (success: Bool, data: Data) = zoweCommand.run()
        let responseObject = zoweProcessResponseTuple(responseTuple, zoweGroup: .jobs, zoweAction: .del)
    }
    
    /// The method launches Zowe CLI response verification process, depending on Zowe specific group and action
    /// - Parameters:
    ///   - responseTuple: Unix stdout/stderr with subprocess result status and data
    ///   - zoweGroup: Zowe group to validate Zowe response for
    ///   - zoweAction: Zowe action to validate Zowe response for
    /// - Returns: Zowe Response as a validated object with relevant properties parsed
    private func zoweProcessResponseTuple(_ responseTuple: (success: Bool, data: Data), zoweGroup: ZoweCLI.Groups, zoweAction: ZoweCLI.Groups.Jobs? = nil) -> ZoweCLIResponse? {
        if responseTuple.success {
            // Get dictionary out of response json data
            let responseDict = responseTuple.data.jsonDataToDictionary() { errorMessage in
                displayErrorPrompt(title: "Zowe JSON Parse Error", message: errorMessage)
            }
            // Get response object out of dictionary
            if let responseObject = ZoweCLIResponse(responseDict) {
                // Check response validity
                if responseObject.isValid(zoweGroup, zoweAction) {
                    return responseObject
                } else {
                    displayErrorPrompt(title: "Zowe Response Error", message: responseObject.stderr.count > 0 ? responseObject.stderr : responseObject.stdout)
                }
            }
        } else {
            // Check if output data has JSON-compatible format - coz Zowe error responses fall here
            if let errorDict = responseTuple.data.jsonDataToDictionary(onFailure: { _ in }), let errorResponse = ZoweCLIResponse(errorDict) {
                displayErrorPrompt(title: "Zowe Invocation Error", message: errorResponse.stderr.count > 0 ? errorResponse.stderr : errorResponse.stdout)
            } else {
                displayErrorPrompt(title: "ZSH Invocation Error", response: responseTuple.data)
            }
        }
        
        return nil
    }
    
    // MARK: - UI Handling
    
    private enum LoadingStatuses: String {
        case loading_JSON_data_from_API
        case checking_Zowe_connection_status
        case performing_Zowe_create_dataSet_command
        case performing_Zowe_upload_command
        case performing_Zowe_submit_job_command
        case performing_Zowe_view_job_spool_file
    }
    
    private func startLoadingStatus(with loadingStatus: LoadingStatuses) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingStatusLabel.stringValue = loadingStatus.rawValue.prefix(1).capitalized + loadingStatus.rawValue.suffix(from: String.Index(encodedOffset: 1)).replacingOccurrences(of: "_", with: " ") + "..."
            self?.loadingStatusLabel.isHidden = false
            self?.progressIndicator.startAnimation(nil)
        }
    }
    
    private func stopLoadingStatus() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingStatusLabel.isHidden = true
            self?.progressIndicator.stopAnimation(nil)
        }
    }
    
    private func updateOutputTextView(with outputString: String) {
        DispatchQueue.main.async { [weak self] in
            self?.outputTextView.string = outputString
            self?.outputTextView.textColor = NSColor.ZOSColors.green
        }
    }
    
    private func displayErrorPrompt(title: String, message: String? = nil, response: Data? = nil) {
        proceedFlag = false
        stopLoadingStatus()
        
        DispatchQueue.main.async {
            let userInfo: [String: Any]
            
            if let message = message {
                userInfo = [NSLocalizedDescriptionKey: title + "\n\n" + message]
            } else if let output = response, let outputString = String(data: output, encoding: .utf8) {
                userInfo = [NSLocalizedDescriptionKey: title + "\n\n" + outputString]
            } else {
                userInfo = [NSLocalizedDescriptionKey: title]
            }
            
            let error =  NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: userInfo)
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
}

