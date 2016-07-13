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
    
    /** Returns the actual date*/
    var now: NSDate {
        return NSDate()
    }
    
    /** Returns the date of today's start date*/
    var startOfToday: NSDate {
        return cal.startOfDayForDate(now)
    }

    
    /** Returns the date of tomorrow's satart date */
    func startOfNextDay(date: NSDate) -> NSDate {
        // allow for daylight-saving and crossing a few time zones
        let nextDay = date.dateByAddingTimeInterval(secondsPerHour * 28)
        return cal.startOfDayForDate(nextDay)
    }
    
    /** Check wether if one date is the same of the other*/
    func isDate(date1: NSDate, afterDate date2: NSDate) -> Bool {
        return date1.timeIntervalSinceDate(date2) > 0
    }
    
}