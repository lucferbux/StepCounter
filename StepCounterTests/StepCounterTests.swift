//
//  StepCounterTests.swift
//  StepCounterTests
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import XCTest
@testable import StepCounter

class StepCounterTests: XCTestCase {
    
    lazy var walks: [Walk] = {
        let path = NSBundle.mainBundle().pathForResource("Walks", ofType: "plist")
        let arrayOfDicts = NSArray(contentsOfFile: path!)!
        var array = [Walk]()
        for i in 0..<arrayOfDicts.count {
            let walk = Walk.convertDictToWalk(arrayOfDicts[i] as! [String : AnyObject])
            array.append(walk)
        }
        return array as Array
    }()
    
    let tableViewController = SessionsTableViewController()
    
    
 
    
    override func setUp() {
        super.setUp()
        tableViewController.loadSavedHistoryData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWalkArrayHasItems() {
        XCTAssertGreaterThan(walks.count, 0, "The Walks don't upload")
        
    }
    
    func testHistoryLoad() {
        let storedHistoryPlist = tableViewController.storedHistoryPlist
        XCTAssertGreaterThan(storedHistoryPlist.count, 0, "The History Porperty has documents")
    }
    
    
    
}
