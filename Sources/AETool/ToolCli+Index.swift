/**
*  https://github.com/tadija/AETool
*  Copyright © 2020 Marko Tadić
*  Licensed under the MIT license
*/

import AECli

extension ToolCli {
    class Index {
        let root: Node

        init(cli: Cli) {
            root = Node(path: [cli.name], command: cli)
            root.populate(with: cli.commands)
        }

        func searchAll(matching name: String) -> [Node] {
            root.findAll(named: name)
        }

        func searchExact(with arguments: [String]) throws -> Node {
            var node = root
            var iterator = arguments.makeIterator()
            while let arg = iterator.next() {
                if let found = node.findFirst(named: arg) {
                    node = found
                } else {
                    throw "\(node.command.name): command not found: \(arg)"
                }
            }
            return node
        }
    }
}

extension ToolCli.Index {
    class Node: CustomStringConvertible {
        let path: [String]
        let command: Command

        var children: [Node] = []

        var description: String {
            var result = "# \(pathDescription)\n> \(command.overview)"
            if !children.isEmpty {
                let childrenText = childrenDescription()
                    .trimmingCharacters(in: .newlines)
                result += "\n\n\(childrenText)"
            }
            if let help = command.help {
                result += "\n\n\(help)"
            }
            return result
        }

        var pathDescription: String {
            path.joined(separator: " ")
        }

        init(path: [String], command: Command) {
            self.path = path
            self.command = command
        }

        func populate(with commands: [Command], at path: [String] = []) {
            for command in commands {
                let commandPath = path + [command.name]

                let child = Node(
                    path: commandPath,
                    command: command
                )
                children.append(child)

                let subcommands = command.commands
                if !subcommands.isEmpty {
                    child.populate(with: subcommands, at: commandPath)
                }
            }
        }

        func findFirst(named name: String) -> Node? {
            if name == command.name {
                return self
            }
            for child in children {
                if let found = child.findFirst(named: name) {
                    return found
                }
            }
            return nil
        }

        func findAll(named name: String) -> [Node] {
            var items = [Node]()
            if name == command.name {
                items += [self]
            }
            for child in children {
                items += child.findAll(named: name)
            }
            return items
        }

        func childrenDescription(indent: Int = 1) -> String {
            var result = String()
            let maxLength = children.map({ $0.command.name.count }).max() ?? 0
            let pad = "  "
            let splitter = "\(pad)>\(pad)"
            for child in children {
                result += Array(repeating: pad, count: indent).joined()
                result += child.command.name.padding(maxLength)
                result += "\(splitter)\(child.command.overview)"
                result += "\n"
                if !child.children.isEmpty {
                    result += "\n"
                    result += child.childrenDescription(indent: indent + 1)
                    result += "\n"
                }
            }
            return result
        }
    }
}
