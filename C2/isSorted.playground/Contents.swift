import Foundation

class List<T> {
    let value: T
    let next: List<T>?

    init(value: T, next: List<T>?) {
        self.value = value
        self.next = next
    }
}


func isSorted<T>(list: List<T>, order: (T, T) -> Bool) -> Bool {
    if let nextNode = list.next {
        if order(list.value, nextNode.value) {
            return isSorted(list: nextNode, order: order)
        } else {
            return false
        }
    } else {
        return true
    }
}

let list_1 = List(value: 1, next: List(value: 2, next: List(value: 3, next: nil)))
let list_2 = List(value: 1, next: List(value: 4, next: List(value: 3, next: nil)))

print(isSorted(list: list_1, order: <))
print(isSorted(list: list_2, order: <))
