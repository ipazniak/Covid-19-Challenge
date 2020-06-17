//
//  Z99998.CBL(COVID19).swift
//  Covid-19 Challenge
//

import Foundation

extension String {
    
    enum COBOL {
        static let source = """
      *A-1-B--+----2----+----3----+----4----+----5----+----6----+----7-|--+----8
      *------------------------------
       IDENTIFICATION DIVISION.
      *------------------------------
       PROGRAM-ID.     \(String.Constants.dataSetMemberCBL)
       AUTHOR.         \(NSFullUserName().uppercased()).
       INSTALLATION.   \(SystemService().modelIdentifier()) \(SystemService().systemVersion()).
       DATE-WRITTEN.   Thursday, Jun 11, 2020.
       DATE-COMPILED.  \(SystemService().dateInFormat(format: "EEEE, MMM dd, yyyy")).
      *------------------------------
       ENVIRONMENT DIVISION.
      *------------------------------
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. \(SystemService().modelIdentifier())_\(SystemService().systemVersion()) WITH DEBUGGING MODE.
       OBJECT-COMPUTER. \(SystemService().modelIdentifier())_\(SystemService().systemVersion()).
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT \(String.Constants.internalDataSet) ASSIGN TO \(String.Constants.externalDataSet).
           SELECT PRINT-LINE ASSIGN TO PRTLINE.
      *------------------------------
       DATA DIVISION.
      *------------------------------
       FILE SECTION.
      *
       FD  \(String.Constants.internalDataSet) RECORDING MODE F.
       01  COVID-FIELDS-RECORD  PIC X(80).
      *
       FD  PRINT-LINE RECORDING MODE F.
       01  PRINT-REC.
           05 COVID-DATE-O      PIC X(10).
           05 FILLER            PIC X(2) VALUE SPACES.
           05 USA-STATE-O       PIC X(2).
           05 FILLER            PIC X(6) VALUE SPACES.
           05 COVID-TOTAL-O     PIC X(7).
           05 FILLER            PIC X(3) VALUE SPACES.
           05 COVID-PSTV-O      PIC X(7).
           05 FILLER            PIC X(3) VALUE SPACES.
           05 COVID-NGTV-O      PIC X(7).
           05 FILLER            PIC X(3) VALUE SPACES.
           05 COVID-DEATH-O     PIC X(7).
           05 FILLER            PIC X(3) VALUE SPACES.
           05 COVID-RCVRD-O     PIC X(7).
           05 FILLER            PIC X(13) VALUE SPACES.

       WORKING-STORAGE SECTION.
      *
       01 HEADER-1.
           05 HDR-COVID-DATE    PIC X(4).
           05 FILLER            PIC X(8) VALUE SPACES.
           05 HDR-USA-STATE     PIC X(5).
           05 FILLER            PIC X(3) VALUE SPACES.
           05 HDR-COVID-TOTAL   PIC X(5).
           05 FILLER            PIC X(5) VALUE SPACES.
           05 HDR-COVID-PSTV    PIC X(8).
           05 FILLER            PIC X(2) VALUE SPACES.
           05 HDR-COVID-NGTV    PIC X(8).
           05 FILLER            PIC X(2) VALUE SPACES.
           05 HDR-COVID-DEATH   PIC X(5).
           05 FILLER            PIC X(5) VALUE SPACES.
           05 HDR-COVID-RCVRD   PIC X(9).
           05 FILLER            PIC X(11) VALUE SPACES.

       01  HEADER-2.
           05  FILLER           PIC X(10) VALUE '----------'.
           05  FILLER           PIC X(2) VALUE SPACES.
           05  FILLER           PIC X(5) VALUE '-----'.
           05  FILLER           PIC X(3) VALUE SPACES.
           05  FILLER           PIC X(7) VALUE '-------'.
           05  FILLER           PIC X(3) VALUE SPACES.
           05  FILLER           PIC X(8) VALUE '--------'.
           05  FILLER           PIC X(2) VALUE SPACES.
           05  FILLER           PIC X(8) VALUE '--------'.
           05  FILLER           PIC X(2) VALUE SPACES.
           05  FILLER           PIC X(7) VALUE '-------'.
           05  FILLER           PIC X(3) VALUE SPACES.
           05  FILLER           PIC X(9) VALUE '---------'.
           05  FILLER           PIC X(11) VALUE SPACES.

       01 WS-DATALINE.
           05 WS-COVID-DATE     PIC X(10).
           05 WS-USA-STATE      PIC X(2).
           05 WS-COVID-TOTAL    PIC X(7).
           05 WS-COVID-PSTV     PIC X(7).
           05 WS-COVID-NGTV     PIC X(7).
           05 WS-COVID-DEATH    PIC X(7).
           05 WS-COVID-RCVRD    PIC X(7).

       01 WS-LASTREC            PIC A.
      *
      *------------------------------
       PROCEDURE DIVISION.
      *------------------------------
       BEGIN.
           PERFORM OPEN-FILES
           PERFORM READ-HEADER
           PERFORM READ-NEXT-RECORD
           PERFORM CLOSE-STOP
           GOBACK
            .
       END-BEGIN.
      *
       OPEN-FILES.
      D    DISPLAY 'PERFORM OPEN-FILES'
           OPEN INPUT \(String.Constants.internalDataSet)
           OPEN OUTPUT PRINT-LINE
           .
       END-OPEN-FILES.
      *
       READ-HEADER.
      D    DISPLAY 'PERFORM READ-HEADER'
           PERFORM READ-RECORD
           PERFORM SPLIT-RECORD-INTO-HEADERS
           PERFORM WRITE-HEADER
           .
       END-READ-HEADER.
      *
       READ-NEXT-RECORD.
      D    DISPLAY 'PERFORM READ-NEXT-RECORD'
           PERFORM READ-RECORD
            PERFORM UNTIL WS-LASTREC = 'Y'
            PERFORM SPLIT-RECORD-INTO-FIELDS
            PERFORM WRITE-RECORD
            PERFORM READ-RECORD
           END-PERFORM
           .
       END-READ-NEXT-RECORD.
      *
       READ-RECORD.
      D    DISPLAY 'PERFORM READ-RECORD'
           READ \(String.Constants.internalDataSet)
           AT END
            MOVE 'Y' TO WS-LASTREC
      D     DISPLAY 'REACHED LAST RECORD'
           NOT AT END
      D     DISPLAY COVID-FIELDS-RECORD
           END-READ
           .
       END-READ-RECORD.
      *
       SPLIT-RECORD-INTO-HEADERS.
      D    DISPLAY 'PERFORM SPLIT-RECORD-INTO-HEADERS'
           UNSTRING COVID-FIELDS-RECORD DELIMITED BY ','
            INTO HDR-COVID-DATE, HDR-USA-STATE, HDR-COVID-TOTAL,
            HDR-COVID-PSTV, HDR-COVID-NGTV, HDR-COVID-DEATH,
            HDR-COVID-RCVRD

      D    DISPLAY 'HDR-COVID-DATE = '
           FUNCTION UPPER-CASE(HDR-COVID-DATE)
      D    DISPLAY 'HDR-USA-STATE = '
           FUNCTION UPPER-CASE(HDR-USA-STATE)
      D    DISPLAY 'HDR-COVID-TOTAL = '
           FUNCTION UPPER-CASE(HDR-COVID-TOTAL)
      D    DISPLAY 'HDR-COVID-PSTV = '
           FUNCTION UPPER-CASE(HDR-COVID-PSTV)
      D    DISPLAY 'HDR-COVID-NGTV = '
           FUNCTION UPPER-CASE(HDR-COVID-NGTV)
      D    DISPLAY 'HDR-COVID-DEATH = '
           FUNCTION UPPER-CASE(HDR-COVID-DEATH)
      D    DISPLAY 'HDR-COVID-RCVRD = '
           FUNCTION UPPER-CASE(HDR-COVID-RCVRD)
           .
       END-SPLIT-RECORD-INTO-HEADERS.
      *
       SPLIT-RECORD-INTO-FIELDS.
      D    DISPLAY 'PERFORM SPLIT-RECORD-INTO-FIELDS'
           UNSTRING COVID-FIELDS-RECORD DELIMITED BY ','
            INTO WS-COVID-DATE, WS-USA-STATE, WS-COVID-TOTAL,
            WS-COVID-PSTV, WS-COVID-NGTV, WS-COVID-DEATH, WS-COVID-RCVRD

      D    DISPLAY 'COVID-DATE = ' WS-COVID-DATE
      D    DISPLAY 'USA-STATE = ' WS-USA-STATE
      D    DISPLAY 'COVID-TOTAL = ' WS-COVID-TOTAL
      D    DISPLAY 'COVID-PSTV = ' WS-COVID-PSTV
      D    DISPLAY 'COVID-NGTV = ' WS-COVID-NGTV
      D    DISPLAY 'COVID-DEATH = ' WS-COVID-DEATH
      D    DISPLAY 'COVID-RCVRD = ' WS-COVID-RCVRD
           .
       END-SPLIT-RECORD-INTO-FIELDS.
      *
       WRITE-HEADER.
           MOVE FUNCTION UPPER-CASE(HDR-COVID-DATE)  TO HDR-COVID-DATE
           MOVE FUNCTION UPPER-CASE(HDR-USA-STATE)   TO HDR-USA-STATE
           MOVE FUNCTION UPPER-CASE(HDR-COVID-TOTAL) TO HDR-COVID-TOTAL
           MOVE FUNCTION UPPER-CASE(HDR-COVID-PSTV)  TO HDR-COVID-PSTV
           MOVE FUNCTION UPPER-CASE(HDR-COVID-NGTV)  TO HDR-COVID-NGTV
           MOVE FUNCTION UPPER-CASE(HDR-COVID-DEATH) TO HDR-COVID-DEATH
           MOVE FUNCTION UPPER-CASE(HDR-COVID-RCVRD) TO HDR-COVID-RCVRD
           WRITE PRINT-REC FROM HEADER-1
           WRITE PRINT-REC FROM HEADER-2
           MOVE SPACES TO PRINT-REC
           .
       END-WRITE-HEADER.
      *
       WRITE-RECORD.
           MOVE WS-COVID-DATE(1:4) TO COVID-DATE-O(1:4)
           MOVE '-' TO COVID-DATE-O(5:1)
           MOVE WS-COVID-DATE(5:2) TO COVID-DATE-O(6:2)
           MOVE '-' TO COVID-DATE-O(8:1)
           MOVE WS-COVID-DATE(7:2) TO COVID-DATE-O(9:2)
           MOVE WS-USA-STATE   TO USA-STATE-O
           MOVE WS-COVID-TOTAL TO COVID-TOTAL-O
           MOVE WS-COVID-PSTV  TO COVID-PSTV-O
           MOVE WS-COVID-NGTV  TO COVID-NGTV-O
           MOVE WS-COVID-DEATH TO COVID-DEATH-O
           MOVE WS-COVID-RCVRD TO COVID-RCVRD-O
           WRITE PRINT-REC
           .
       END-WRITE-RECORD.
      *
       CLOSE-STOP.
      D    DISPLAY 'PERFORM CLOSE-STOP'
           CLOSE \(String.Constants.internalDataSet)
           CLOSE PRINT-LINE
           .
       END-CLOSE-STOP.
      *
"""
    }
}
