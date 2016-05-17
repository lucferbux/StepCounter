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
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    //Here the path of the property list is located
    var sourcePath:String? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else { return .None }
        return path
    }
    //The destination path is the folder placed in a read/write memory location in which the property list will be stored and retrieved
    var destPath:String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {

        self.name = name
        
        let fileManager = NSFileManager.defaultManager()
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExistsAtPath(source) else { return nil }
        //Check if the file exist
        if !fileManager.fileExistsAtPath(destination) {

            do {
                try fileManager.copyItemAtPath(source, toPath: destination)
            } catch let error as NSError {
                print(error)
                return nil
            }
        }
    }
    
    //Get the static values from the fil
    func getValuesInPlistFile() -> NSArray?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSArray(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    //Get the entire file as nsdata to allow the app from sendig to another device
    func getPlist() -> NSData?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSData(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    //Get the mutable array to work with
    func getMutablePlistFile() -> NSMutableArray?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableArray(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    //Add values to the property list
    func addValuesToPlistFile(history:NSMutableArray) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            if !history.writeToFile(destPath!, atomically: false) {
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
}