//
//  DataConverter.swift
//  Covid-19 Challenge
//

import Foundation

extension Data {
    
    func jsonDataToDictionary(onFailure: (_ error: String?) -> Void) -> [String: Any]? {
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] {
                return dictionary
            }
        } catch {
            onFailure(error.localizedDescription)
        }
        
        return nil
    }
    
    func jsonDataToArray(onFailure: (_ error: String?) -> Void) -> [[String: Any]]? {
        do {
            if let json = try JSONSerialization.jsonObject(with: self, options: []) as? [[String: Any]] {
                return json
            }
        } catch {
            onFailure(error.localizedDescription)
        }
        
        return nil
    }
    
    func jsonDataToCsv(onFailure: (_ error: String?) -> Void) -> String {
        let jsonArray = self.jsonDataToArray() { error in onFailure(error) }
        let jsonKeys: [String] = ["date", "state", "total", "positive", "negative", "death", "recovered"]
        var jsonValues: [String] = []
        var jsonStrings: [String] = [jsonKeys.joined(separator: ",")]
        jsonArray?.forEach { json in
            jsonKeys.forEach { key in
                if let value = json[key] {
                    jsonValues.append("\(value)")
                }
            }
            jsonStrings.append(jsonValues.joined(separator: ","))
            jsonValues.removeAll()
        }
        return jsonStrings.joined(separator: "\n")
    }
}
