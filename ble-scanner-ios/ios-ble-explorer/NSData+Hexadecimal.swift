//
//  NSData+Hexadecimal.swift
//  Bluetooth Scanner
//
//  Created by Pavan Athreya on 01/03/2019.
//  Copyright (c) 2019 Pavan Athreya. All rights reserved.
//

import Foundation

extension Data {
    
    //hexadecimal string representation of Data object.
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: count * 2)
        var byte: UInt8 = 0
        
        for i in 0 ..< count {
            copyBytes(to: &byte, count: i)
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
    
    //hexadecimal description string representation of Data object.
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

