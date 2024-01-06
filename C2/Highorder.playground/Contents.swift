import Foundation

func compose<A, B, C>(_ f1: @escaping (A) -> B, _ f2: @escaping (B) -> C) -> (A) -> C {
    return { (a: A) in
        return f2(f1(a))
    }
}

let calcComposition = compose({ $0 + 1 }, { $0 * 2})
print(calcComposition(1))
