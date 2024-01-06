//
//  ViewController.swift
//  FiboTest
//
//  Created by Moonbeom KWON on 2024/01/06.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let theNumber = 20

            print("fib_1")
            var startTime = Date()
            print(self.fib_1(theNumber))
            var endTime = Date()
            print(endTime.timeIntervalSince(startTime))
            print("\n")

            print("fib_2")
            startTime = Date()
            print(self.fib_2(theNumber))
            endTime = Date()
            print(endTime.timeIntervalSince(startTime))
            print("\n")

            print("fib_3")
            startTime = Date()
            print(self.fib_3(theNumber))
            endTime = Date()
            print(endTime.timeIntervalSince(startTime))
            print("\n")

            print("fib_4")
            startTime = Date()
            print(self.fib_4(theNumber))
            endTime = Date()
            print(endTime.timeIntervalSince(startTime))
            print("\n")

            print("fib_5")
            startTime = Date()
            print(self.fib_5(theNumber))
            endTime = Date()
            print(endTime.timeIntervalSince(startTime))
            print("\n")
        }
    }
}

extension ViewController {
    // 6.5s
    // 3.3s [-Os]
    func fib_1(_ i: Int) -> Int {
        var value = i
        if i > 1 {
            value = self.fib_1(i-2) + self.fib_1(i-1)
        }
        return value
    }

    // 0.62s
    // 0.43s [-Os]
    func fib_2(_ i: Int) -> Int {
        if i > 1 {
            return self.fib_2(i-2) + self.fib_2(i-1)
        } else {
            return i
        }
    }

    // 0.22s
    // 0.27s [-Os]
    func fib_3(_ i: Int) -> Int {
        func inner_fib(value: Int) -> Int {
            if value > 1 {
                return inner_fib(value: value-2) + inner_fib(value: value-1)
            } else {
                return value
            }
        }

        return inner_fib(value: i)
    }

    // 0.26s
    // 0.22s [-Os]
    func fib_4(_ i: Int) -> Int {
        func inner_fib(value: Int) -> Int {
            return value > 1 ? inner_fib(value: value-2) + inner_fib(value: value-1) : value
        }

        return inner_fib(value: i)
    }

    // 1.1s
    // 0.41s [-Os]
    func fib_5(_ i: Int) -> Int {
        return i > 1 ? fib_5(i-2) + fib_5(i-1) : i
    }
}

