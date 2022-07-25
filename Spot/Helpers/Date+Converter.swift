//
//  Date+Converter.swift
//  Spot
//
//  Created by Jin Kim on 11/19/21.
//

import Foundation

// Currently not being used
class DateConverter {
    
    func convert(_ dt: String) -> Date? {
        
        let dd: String = dt[0 ..< 10] + " " + dt[11 ..< 16]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let res = formatter.date(from: dd)

        return res
    }
}
