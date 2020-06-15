class Node

    include Comparable

    attr_accessor :data, :left_child, :right_child

    def initialize(data, left_child = nil, right_child = nil)
        @data = data
        @left_child = left_child
        @right_child = right_child
    end

end

class Tree

    attr_accessor :root

    def initialize(array)
        @root = build_tree(array)
    end

    def build_tree(array)
        return Node.new(array.first) if array.length == 1
        array.sort!.uniq!
        halfway = (array.length.to_f / 2).round - 1
        root = array[halfway]
        left_tree = array.first == root ? nil : build_tree(array[0..halfway-1])
        right_tree = build_tree(array[halfway+1..-1])
        node = Node.new(root, left_tree, right_tree)
        node
    end

    def insert(value, node = @root, first_run = true)
        return if find(value) && first_run
        return Node.new(value) if !node
        if value < node.data
            !node.left_child ? node.left_child = Node.new(value) : insert(value, node.left_child, false)
        elsif value > node.data
            !node.right_child ? node.right_child = Node.new(value) : insert(value, node.right_child, false)
        end
    end
    
    def delete(value, node = find(value))
        return if !node
        if !node.left_child && !node.right_child
            if parent(node).left_child == node
                parent(node).left_child = nil
            else
                parent(node).right_child = nil
            end
        elsif node == @root
            target = node.right_child ? node.right_child : node.left_child
            until !target.left_child
                target = target.left_child
            end
            node.data = target.data
            delete(node.data, target)
        elsif node.left_child && node.right_child
            array = inorder
            index = array.index(value)
            node.data = array[index + 1]
            if node.left_child.data == node.data
                delete(node.data, node.left_child)
            else
                delete(node.data, node.right_child)
            end
        else
            if parent(node).left_child == node
                parent(node).left_child = node.left_child
            else
                parent(node).right_child = node.right_child
            end
        end        
    end

    def parent(node, pointer = @root)
        return pointer if pointer.left_child == node || pointer.right_child == node
        node.data < pointer.data ? parent(node, pointer.left_child) : parent(node, pointer.right_child)
    end

    #creates depth-level methods dynamically

    ["inorder", "preorder", "postorder"].each do |method|
        define_method(method) do | node = @root, arr = [], &block |

            return arr if !node

            self.send(method, node.left_child, arr, &block) if method == "inorder" || method == "postorder"
            self.send(method, node.right_child, arr, &block) if method == "postorder"

            block ? block.call(node) : arr << node.data

            if method == "inorder" || method == "preorder"
                self.send(method, node.left_child, arr, &block) if method == "preorder"
                self.send(method, node.right_child, arr, &block)
            else
                return arr
            end

        end
    end

    def level_order(node = @root, q = [], arr = [], &block)
        return arr if !node
        yield node if block_given?
        arr << node.data if !block_given?
        q << node.left_child if node.left_child
        q << node.right_child if node.right_child
        level_order(q.shift, q, arr, &block)
    end

    def find(value, node = @root)
        return nil if !node
        return node if node.data == value
        value < node.data ? find(value, node.left_child) : find(value, node.right_child)
    end

    def print
        @root
    end

    def depth(value, counter = 1)
        return (counter - 1) if !value && counter == 1
        return counter if !value
        node = value.class == Integer ? find(value) : value
        counter += 1 if node.left_child || node.right_child
        depth(node.left_child, counter)
        depth(node.right_child, counter)
    end

    def balanced?
        left = depth(@root.left_child)
        right = depth(@root.right_child)
        difference = (left - right).abs
        difference > 1 ? false : true
    end

    def rebalance!
        if !balanced?
            array = level_order
            @root = build_tree(array)
        else
            puts "Tree is already balanced."
        end
    end

end

tree = Tree.new(Array.new(15) { rand(1..100) })

# tree.postorder

until tree.balanced?
    tree.rebalance!
end

p "Level: #{tree.level_order}"
p "Pre: #{tree.preorder}"
p "Post: #{tree.postorder}"
p "Inorder: #{tree.inorder}"

counter = 100
until !tree.balanced?
    tree.insert(counter)
    counter += 10
end

tree.rebalance!

tree.balanced?

p "Level: #{tree.level_order}"
p "Pre: #{tree.preorder}"
p "Post: #{tree.postorder}"
p "Inorder: #{tree.inorder}"