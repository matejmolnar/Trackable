//
//  Key.swift
//  Trackable
//
//  Created by Vojta Stavik (vojtastavik.com) on 06/12/15.
//  Copyright © 2015 Vojta Stavik. All rights reserved.
//

import Foundation

public protocol Key: CustomStringConvertible { }

/**
    Specify a prefix which sould be removed from all keys. Usually you use this to remove project and/or module name.
*/
public var keyPrefixToRemove: String? = nil

/**
    
*/
public var smartKeyComposingEnabled = true

public extension Key where Self : RawRepresentable {
    /**
        String representation of Event object.
     */
    var description: String {
        var rawDescription = String(reflecting: type(of: self)) + "." + "\(self.rawValue)"
        if let
            prefixToRemove = keyPrefixToRemove,
            let range = rawDescription.range(of: prefixToRemove) {
            rawDescription.removeSubrange(range)
        }
        
        return rawDescription
    }
}

public extension Key {
    /**
        Removes common prefix for both keys
     */
    func composeKeyWith(_ key: Key) -> String {
        guard smartKeyComposingEnabled else {
            return description + "." + key.description
        }
        
        var finalKey = description
        let myKeySubstrings = finalKey.split(separator: ".", omittingEmptySubsequences: true)
        let otherKeySubstrings = key.description.split(separator: ".", omittingEmptySubsequences: true)
        
        for i in 0..<otherKeySubstrings.endIndex {
            guard
                i < myKeySubstrings.endIndex,
                otherKeySubstrings[i] == myKeySubstrings[i]
            else {
                let subArray = otherKeySubstrings[i..<otherKeySubstrings.endIndex]
                
                finalKey = subArray.reduce(finalKey, { result, substring in
                    result + "." + String(substring)
                })
                break
            }
            
            continue
        }
        
        let keyWithoutRepeatingParts = removeRepeatingParts(finalKey)
        return keyWithoutRepeatingParts
    }
    
    /**
        Removes repeating parts of the key
     */
    func removeRepeatingParts(_ keyDescription: String) -> String {
        let separator = "."
        let elements = keyDescription.components(separatedBy: separator)
        
        let first = elements.first! // ->> should never be nil
        return elements.reduce(first, { (result, element) -> String in
            if result.components(separatedBy: separator).last == element {
                return result
            } else {
                return result + "." + element
            }
        })
    }
}

extension String : Key {
    public var description: String {
        return self
    }
}
