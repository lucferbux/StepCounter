//
//  Calendar.swift
//  StepCounter
//
//  Created by lucas fernández on 10/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import Foundation

struct Calendar {
    let secondsPerHour: TimeInterval = 3600
    let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    
    /** Returns the actual date*/
    var now: NSDate {
        return NSDate()
    }
    
    /** Returns the date of today's start date*/
    var startOfToday: NSDate {
        return cal.startOfDay(for: now as Date) as (Date) as NSDate
    }

    
    /** Returns the date of tomorrow's satart date */
    func startOfNextDay(date: NSDate) -> NSDate {
        // allow for daylight-saving and crossing a few time zones
        let nextDay = date.addingTimeInterval(secondsPerHour * 28)
        return cal.startOfDay(for: nextDay as Date) as (Date) as NSDate
    }
    
    /** Check wether if one date is the same of the other*/
    func isDate(date1: NSDate, afterDate date2: NSDate) -> Bool {
        return date1.timeIntervalSince(date2 as Date) > 0
    }
    
}
