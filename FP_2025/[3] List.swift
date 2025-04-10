import Foundation

class List<T> {
    let value: T
    var next: List<T>?

    init(value: T, next: List<T>?) {
        self.value = value
        self.next = next
    }
}
// MARK: - Questions
let test_list = List(value: 1, next: List(value: 2, next: List(value: 3, next: nil)))

// MARK: 1
func tail<T>(list: List<T>) -> List<T>? {
    if let nextNode = list.next {
        return nextNode
    } else {
        return nil
    }
}

// MARK: 2
func setHead<T: Equatable>(list: List<T>, value: T) -> List<T> {
    if list.value == value {
        return list
    } else {
        return List(value: value, next: list.next)
    }
}

func setTail<T: Equatable>(list: List<T>, value: T) -> List<T> {
    if let nextNode == list.next {
        return List(value: list.value,
                    next: setTail(list: nextNode, value: value))
    } else {
        list.next = List(value: value, next: nil)
        return list
    }
}

// MARK: 3
func drop<T>(list: List<T>, n: Int) -> List<T>? {
    if n == 0 {
        return list
    } else if let nextNode = list.next {
        return drop(list: nextNode, n: n-1)
    } else {
        return nil
    }
}

// MARK: 4
func dropWhile<T>(list: List<T>, f: (T) -> Bool) -> List<T>? {
    if f(list.value) {
        return list
    } else if let nextNode = list.next {
        return dropWhile(list: nextNode, f: f)
    } else {
        return nil
    }
}

// MARK: 5
func initList<T>(list: List<T>) -> List<T>? {
    if let nextNode = list.next {
        return List(value: list.value, next: initList(list: nextNode))
    } else {
        return nil
    }
}


// MARK: - foldRight
func foldRight<U, V>(list: List<U>?, value: V, f: (U, V) -> V) -> V {
    if let listNode = list {
        return f(listNode.value, foldRight(list: listNode.next,
                                           value: value, f: f))
    } else {
        return value
    }
}

// MARK: 6

// MARK: 7
if let result_7 = foldRight(list: test_list,
                            value: nil, f: { x, y in return List(value: x, next: y) }) {
    print("copy: \(result_7)")
}

// MARK: 8
func length<T>(list: List<T>) -> Int {
    foldRight(list: test_list, value: 0) { _, y in
        y + 1
    }
}

print("lenght: \(length(list: test_list))")

// MARK: 9
func foldLeft<U, V>(list: List<U>?, value: V, f: (U, V) -> V) -> V {
    if let listNode = list {
        return foldLeft(list: listNode.next,
                        value: f(listNode.value, value), f: f)
    } else {
        return value
    }
}

foldRight(list: test_list, value: 0) { value, _ in
    print("foldRight \(value)")
    return value
}

foldLeft(list: test_list, value: 0) { value, _ in
    print("foldLeft \(value)")
    return value
}

// MARK: 13
func appendRight<T>(list: List<T>, value: T) -> List<T> {
    return foldRight(list: list, value: List(value: value, next: nil)) { nodeValue, value in
        List(value: nodeValue, next: value)
    }
}

func appendLeft<T>(list: List<T>, value: T) -> List<T> {
    foldLeft(list: list, value: list) { nodeValue, value in
        value.next ?? value
    }.next = List(value: value, next: nil)
    return list
}

print("append test")
let appended_right_list = appendRight(list: test_list, value: 20)
let appended_left_list = appendLeft(list: test_list, value: 20)

// MARK: 14
let numList = [1, 2, 3, 4]
let resultList = numList
    .map({ List.init(value: $0, next: nil) })
    .reversed()
    .reduce(nil) { partialResult, node in
        node.next = partialResult
        return node
    }

// MARK: 15, 17
func mapList<U, V>(list: List<U>, f: (U) -> V) -> List<V> {
    if let nextNode = list.next {
        return List(value: f(list.value), next: mapList(list: nextNode, f: f))
    } else {
        return List(value: f(list.value), next: nil)
    }
}

func printElement<T>(list: List<T>?) {
    guard let list = list else {
        print("empty")
        return
    }
    print(list.value)

    if let nextNode = list.next {
        return printElement(list: nextNode)
    }
}

print("map +1")
printElement(list: mapList(list: test_list, f: { $0 + 1 }))

// MARK: 16
print("map string")
printElement(list: mapList(list: test_list, f: { String($0) }))

// MARK: 18
func filterList<T>(list: List<T>, f: (T) -> Bool) -> List<T>? {
    if let nextNode = list.next {
        if f(list.value) {
            return List(value: list.value,
                        next: filterList(list: nextNode, f: f))
        } else {
            return filterList(list: nextNode, f: f)
        }
    } else if f(list.value) {
        return List(value: list.value, next: nil)
    } else {
        return nil
    }
}

print("filter test")
printElement(list: test_list)
printElement(list: filterList(list: test_list, f: { $0 % 2 == 0 }))

// MARK: 19
func flatMapList<U, V>(list: List<U>, f: (U) -> List<V>?) -> List<V>? {
    if let nextNode = list.next {
        if let node = f(list.value) {
            node.next = flatMapList(list: nextNode, f: f)
            return node
        } else {
            return flatMapList(list: nextNode, f: f)
        }
    } else {
        return f(list.value)
    }
}

// MARK: 20
func filterListWithFlatMap<T>(list: List<T>, f: (T) -> Bool) -> List<T>? {
    return flatMapList(list: list) { value in
        if f(value) {
            return List(value: value, next: nil)
        } else {
            return nil
        }
    }
}

print("filter with flatMap test")
printElement(list: test_list)
printElement(list: filterListWithFlatMap(list: test_list, f: { $0 % 2 == 1 }))

// MARK: 21, 22
func zipList<T>(list_1: List<T>, list_2: List<T>, f: (T, T) -> T) -> List<T>? {
    if let nextNode_1 = list_1.next, let nextNode_2 = list_2.next {
        return List(value: f(list_1.value, list_2.value),
                    next: zipList(list_1: nextNode_1, list_2: nextNode_2, f: f))
    } else {
        return nil
    }
}

print("zipList test")
printElement(list: zipList(list_1: test_list, list_2: test_list, f: +))
