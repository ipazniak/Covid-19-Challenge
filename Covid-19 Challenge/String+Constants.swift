//
//  String+Constants.swift
//  Covid-19 Challenge
//

import Foundation

extension String {
    
    enum Constants {
        static let covidApi = "https://covidtracking.com/api/v1/states/current.json"
        static let zId = "Z81056"
        static let dataSetExtensionCBL = "CBL"
        static let dataSetExtensionJCL = "JCL"
        static let dataSetExtensionPS = "PS"
        static let dataSetCBL = zId + "." + dataSetExtensionCBL
        static let dataSetJCL = zId + "." + dataSetExtensionJCL
        static let dataSetPS = zId + "." + dataSetExtensionPS
        static let dataSetMemberCBL = "COVID19"
        static let dataSetMemberJCL = dataSetMemberCBL + "J"
        static let internalDataSet = "COVID-REC"
        static let externalDataSet = "COVIDREC"
        static let pathToZowe = "/usr/local/bin/"
        static let pathToZsh = "/bin/zsh"
    }
}
