//
//  ZoweCLIResponse.swift
//  Covid-19 Challenge
//

import Foundation

class ZoweCLIResponse {
    
    let success: Bool
    let exitCode: Int
    let message: String
    let stdout: String
    let stderr: String
    let data: Any
    
    init?(_ optionalDict: [String: Any]?) {
        // Parse JSON data
        if let dict = optionalDict, let success = dict["success"] as? Bool, let exitCode = dict["exitCode"] as? Int, let message = dict["message"] as? String, let stdout = dict["stdout"] as? String, let stderr = dict["stderr"] as? String, let data = dict["data"] {
            self.success = success
            self.exitCode = exitCode
            self.message = message
            self.stdout = stdout
            self.stderr = stderr
            self.data = data
        } else {
            return nil
        }
    }
    
    func isValid(_ zoweGroup: ZoweCLI.Groups, _ zoweAction: ZoweCLI.Groups.Jobs? = nil) -> Bool {
        let isValid: Bool
        
        switch zoweGroup {
        case .zosmf:
            isValid = (success == true && exitCode == 0)
        case .files:
            let responseData = data as? [String: Any]
            let responseDataSuccess = responseData?["success"] as? Bool
            isValid = (success == true && exitCode == 0 && responseDataSuccess != nil && responseDataSuccess == true)
        case .jobs where zoweAction == .del,
             .jobs where zoweAction == .sub:
            let responseData = data as? [String: Any]
            let retcode = responseData?["retcode"] as? String
            isValid = (success == true && exitCode == 0 && retcode != nil && retcode == "CC 0000")
        case .jobs where zoweAction == .vw:
            let responseData = data as? String
            isValid = (success == true && exitCode == 0 && responseData != nil)
        default:
            return false
        }
        
        return isValid
    }
}
