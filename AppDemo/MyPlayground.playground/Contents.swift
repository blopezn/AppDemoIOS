//: Playground - noun: a place where people can play

import UIKit
import AFNetworking

var str = "Hello, playground"

extension String {
    func reversa() -> String {
        print("Reversando")
        return "Hola"
    }
    
    func IntValue() -> Int {
        return Int(self)!
    }
    
    func Validar() -> Bool {
        return self.characters.first == "A"
    }
}

//"0".IntValue()

//"Alan".Validar()


