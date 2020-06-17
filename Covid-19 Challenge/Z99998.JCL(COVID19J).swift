//
//  Z99998.JCL(COVID19J).swift
//  Covid-19 Challenge
//

import Foundation

extension String {
    
    enum JCL {
        static let source = """
//COVID19J JOB 1,NOTIFY=&SYSUID
//***************************************************/
//COBRUN  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(COVID19),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(COVID19),DISP=SHR
//***************************************************/
// IF RC = 0 THEN
//***************************************************/
//RUN     EXEC PGM=COVID19
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//\(String.Constants.externalDataSet)  DD DSN=&SYSUID..\(String.Constants.dataSetExtensionPS),DISP=SHR
//PRTLINE   DD SYSOUT=*,OUTLIM=15000
//SYSOUT    DD SYSOUT=*,OUTLIM=15000
//CEEDUMP   DD DUMMY
//SYSUDUMP  DD DUMMY
//***************************************************/
// ELSE
// ENDIF
"""
    }
}
