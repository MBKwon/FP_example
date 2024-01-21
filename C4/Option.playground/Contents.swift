import Foundation

// MARK: - Questions
// MARK: 1
extension Optional {

    func map<B>(_ f: (Wrapped) -> B) -> B? {
        switch self {
            case .some(let value):
                return .some(f(value))
            case .none:
                return .none
        }
    }

    func flatMap<B>(_ f: (Wrapped) -> B?) -> B? {
        switch self {
            case .some(let value):
                return f(value)
            case .none:
                return .none
        }
    }

    func getOrElse(default: Wrapped) -> Wrapped {
        switch self {
            case .some(let value):
                return value
            case .none:
                return `default`
        }
    }

    func orElse(_ f: () -> Wrapped) -> Wrapped? {
        switch self {
            case .some:
                return self
            case .none:
                return f()
        }
    }

    func filter(_ f: (Wrapped) -> Bool) -> Wrapped? {
        switch self {
            case .some(let value) where f(value):
                return self
            default:
                return .none
        }
    }
}


// MARK: 2
extension Array where Element: Numeric {
    var mean: Double? {
        if self.isEmpty {
            return .none
        } else {
            let sum = self.reduce(Element.zero, +)
            let count = Double(self.count)
            if let sumValue = sum as? (any BinaryInteger) {
                return Double(sumValue) / count
            } else if let sumValue = sum as? (any BinaryFloatingPoint) {
                return Double(sumValue) / count
            }
        }

        return nil
    }

    var variance: Double? {
        let numList = self.compactMap {
            if let num = $0 as? (any BinaryInteger) {
                return Double(num)
            } else if let num = $0 as? (any BinaryFloatingPoint) {
                return Double(num)
            } else {
                return nil
            }
        }
        guard numList.count == self.count else { return nil }
        guard let meanValue = self.mean else { return nil }
        return numList.map { pow(($0 - meanValue), 2) }
            .mean
    }
}

print([12, 13, 14, 15, 16, 17].mean ?? 0)
print([12, 13, 14, 15, 16, 17].variance ?? 0)


// MARK: 3
func map2<A, B, C>(a: A?, b: B?, f: (A, B) -> C) -> C? {
    guard let unwrappedA = a, let unwrappedB = b else { return nil }
    return f(unwrappedA, unwrappedB)
}


// MARK: 4
extension Array where Element == Optional<Any> {
    var sequence: Array<Any>? {
        return self.reduce(Array<Any>()) { partialResult, element in
            if case .some(var array) = partialResult, case .some(let value) = element {
                array.append(value)
                return array
            } else {
                return nil
            }
        }
    }
}

let test_array = [2, 3, 4, 5, 6].sequence
let test_array_optional = [2, nil, nil, 5, 6].sequence


// MARK: 5
extension Array {
    func traverse<B>(_ f: (Element) -> B?) -> Array<B>? {
        return self.reduce(Array<B>()) { partialResult, element in
            if case .some(var array) = partialResult, let value = f(element) {
                array.append(value)
                return array
            } else {
                return nil
            }
        }
    }
}


let test_traverse_array = [Optional(2), 3, 4, 5, 6].traverse({
    switch $0 {
        case .some(let value):
            return value + 1
        case .none:
            return nil
    }
})
let test_traverse_array_optional = [2, nil, nil, 5, 6].traverse({
    switch $0 {
        case .some(let value):
            return value + 1
        case .none:
            return nil
    }
})


// MARK: 6
enum Either<E, A> {
    case left(E)
    case right(A)
}

extension Either {
    func map<B>(_ f: (A) -> B) -> Either<E, B> {
        switch self {
            case .right(let value):
                return Either<E, B>.right(f(value))
            case .left(let value):
                return Either<E, B>.left(value)
        }
    }

    func flatMap<B>(_ f: (A) -> Either<E, B>) -> Either<E, B> {
        switch self {
            case .right(let value):
                return f(value)
            case .left(let value):
                return Either<E, B>.left(value)
        }
    }

    func orElse(_ f: () -> Either<E, A>) -> Either<E, A> {
        switch self {
            case .right(let value):
                return f()
            case .left:
                return self
        }
    }
}

func map2WithEither<E, A, B, C>(a: Either<E, A>, b: Either<E, B>, f: (A, B) -> C) -> Either<E, C> {
    switch (a, b) {
        case (.right(let valueA), .right(let valueB)):
            return Either<E, C>.right(f(valueA, valueB))
        case (.left(let valueA), _):
            return Either<E, C>.left(valueA)
        case (_, .left(let valueB)):
            return Either<E, C>.left(valueB)
    }
}


// MARK: 7
extension Array where Element == Either<String, Any> {
    var sequence: Either<String, Array<Any>> {
        return self.reduce(Either<String, Array<Any>>.right([])) { partialResult, element in
            if case .right(var array) = partialResult, case .right(let value) = element {
                array.append(value)
                return .right(array)
            } else {
                return .left("Left is found")
            }
        }
    }

    func traverse<B>(_ f: (Element) -> Either<String, B>) -> Either<String, Array<B>> {
        return self.reduce(Either<String, Array<B>>.right([])) { partialResult, element in
            if case .right(var array) = partialResult, case .right(let value) = f(element) {
                array.append(value)
                return .right(array)
            } else {
                return .left("Left is found")
            }
        }
    }
}


// MARK: 8
struct Name {
    let value: String
}

struct Age {
    let value: Int
}

struct Person {
    let name: Name
    let age: Age
}

func mkName(name: String) -> Either<String, Name> {
    if name.isEmpty {
        return .left("name is empty")
    } else {
        return .right(Name(value: name))
    }
}

func mkAge(age: Int) -> Either<String, Age> {
    if age < 0 {
        return .left("age is empty")
    } else {
        return .right(Age(value: age))
    }
}

func mkperson(name: String, age: Int) -> Either<String, Person> {
    return map2WithEither(a: mkName(name: name), b: mkAge(age: age)) { n, a in
        Person(name: n, age: a)
    }
}

let test_person_1 = mkperson(name: "Brad", age: 33)
let test_person_2 = mkperson(name: "", age: 33)
let test_person_3 = mkperson(name: "Brad", age: -1)
let test_person_4 = mkperson(name: "", age: -1)


// MARK: 8 answer
extension Either where E: OptionSet {
    func printOption() {
        switch self {
            case .left(let optionSet):
                print(optionSet)
            case .right:
                print("noOption")
        }
    }
}

func map2WithOptionSet<E: OptionSet, A, B, C>(a: Either<E, A>, b: Either<E, B>, f: (A, B) -> C) -> Either<E, C> {
    switch (a, b) {
        case (.right(let valueA), .right(let valueB)):
            return Either<E, C>.right(f(valueA, valueB))
        case (.left(let valueA), .left(let valueB)):
            return Either<E, C>.left(valueA.union(valueB))
        case (.left(let valueA), _):
            return Either<E, C>.left(valueA)
        case (_, .left(let valueB)):
            return Either<E, C>.left(valueB)
    }
}

struct PersonError : OptionSet {
    let rawValue: Int

    static let invalidName  = PersonError(rawValue: 1 << 0)
    static let invalidAge = PersonError(rawValue: 1 << 1)
}

func mkNameWithOptionSet(name: String) -> Either<PersonError, Name> {
    if name.isEmpty {
        return .left(.invalidName)
    } else {
        return .right(Name(value: name))
    }
}

func mkAgeWithOptionSet(age: Int) -> Either<PersonError, Age> {
    if age < 0 {
        return .left(.invalidAge)
    } else {
        return .right(Age(value: age))
    }
}

func mkPersonWithOptionSet(name: String, age: Int) -> Either<PersonError, Person> {
    return map2WithOptionSet(a: mkNameWithOptionSet(name: name), b: mkAgeWithOptionSet(age: age)) { n, a in
        Person(name: n, age: a)
    }
}

let test_person_1_withOption = mkPersonWithOptionSet(name: "Brad", age: 33)
let test_person_2_withOption = mkPersonWithOptionSet(name: "", age: 33)
let test_person_3_withOption = mkPersonWithOptionSet(name: "Brad", age: -1)
let test_person_4_withOption = mkPersonWithOptionSet(name: "", age: -1)

test_person_1_withOption.printOption()
test_person_2_withOption.printOption()
test_person_3_withOption.printOption()
test_person_4_withOption.printOption()
