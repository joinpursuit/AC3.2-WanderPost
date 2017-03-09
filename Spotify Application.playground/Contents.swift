//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


//Reverse a string using no built in methods

func reverse(string: String) -> String {
    
    var returnString = ""
    
    for character in string.characters {
        returnString = String(character) + returnString
    }
    
    return returnString
}

reverse(string: "")

func findTheSecondLargestInt (in arr: [Int]) -> Int? {
    guard arr.count > 1 else { return nil }
    
    var smallest = Int.max
    var secondSmallest = Int.max
    
    
    
    return nil
}