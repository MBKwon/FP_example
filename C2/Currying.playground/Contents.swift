import Foundation


// Caurry
// reference : https://github.com/thoughtbot/Curry
typealias EscapingClosure<A, B> = (A) -> B
func uncurry<A, B, C>(_ f: @escaping EscapingClosure<A, (B) -> C>) -> (A, B) -> C {
    return { (a: A, b: B) -> C in
        return f(a)(b)
    }
}

public func curry<A, B>(_ function: @escaping (A) -> B) -> (A) -> B {
    return { (a: A) -> B in function(a) }
}

public func curry<A, B, C>(_ function: @escaping ((A, B)) -> C) -> (A) -> (B) -> C {
    return { (a: A) -> (B) -> C in { (b: B) -> C in function((a, b)) } }
}


//Partial Application
func partialApplication(val: Int, _ function: @escaping (Int, Int) -> Int) -> (Int) -> Int {
    return { (b: Int) -> Int in
        return function(val, b)
    }
}



// Test
func multiply(a: Int, b: Int) -> Int {
    return a * b
}

let multiply3 = partialApplication(val: 3, multiply(a:b:))
print("partila application \(multiply3) \(type(of: multiply3))")
print(multiply3(10))


let curryMultiply = curry(multiply(a:b:))
let multiply4 = curryMultiply(4)
print("curry \(multiply4) \(type(of: multiply4))")
print(curryMultiply(4)(10))
print(multiply4(10))
