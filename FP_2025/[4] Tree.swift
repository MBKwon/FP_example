import Foundation

class Tree<T> {
    let value: T
    var right: Tree<T>?
    var left: Tree<T>?

    init(value: T, right: Tree<T>?, left: Tree<T>?) {
        self.value = value
        self.right = right
        self.left = left
    }
}
// MARK: - Questions
let test_tree = Tree(value: 2,
                     right: Tree(value: 3,
                                 right: nil,
                                 left: Tree(value: 7,
                                            right: nil,
                                            left: nil)),
                     left: Tree(value: 6,
                                right: Tree(value: 9,
                                            right: Tree(value: 10,
                                                        right: nil,
                                                        left: nil),
                                            left: nil),
                                left: nil))


func traversePreorder<T>(_ f: (T) -> Void, in tree: Tree<E>) {
    if let value = tree.value {
        f(value)
    }
    
    if let leftLeaf = tree.left {
        traversePreorder(f, in: leftLeaf)
    }
    
    if let rightLeaf = tree.right {
        traversePreorder(f, in: rightLeaf)
    }
}

func traverseInorder<T>(_ f: (T) -> Void, in tree: Tree<E>) {
    if let leftLeaf = tree.left {
        traversePreorder(f, in: leftLeaf)
    }
    
    if let value = tree.value {
        f(value)
    }
    
    if let rightLeaf = tree.right {
        traversePreorder(f, in: rightLeaf)
    }
}

func traversePostorder<T>(_ f: (T) -> Void, in tree: Tree<E>) {
    if let leftLeaf = tree.left {
        traversePreorder(f, in: leftLeaf)
    }
    
    if let rightLeaf = tree.right {
        traversePreorder(f, in: rightLeaf)
    }
    
    if let value = tree.value {
        f(value)
    }
}

func add<T>(_ value: T, into tree: Tree<T>) -> Tree<T> {
    if tree.value > value {
        if let leftTree = tree.left {
            return Tree(value: tree.value,
                        right: tree.right,
                        left: add(value, into: leftTree))
        } else {
            return Tree(value: value, right: nil, left: nil)
        }
        
    } else if tree.value < value {
        if let rightTree = tree.right {
            return Tree(value: tree.value,
                        right: add(value, into: rightTree),
                        left: tree.left)
        } else {
            return Tree(value: value, right: nil, left: nil)
        }
        
    } else {
        return tree
    }
}

// MARK: 24
func sizeTree<T>(tree: Tree<T>) -> Int {
    var num = 1
    if let leftLeaf = tree.left {
        num = num + sizeTree(tree: leftLeaf)
    }

    if let rightLeaf = tree.right {
        num = num + sizeTree(tree: rightLeaf)
    }

    return num
}

print("size test (node count)")
print(sizeTree(tree: test_tree))

// MARK: 25
func compareValueTree<T: Comparable>(tree: Tree<T>, f: (T, T) -> Bool) -> T {
    if let leftLeaf = tree.left {
        let num = compareValueTree(tree: leftLeaf, f: f)
        if f(tree.value, num) {
            return tree.value
        } else {
            return num
        }
    }

    if let rightLeaf = tree.right {
        let num = compareValueTree(tree: rightLeaf, f: f)
        if f(tree.value, num) {
            return tree.value
        } else {
            return num
        }
    }

    return tree.value
}

print("max test")
print(compareValueTree(tree: test_tree, f: >))
print("min test")
print(compareValueTree(tree: test_tree, f: <))

// MARK: 26
func depthTree<T>(tree: Tree<T>) -> Int {
    if tree.left == nil, tree.right == nil {
        return 1
    } else {
        var depth = 0
        if let leftLeaf = tree.left {
            depth = max(depth, depthTree(tree: leftLeaf) + 1)
        }

        if let rightLeaf = tree.right {
            depth = max(depth, depthTree(tree: rightLeaf) + 1)
        }

        return depth
    }
}

print("depth test (Height)")
print(depthTree(tree: test_tree))

// MARK: 27
func mapTree<U, V>(tree: Tree<U>, f: (U) -> V) -> Tree<V> {

    let mainTree = Tree(value: f(tree.value), right: nil, left: nil)

    if let leftLeaf = tree.left {
        mainTree.left = mapTree(tree: leftLeaf, f: f)
    }

    if let rightLeaf = tree.right {
        mainTree.right = mapTree(tree: rightLeaf, f: f)
    }

    return mainTree
}

print("map test")
print(mapTree(tree: test_tree, f: { $0 + 1}))

// MARK: - foldTree
// MARK: 28
func foldTree<U, V>(tree: Tree<U>, l: (U) -> V, b: (V, V) -> V) -> V {
    let result = l(tree.value)

    if let leftLeaf = tree.left, let rightLeaf = tree.right {
        let value = b(foldTree(tree: leftLeaf, l: l, b: b),
                      foldTree(tree: rightLeaf, l: l, b: b))

        return b(result, value)

    } else if let leftLeaf = tree.left {
        return b(result, foldTree(tree: leftLeaf, l: l, b: b))

    } else if let rightLeaf = tree.right {
        return b(result, foldTree(tree: rightLeaf, l: l, b: b))

    } else {
        return result
    }

}

func sizeTreeWithFold<T>(tree: Tree<T>) -> Int {
    let getSize: (T?) -> Int = { nodeValue in
        nodeValue != nil ? 1 : 0
    }

    return foldTree(tree: tree, l: getSize, b: { $0 + $1 })
}

print("size test")
print(sizeTreeWithFold(tree: test_tree))


func compareValueTreeWithFold<T: Comparable>(tree: Tree<T>, f: (T, T) -> Bool) -> T {
    return foldTree(tree: tree, l: { $0 }, b: { f($0, $1) ? $0 : $1 })
}

print("min test")
print(compareValueTreeWithFold(tree: test_tree, f: <))
print("max test")
print(compareValueTreeWithFold(tree: test_tree, f: >))

extension Tree {
    enum TreeType {
        case branch, leftLeaf, rightLeaf
    }
}

// MARK: - foldTree_V2
func foldTree_V2<U, V>(tree: Tree<U>, l: (U) -> V,
                       b: ((content: V, type: Tree<V>.TreeType), (content: V, type: Tree<V>.TreeType)) -> V) -> V {

    let result = l(tree.value)

    if let leftLeaf = tree.left, let rightLeaf = tree.right {
        let value = b((foldTree_V2(tree: leftLeaf, l: l, b: b), .leftLeaf),
                      (foldTree_V2(tree: rightLeaf, l: l, b: b), .rightLeaf))

        return b((result, .branch), (value, .branch))

    } else if let leftLeaf = tree.left {
        return b((result, .branch), (foldTree_V2(tree: leftLeaf, l: l, b: b), .leftLeaf))

    } else if let rightLeaf = tree.right {
        return b((result, .branch), (foldTree_V2(tree: rightLeaf, l: l, b: b), .rightLeaf))

    } else {
        return result
    }
}

func depthTreeWithFold<T>(tree: Tree<T>) -> Int {
    return foldTree_V2(tree: tree, l: { _ in
        return 1
    }, b: { value_0, value_1 in
        switch (value_0.type, value_1.type) {
            case (.leftLeaf, .rightLeaf):
                return max(value_1.content, value_0.content)
            case (.branch, .branch), (.branch, .leftLeaf), (.branch, .rightLeaf):
                return value_1.content + 1
            default:
                return 0
        }
    })
}

print("depthTreeWithFold test")
print(depthTreeWithFold(tree: test_tree))

func mapTreeWithFold<U, V>(tree: Tree<U>, f: (U) -> V) -> Tree<V> {
    return foldTree_V2(tree: tree, l: {
        Tree(value: f($0), right: nil, left: nil)
    }, b: { value_0, value_1 in
        switch (value_0.type, value_1.type) {
            case (.leftLeaf, .rightLeaf):
                return Tree(value: value_0.content.value, right: value_1.content, left: value_0.content)
            case (.branch, .branch):
                return Tree(value: value_0.content.value, right: value_1.content.right, left: value_1.content.left)
            case (.branch, .leftLeaf):
                return Tree(value: value_0.content.value, right: nil, left: value_1.content)
            case (.branch, .rightLeaf):
                return Tree(value: value_0.content.value, right: value_1.content, left: nil)
            default:
                return Tree(value: value_0.content.value, right: nil, left: nil)
        }
    })
}

print("mapTreeWithFold test")
let new_tree = mapTreeWithFold(tree: test_tree, f: { $0 * 10 })
print(new_tree)
