//
//  Z99998.JCL(COVID19J).swift
//  Covid-19 Challenge
//

import Foundation

extension String {
    
    enum JCL {
        static let source = """
//\(String.Constants.dataSetMemberJCL) JOB 1,NOTIFY=&SYSUID
//***************************************************/
//COBRUN  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(\(String.Constants.dataSetMemberCBL)),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(\(String.Constants.dataSetMemberCBL)),DISP=SHR
//***************************************************/
// IF RC = 0 THEN
//***************************************************/
//RUN     EXEC PGM=\(String.Constants.dataSetMemberCBL)
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//\(String.Constants.externalDataSet)  DD DSN=&SYSUID..\(String.Constants.dataSetExtensionPS),DISP=SHR
//PRTLINE   DD SYSOUT=*,OUTLIM=1000
//SYSOUT    DD SYSOUT=*,OUTLIM=5000
//CEEDUMP   DD DUMMY
//SYSUDUMP  DD DUMMY
//***************************************************/
// ELSE
// ENDIF
"""
    }
}
