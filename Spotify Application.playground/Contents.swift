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

func findTheSecondSmallestElement<T: Comparable> (in arr: [T]) -> T? {
    guard arr.count > 1 else { return nil }
    
    var smallest = arr[0]
    var secondSmallest: T? = nil
    
    for int in arr {
        if int < smallest {
            secondSmallest = smallest
            smallest = int
        } else if secondSmallest == nil || int < secondSmallest! {
            secondSmallest = int
        }
    }
    
    return secondSmallest
}
findTheSecondSmallestElement(in: [42, 8, 3])

