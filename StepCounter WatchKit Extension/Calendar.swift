//
//  Calendar.swift
//  StepCounter
//
//  Created by lucas fernández on 10/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import Foundation

struct Calendar {
    let secondsPerHour: NSTimeInterval = 3600
    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    var now: NSDate {
        return NSDate()
    }
    
    var startOfToday: NSDate {
        return cal.startOfDayForDate(now)
    }

    
    func startOfNextDay(date: NSDate) -> NSDate {
        // allow for daylight-saving and crossing a few time zones
        let nextDay = date.dateByAddingTimeInterval(secondsPerHour * 28)
        return cal.startOfDayForDate(nextDay)
    }
    
    func isDate(date1: NSDate, afterDate date2: NSDate) -> Bool {
        return date1.timeIntervalSinceDate(date2) > 0
    }
    
}