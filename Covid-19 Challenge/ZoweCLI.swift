//
//  ZoweCLI.swift
//  Covid-19 Challenge
//

import Foundation

enum ZoweCLI {
    
    enum Groups: String {
        case files          // zos-files            | Manage z/OS data sets
        case jobs           // zos-jobs             | Manage z/OS jobs
        case zosmf          // zosmf                | Interact with z/OSMF
        
        enum Zosmf: String {
            case check      // check                | Confirm that z/OSMF is running on a specified system
            
            enum Check: String {
                case status // status               | Confirm that z/OSMF is running on a system specified in your profile
            }
        }
        
        enum Files: String {
            case cre        // create               | Create data sets
            case del        // delete               | Delete a data set or Unix System Services file
            case ls         // list                 | List data sets and data set members (optionally, lists their details and attributes)
            case ul         // upload               | Upload the contents of a file to z/OS data sets
            
            enum Create: String {
                case bin    // data-set-binary      | Create executable data sets
                case dsc    // data-set-c           | Create data sets for C code programming
                case classic// data-set-classic     | Create classic data sets (JCL, HLASM, CBL, etc...)
                case pds    // data-set-partitioned | Create partitioned data sets (PDS)
                case ps     // data-set-sequential  | Create physical sequential data sets (PS)
                case vsam   // data-set-vsam        | Create a VSAM cluster
                case dir    // uss-directory        | Create a UNIX directory
                case file   // uss-file             | Create a UNIX file
                case zfs    // zos-file-system      | Create a z/OS file system
            }
            
            enum Delete: String {
                case ds     // data-set             | Delete a data set or data set member permanently
                case vsam   // data-set-vsam        | Delete a VSAM cluster permanently
                case uss    // uss-file             | Delete a Unix Systems Services (USS) File or directory permanently
                case zfs    // zos-file-system      | Delete a z/OS file system permanently
            }
            
            enum List: String {
                case am     // all-members          | List all members of a pds
                case ds     // data-set             | List data sets
                case fs     // file-system          | Listing mounted z/OS filesystems
                case uss    // uss-files            | List USS files
            }
            
            enum Upload: String {
                case dtp    // dir-to-pds           | Upload files from a local directory to a partitioned data set (PDS)
                case dtu    // dir-to-uss           | Upload a local directory to a USS directory
                case ftds   // file-to-data-set     | Upload the contents of a file to a z/OS data set
                case ftu    // file-to-uss          | Upload content to a USS file from local file
                case stds   // stdin-to-data-set    | Upload the content of a stdin to a z/OS data set
            }
        }
        
        enum Jobs: String {
            case can        // cancel               | Cancel a single job by job ID (this cancels the job if it is running or on input)
            case del        // delete               | Delete a single job by job ID in OUTPUT status (this cancels the job if it is running)
            case sub        // submit               | Submit jobs (JCL) contained in data sets
            case vw         // view                 | View details of z/OS jobs on spool/JES queues
            
            enum Cancel: String {
                case job    // job                  | Cancel a single job by job ID
            }
            
            enum Delete: String {
                case job    // job                  | Delete a single job by job ID
            }
            
            enum Submit: String {
                case ds     // data-set             | Submit a job contained in a data set
                case lf     // local-file           | Submit a job contained in a local file
                case stdin  // in                   | Submit a job read from standard in
            }
            
            enum View: String {
                case jsbj   // job-status-by-jobid  | View status details of a z/OS job
                case sfbi   // spool-file-by-id     | View a spool file from a z/OS job
            }
        }
    }
    
    enum Options: String {
        case binary         // --binary
        case for_sure       // --for-sure
        case rfj            // --response-format-json
        case vasc           // --view-all-spool-content
        case wfa            // --wait-for-active
        case wfo            // --wait-for-output
    }
}
