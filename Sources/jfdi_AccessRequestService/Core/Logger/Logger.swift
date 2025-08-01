//
//  Logger.swift
//  
//
//  Created by Patrick-Benjamin Bök on 18.08.23.
//

import Foundation

//Central logger for the applicaation
final class Logger: TextOutputStream, Sendable {
    //Apply the singleton pattern
    private static let log: Logger = Logger()
    private let queue = DispatchQueue(label: "com.jufudoo.aloliana.base")
    
    
    
    //Function to retrieve the current filesize of the log file
    func getFileSize() -> UInt64{
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("jfdi.log")
        if let attr = try? fm.attributesOfItem(atPath: log.absoluteString){
            return attr[FileAttributeKey.size] as! UInt64
        }
        return 0
    }
    
    //Function to write some string to the log file
    func write(_ string: String) {
        //If the file is bigger than 5 MB, it will be deleted
        queue.sync {
            if(getFileSize() > 5000000){
                deleteLogfile()
            }
            let fm = FileManager.default
            let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("jfdi.log")
            if let handle = try? FileHandle(forWritingTo: log) {
                //Data will be added to the end of the file
                handle.seekToEndOfFile()
                handle.write(string.data(using: .utf8)!)
                handle.closeFile()
            }
            else {
                try? string.data(using: .utf8)?.write(to: log)
            }
        }
    }
    
    //Function to delete the mia.log file
    func deleteLogfile(){
        queue.sync {
            let fm = FileManager.default
            let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("jfdi.log")
            do{
                try fm.removeItem(at: log)
            }
            catch{}
        }
    }
    
    private init() {
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("jfdi.log")
        do{
            try fm.removeItem(at: log)
        }
        catch{
            /* not handled as logging is not a major thing currently */
        }
    }
}
