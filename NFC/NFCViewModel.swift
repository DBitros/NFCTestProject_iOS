//
//  NFCViewModel.swift
//  NFC
//
//  Created by Dionysios Bitros on 21/07/23.
//

import Foundation
import CoreNFC

class NFCViewModel: NSObject, ObservableObject {
    
    var session: NFCNDEFReaderSession? = nil
    
    func beginScanning() {
        
        guard NFCNDEFReaderSession.readingAvailable else {
            debugPrint("NFC Reader :: Scanning not enabled")
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }
    
}

extension NFCViewModel: NFCNDEFReaderSessionDelegate {
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        debugPrint("NFC Reader :: \(session.description)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                debugPrint("NFC Reader :: Session invalidated")
            }
        }
        
        // To read new tags, a new session instance is required.
        self.session = nil
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "NFC Reader :: Couldn't read tag")
            return
        }
      
        session.connect(to: tag) { (error: Error?) in
            if error != nil {
              session.invalidate(errorMessage: "NFC Reader :: Connection error. Please try again.")
              return
            }

            tag.queryNDEFStatus { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
              if error != nil {
                  session.invalidate(errorMessage: "NFC Reader :: Failed to determine NDEF status. Please try again.")
                  return
              }
              
              if status == .readOnly || status == .readWrite {
                  tag.readNDEF { (ndefMessage: NFCNDEFMessage?, error: Error?) in
                      if error != nil {
                          session.invalidate(errorMessage: "NFC Reader :: Read error. Please try again.")
                          return
                      }
                      
                      if let ndefMessage = ndefMessage {
                          // Process the NDEF message
                          debugPrint(ndefMessage.records)
                      }
                      
                      session.invalidate()
                  }
              } else {
                  session.invalidate(errorMessage: "NFC Reader :: Tag is not NDEF compliant.")
              }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        // Print messages
        for message in messages {
            for record in message.records {
                debugPrint("NFC Reader :: NDEF Payload: \(record.payload)")
            }
        }
    }
}
