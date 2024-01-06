import Foundation

func fib_1(_ i: Int) -> Int {
    var value = i
    if i > 1 {
        value = fib_1(i-2) + fib_1(i-1)
    }
    return value
}

func fib_2(_ i: Int) -> () -> Int {
    return {
        if i > 1 {
            return fib_2(i-2)() + fib_2(i-1)()
        } else {
            return i
        }
    }
}

func fib_3(_ i: Int) -> Int {
    if i > 1 {
        return fib_3(i-2) + fib_3(i-1)
    } else {
        return i
    }
}


let theNumber = 20

var startTime = Date()
print(fib_1(theNumber))
var endTime = Date()
print(endTime.timeIntervalSince(startTime))

startTime = Date()
print(fib_2(theNumber)())
endTime = Date()
print(endTime.timeIntervalSince(startTime))

startTime = Date()
print(fib_3(theNumber))
endTime = Date()
print(endTime.timeIntervalSince(startTime))
