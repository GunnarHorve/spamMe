//
//  helpers.swift
//  spamMe
//
//  Created by Gunnar Horve on 7/3/16.
//  Copyright © 2016 Latent Non-Ability. All rights reserved.
//

import Foundation

func formatTime(time: Double) -> String {
    let currentTime: Double = NSDate().timeIntervalSince1970
    let date = NSDate(timeIntervalSinceReferenceDate: time)
    
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Minute, .Hour, .Day, .Weekday, .Month , .Year], fromDate: date)
    let days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    if(currentTime - time < 86400) {           // message was sent today
        if(comp.minute < 10) {
            return "\(comp.hour):0\(comp.minute)"
        } else {
            return "\(comp.hour):\(comp.minute)"
        }
    } else if(currentTime - time < 604800) {   // message was sent this week
        return days[comp.weekday]
    } else {                                   // message was sent "some time"
        return "\(comp.day)/\(comp.month)/\(comp.year)"
    }
}