import Foundation

indirect enum UnfoldStream<T> {
    case Cons(head: () -> T, tail: () -> Self)
    case Empty
}

extension UnfoldStream {
    var headOption: Optional<T> {
        switch self {
            case .Cons(let head, _):
                return .some(head())
            case .Empty:
                return .none
        }
    }

    func printStream() {
        switch self {
            case .Cons(let head, let tail):
                print("<Stream>.head(\(head())) -> ")
                tail().printStream()
            case .Empty:
                print("<Stream>.empty")
        }
    }
}

let test_stream: UnfoldStream<Int> =
    .Cons(head: { 2 }) {
        .Cons(head: { 3 }) {
            .Cons(head: { 4 }) {
                .Cons(head: { 2 }) {
                    .Empty
                }
            }
        }
    }


// MARK: - Questions
// MARK: 1
class List<T> {
    let value: T
    var next: List<T>?

    init(value: T, next: List<T>?) {
        self.value = value
        self.next = next
    }
}

extension List {
    func printList() {
        if let nextNode = next {
            print("<List>.value(\(self.value)) -> ")
            nextNode.printList()
        } else {
            print("<List>.value(\(self.value))")
        }

    }
}

extension UnfoldStream {
    func toList() -> List<T>? {
        switch self {
            case .Cons(let head, let tail):
                return List(value: head(), next: tail().toList())
            case .Empty:
                return nil
        }
    }
}

test_stream.toList()?.printList()


// MARK: 2
extension UnfoldStream {
    func take(n: Int) -> Self {
        if n == 0 {
            return .Empty
        }

        switch self {
            case .Cons(let head, let tail):
                return .Cons(head: head, tail: { tail().take(n: n-1) })
            case .Empty:
                return .Empty
        }
    }

    func drop(n: Int) -> Self {
        if n == 0 {
            return self
        }

        switch self {
            case .Cons(let head, let tail):
                return tail().drop(n: n-1)
            case .Empty:
                return .Empty
        }
    }
}

test_stream.take(n: 2).printStream()
test_stream.drop(n: 2).printStream()


// MARK: 3
extension UnfoldStream {
    func takeWhile(p: @escaping (T) -> Bool) -> Self {
        switch self {
            case .Cons(let head, let tail) where p(head()):
                return .Cons(head: head, tail: { tail().takeWhile(p: p) })
            default:
                return .Empty
        }
    }
}

test_stream.takeWhile(p: { $0 < 4 }).toList()?.printList()


// MARK: 4
extension UnfoldStream {
    func checkAllSafe(p: (T) -> Bool) -> Bool {
        switch self {
            case .Cons(let head, let tail) where p(head()):
                return tail().checkAllSafe(p: p)
            case .Empty:
                return true
            default:
                return false
        }
    }
}

print(test_stream.checkAllSafe(p: { $0 < 4 }))
print(test_stream.checkAllSafe(p: { $0 < 5 }))


// MARK: 5
func foldRight<U, V>(stream: UnfoldStream<U>, value: V, f: (U, V) -> V) -> V {
    switch stream {
        case .Cons(let head, let tail):
            return f(head(), foldRight(stream: tail(), value: value, f: f))
        case .Empty:
            return value
    }
}

extension UnfoldStream {
    func takeWhileWithFold(p: (T) -> Bool) -> Self {
        return foldRight(stream: self, value: .Empty) { cons, partialResult in
            if p(cons) {
                .Cons(head: { cons }, tail: { partialResult })
            } else {
                .Empty
            }
        }
    }
}

test_stream.takeWhileWithFold(p: { $0 < 4 }).printStream()


// MARK: 6
extension UnfoldStream {
    var headOptionWithFold: Optional<T> {
        return foldRight(stream: self, value: .none) { cons, _ in
            return .some(cons)
        }
    }
}

print(test_stream.headOptionWithFold ?? "Optional.none")


// MARK: 7
extension UnfoldStream {
    func map<U>(f: @escaping (T) -> U) -> UnfoldStream<U> {
        return foldRight(stream: self, value: .Empty) { cons, partialResult in
                .Cons(head: { f(cons) }, tail: { partialResult })
        }
    }

    func filter(f: @escaping (T) -> Bool) -> Self {
        return foldRight(stream: self, value: .Empty) { cons, partialResult in
            if f(cons) {
                return .Cons(head: { cons }, tail: { partialResult })
            } else {
                return partialResult
            }
        }
    }

    func append(_ element: Self) -> Self {
        return foldRight(stream: self, value: .Empty) { cons, partialResult in
            switch partialResult {
                case .Cons(_, _):
                    return partialResult
                case .Empty:
                    return element
            }
        }
    }
}


extension UnfoldStream {
    static func makeUnfoldStream(first: T, next: @escaping (T) -> T) -> UnfoldStream<T> {
        let nextValue = next(first)
        return .Cons(head: { first }, tail: {
            UnfoldStream.makeUnfoldStream(first: nextValue, next: next)
        })
    }
}


// MARK: 8
extension UnfoldStream where T == Int {
    static var ones: UnfoldStream<Int> = UnfoldStream.makeUnfoldStream(first: 1, next: { $0 })
}

extension UnfoldStream {
    func getConstant(a: T) -> UnfoldStream<T> {
        return UnfoldStream.makeUnfoldStream(first: a, next: { $0 })
    }
}


// MARK: 9
extension UnfoldStream where T == Int {
    static func from(n: Int) -> UnfoldStream<Int> {
        return UnfoldStream.makeUnfoldStream(first: n, next: { $0 + 1 })
    }
}

UnfoldStream<Int>.from(n: 1).take(n: 2).printStream()


// MARK: 10
func getFibs() -> UnfoldStream<Int> {
    func go(first: Int, next: Int) -> UnfoldStream<Int> {
        let nextValue = first + next
        return .Cons(head: { first }, tail: { go(first: next, next: nextValue) })
    }

    return go(first: 0, next: 1)
}

getFibs().take(n: 10).printStream()


// MARK: 11
// UnfoldStream.makeUnfoldStream
extension UnfoldStream {
    static func makeUnfoldStream<U>(first: T, next: @escaping (T) -> (U, T)?) -> UnfoldStream<U> {
        guard let nextValue = next(first) else { return .Empty}
        return .Cons(head: { nextValue.0 }, tail: {
            UnfoldStream.makeUnfoldStream(first: nextValue.1, next: next)
        })
    }
}


// MARK: 12
func getFibsWithUnfold() -> UnfoldStream<Int> {
    return UnfoldStream.makeUnfoldStream(first: (0, 1)) { tuple in
        let nextValue = tuple.0 + tuple.1
        return (nextValue, (tuple.1, nextValue))
    }
}

getFibsWithUnfold().take(n: 10).printStream()


// MARK: 13
extension UnfoldStream {
    func mapUnfold<U>(f: @escaping (T) -> U) -> UnfoldStream<U> {
        return UnfoldStream<UnfoldStream<T>>.makeUnfoldStream(first: self) { currentCons in
            switch currentCons {
                case .Cons(let head, let tail):
                    return (f(head()), tail())
                case .Empty:
                    return nil
            }
        }
    }

    func takeUnfold(n: Int) -> UnfoldStream<T> {
        return UnfoldStream<(UnfoldStream<T>, Int)>.makeUnfoldStream(first: (self, n)) { currentCons in
            switch currentCons.0 {
                case .Cons(let head, let tail) where currentCons.1 > 0:
                    return (head(), (tail(), currentCons.1 - 1))
                default:
                    return nil
            }
        }
    }

    func takeWhileUnfold(p: @escaping (T) -> Bool) -> UnfoldStream<T> {
        return UnfoldStream<UnfoldStream<T>>.makeUnfoldStream(first: self) { currentCons in
            switch currentCons {
                case .Cons(let head, let tail) where p(head()):
                    return (head(), tail())
                default:
                    return nil
            }
        }
    }

    func zipUnfold<U, V>(with that: UnfoldStream<U>, f: @escaping (T, U) -> V) -> UnfoldStream<V> {
        return UnfoldStream<(UnfoldStream<T>, UnfoldStream<U>)>
            .makeUnfoldStream(first: (self, that)) { currentCons in
                switch currentCons {
                    case (.Cons(let head1, let tail1), .Cons(let head2, let tail2)):
                        return (f(head1(), head2()), (tail1(), tail2()))
                    default:
                        return nil
                }
            }
    }

    func zipAllUnfold<U>(with that: UnfoldStream<U>) -> UnfoldStream<(T, U)> {
        return UnfoldStream<(UnfoldStream<T>, UnfoldStream<U>)>
            .makeUnfoldStream(first: (self, that)) { currentCons in
                switch currentCons {
                    case (.Cons(let head1, let tail1), .Cons(let head2, let tail2)):
                        return ((head1(), head2()), (tail1(), tail2()))
                    default:
                        return nil
                }
            }
    }
}

UnfoldStream<Int>.from(n: 1)
    .mapUnfold(f: { $0 * 2 + 1})
    .takeWhileUnfold(p: { $0 < 50 })
    .printStream()


// MARK: 14
extension UnfoldStream where T: Equatable {
    func start(with that: Self) -> Bool {
        return self.zipUnfold(with: that) { $0 == $1 }.checkAllSafe(p: { $0 })
    }
}

print(UnfoldStream<Int>.from(n: 1)
    .mapUnfold(f: { $0 * 2 + 1})
    .takeWhileUnfold(p: { $0 < 50 })
    .start(with: UnfoldStream<Int>.Cons(head: { 3 }, tail: { .Empty })))

print(UnfoldStream<Int>.from(n: 1)
    .mapUnfold(f: { $0 * 2 + 1})
    .takeUnfold(n: 3)
    .start(with: UnfoldStream<Int>.Cons(head: { 2 }, tail: { .Empty })))


// MARK: 15
extension UnfoldStream {
    var tails: UnfoldStream<UnfoldStream<T>> {
        return UnfoldStream<UnfoldStream<T>>.makeUnfoldStream(first: self) { currentCons in
            switch currentCons {
                case .Cons(let head, let tail):
                    return (currentCons, tail())
                case .Empty:
                    return nil
            }
        }
    }
}

UnfoldStream<Int>.from(n: 1)
    .takeUnfold(n: 2)
    .tails
    .printStream()


// MARK: 16
