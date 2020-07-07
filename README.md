# Covid-19-Challenge

> COBOL-Swift via Zowe CLI interaction sample

---

## Description

A native macOS Swift-written application, performing the following steps:

- Retrieving <a href="https://covidtracking.com/api/v1/states/current.json" target="_blank">data</a> in JSON format from <a href="https://covidtracking.com/data/api" target="_blank">covidtracking.com</a> API and converting it to CSV format
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

Make sure you change the default `zId` (which is `Z99998`) to your own Mainframe ID. This and other user-specific information can be easily edited in `String+Constants.swift` file, for example:
```swift
static let zId = "Z99998"
static let dataSetMemberCBL = "COVID19"
static let internalDataSet = "COVID-REC"
static let externalDataSet = "COVIDREC"
```

## Screenshots
![Loading JSON data from API...](/../screenshots/Scrshots/COVID-19%20Challenge01.jpg?raw=true "Loading JSON data from API...")
![Checking Zowe connection status...](/../screenshots/Scrshots/COVID-19%20Challenge02.jpg?raw=true "Checking Zowe connection status...")
![Performing Zowe create dataSet command...](/../screenshots/Scrshots/COVID-19%20Challenge03.jpg?raw=true "Performing Zowe create dataSet command...")
![Performing Zowe upload command...](/../screenshots/Scrshots/COVID-19%20Challenge04.jpg?raw=true "Performing Zowe upload command...")
![Performing Zowe submit job command...](/../screenshots/Scrshots/COVID-19%20Challenge05.jpg?raw=true "Performing Zowe submit job command...")
![Performing Zowe view job spool file...](/../screenshots/Scrshots/COVID-19%20Challenge06.jpg?raw=true "Performing Zowe view job spool file...")
![Displaying COBOL program execution output](/../screenshots/Scrshots/COVID-19%20Challenge07.jpg?raw=true "Displaying COBOL program execution output")
