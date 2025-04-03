import Foundation

func multiply(x: Int, y: Int) -> num {
    return x * y
}

func printFormula(with formula: String,
                  closure: (Int, Int) -> Int) -> (Int, Int) -> Int {
    return { x, y in
        print("\(formula) = \(closure(x, y))")
    }
}

func  printMultiply(with num: Int, from start: Int, until end: Int) {
    guard start <= end else { return }
    printMultiply(with: num, from: start + 1, until: end)
    let function = printFormula("\(num) * \(start)", multiply)
    function(start, end)
}
