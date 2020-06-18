# Covid-19-Challenge

> COBOL-Swift via Zowe CLI interaction sample

---

## Description

A native macOS Swift-written application, performing the following steps:

- Retrieving JSON data from <a href="https://covidtracking.com/api/v1/states/current.json" target="_blank">API</a> and converting it to CSV format
- Checking user connection status to z/OSMF
- Creating a sequential `Z99998.PS` data set and uploading CSV data to it
- Uploading COBOL and JCL source code to the existing data sets as `Z99998.CBL(COVID19)` and `Z99998.JCL(COVID19J)`
- Submitting a new job and viewing its spool file output, showing the results in the main application window
- Deleting the job submitted and `Z99998.PS` data set, created before

## Installation and Setup

The following environment and software is necessary to build and run:

- <a href="https://apps.apple.com/us/app/macos-catalina/id1466841314" target="_blank">macOS 10.14.6</a> or newer
- <a href="https://apps.apple.com/us/app/xcode/id497799835" target="_blank">Xcode 10.3</a> or higher
- Personal Mainframe ID for IBM's COBOL Programming with VSCode Labs system (i e `Z99998`, can be obtained from <a href="https://www-01.ibm.com/events/wwe/ast/mtm/cobolvscode.nsf/enrollall?openform" target="_blank">here</a>)
- <a href="https://github.com/zowe/zowe-cli" target="_blank">Zowe CLI</a> installed
- Zowe CLI `zosmf` <a href="https://github.com/zowe/zowe-cli#configure-zowe-cli" target="_blank">profile</a> created and configured

## Usage

`UserID` and other specific information can be easily edited for the corresponding values in `String+Constants.swift` file, for example:
```swift
static let zId = "Z99998"
static let dataSetMemberCBL = "COVID19"
static let internalDataSet = "COVID-REC"
static let externalDataSet = "COVIDREC"
```
