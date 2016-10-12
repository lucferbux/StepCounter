//
//  SessionDataXML.swift
//  StepCounter
//
//  Created by lucas fernández on 10/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import Foundation


struct HistoryData {
    //Enumeration for errors in the file manager
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    //Here the path of the property list is located
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    //The destination path is the folder placed in a read/write memory location in which the property list will be stored and retrieved
    var destPath:String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {

        self.name = name
        
        let fileManager = FileManager.default
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        //Check if the file exist
        if !fileManager.fileExists(atPath: destination) {

            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print(error)
                return nil
            }
        }
    }
    
    //Get the static values from the fil
    func getValuesInPlistFile() -> NSArray?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSArray(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    //Get the entire file as nsdata to allow the app from sendig to another device
    func getPlist() -> NSData?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSData(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    //Get the mutable array to work with
    func getMutablePlistFile() -> NSMutableArray?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableArray(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    //Add values to the property list
    func addValuesToPlistFile(history:NSMutableArray) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !history.write(toFile: destPath!, atomically: false) {
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
}
