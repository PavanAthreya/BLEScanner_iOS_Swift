//
//  String+Hexadecimal.swift
//  Bluetooth Scanner
//
//  Created by Pavan Athreya on 01/03/2019.
//  Copyright (c) 2019 Pavan Athreya. All rights reserved.
//

import Foundation

extension String {
    
    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a NSData object. Note, if the string has any spaces, those are removed. Also if the string started with a '<' or ended with a '>', those are removed, too. This does no validation of the string to ensure it's a valid hexadecimal string
    ///
    /// The use of `strtoul` inspired by Martin R at http://stackoverflow.com/a/26284562/1271826
    ///
    /// :returns: NSData represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range.
    
    var hexadecimal: Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a String object from taht. Note, if the string has any spaces, those are removed. Also if the string started with a '<' or ended with a '>', those are removed, too.
    ///
    /// :param: encoding The NSStringCoding that indicates how the binary data represented by the hex string should be converted to a String.
    ///
    /// :returns: String represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range or if a string cannot be created using the provided encoding
    
    func stringFromHexadecimalStringUsingEncoding(encoding: String.Encoding) -> String? {
        if let data = self.hexadecimal {
            return String(data: data as Data, encoding: encoding)
        }
        return nil
    }
    
    /// Create hexadecimal string representation of String object.
    ///
    /// :param: encoding The NSStringCoding that indicates how the string should be converted to NSData before performing the hexadecimal conversion.
    ///
    /// :returns: String representation of this String object.
    
    func hexadecimalStringUsingEncoding(encoding: String.Encoding) -> String? {
        let data1 = data(using: encoding)
        return data1?.hexadecimalString()
    }
}
