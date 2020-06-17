//
//  ApiManager.swift
//  Covid-19 Challenge
//

import Foundation

class ApiManager {
    
    enum HttpMethods: String {
        case get
        case post
        case put
        case delete
    }
    
    func load(url: String, httpMethod: HttpMethods, onCompletion: @escaping (_ success: Bool, _ data: Data?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let validUrl = URL(string: url) else {
            onCompletion(false, nil)
            return
        }
        
        var request = URLRequest(url: validUrl)
        request.httpMethod = httpMethod.rawValue.uppercased()
        
        print("API request has started")
        print("----------------------")
        
        let task = session.dataTask(with: request, completionHandler: { contentsData, response, error in
            print("API response has been received")
            
            if let errorUnwrapped = error {
                // Failure
                print("Failure: \(errorUnwrapped.localizedDescription)")
                print("----------------------")
                onCompletion(false, nil)
            } else {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    // Success, conditional though - check status code returned
                    print("Success: \(statusCode)")
                    guard let contentsDataUnwrapped = contentsData else {
                        print ("URL data is null")
                        return
                    }
                    guard let contentsString = String(data: contentsDataUnwrapped, encoding: .utf8) else {
                        print("URL data can NOT be converted to string format using UTF8 encoding")
                        return
                    }
                    print("URL data converted to string: \(contentsString)")
                    print("----------------------")
                    
                    onCompletion((200...299).contains(statusCode), contentsData)
                }
            }
        })
        
        task.resume()
    }
}
