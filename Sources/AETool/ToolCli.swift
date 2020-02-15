/**
 *  https://github.com/tadija/AETool
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation
import AECli

public final class ToolCli: Cli {
    static let systemColor: ANSI.Color = .magenta

    public let name: String
    public let overview: String
    public let core: Command
    public let commands: [Command]
    public let help: String?
    public let output: Output

    public init(name: String = CommandLine.arguments[0],
                overview: String,
                core: Command = Core(),
                commands: [Command],
                help: String? = nil,
                output: Output = ColorOutput()) {
        self.name = name
        self.overview = overview
        self.core = core
        self.commands = [core] + commands
        self.help = help
        self.output = output
    }

    public func run(_ arguments: [String] = [], in cli: Cli) throws {
        if arguments.isEmpty || arguments.first == name {
            try systemRun(
                output(self)
            )
        } else {
            let first = arguments[0]
            let next = Array(arguments.dropFirst())
            let aliases = global.factory.aliases.filter { $0.key == first }
            switch aliases.count {
            case 0:
                let node = try selectNode(matching: first)
                try systemRun(
                    node.command.run(next, in: self),
                    header: ([node.pathDescription] + next).joined(separator: " ")
                )
            case 1:
                var cmd = aliases[0].value.components(separatedBy: " ")
                cmd.append(contentsOf: next)
                try run(cmd, in: cli)
            default:
                throw "found multiple aliases named: \(first)"
            }
        }
    }

    func helpText(for arguments: [String]) throws -> String {
        switch arguments.count {
        case 0:
            return index.root.description
        case 1:
            let node = try selectNode(matching: arguments[0])
            return node.description
        case 2...Int.max:
            let node = try index.searchExact(with: arguments)
            return node.description
        default:
            fatalError()
        }
    }

    private func systemRun(_ cmd: @autoclosure () throws -> Void,
                           header: String = "", footer: String = "") throws {
        systemOutput("<< \(name) \(header)\n")
        try cmd()
        systemOutput("\n>> \(footer)")
    }

    private func systemOutput(_ text: String) {
        print(text.ansi(ToolCli.systemColor))
    }

    private lazy var index: Index = {
        .init(cli: self)
    }()

    private func selectNode(matching query: String) throws -> Index.Node {
        let nodes = index.searchAll(matching: query)
        guard nodes.count > 0 else {
            throw "\(name): command not found: \(query)"
        }
        if nodes.count == 1 {
            return nodes[0]
        } else {
            return try makeChoice(from: nodes)
        }
    }

    private func makeChoice(from nodes: [Index.Node]) throws -> Index.Node {
        var choice = "multiple commands found:\n\n"
        for (i, node) in nodes.enumerated() {
            let found = "\(i + 1): \(node.pathDescription)\n"
            choice += found.ansi(.yellow)
        }
        choice += "\nchoose number (0 to cancel):"
        output(choice)

        let input = readLine() ?? ""
        let intInput = Int(input) ?? -1
        output("")

        if intInput == 0 {
            exit(0)
        } else {
            let index = intInput - 1
            if nodes.indices.contains(index) {
                return nodes[index]
            } else {
                throw "invalid choice"
            }
        }
    }
}

// MARK: - Helpers

public extension Cli {
    func output(_ text: String, color: ANSI.Color) {
        output(text.ansi(color))
    }
}

public final class ColorOutput: Output {
    public init() {}

    public func text(_ text: String) {
        let pad = "  "
        let final = text.replacingOccurrences(of: "\n", with: "\n\(pad)")
        print("\(pad)\(final)")
    }

    public func error(_ error: Error) {
        let redError = error.localizedDescription.ansi(.red)
        fputs("\(redError)\n", stderr)
    }

    public func describe(_ command: Command) -> String {
        var description = "\(command.overview.ansi(.cyan))\n\n"
        if !command.commands.isEmpty {
            description += describe(command.commands)
        }
        if let help = command.help {
            description += "\n\n\(help.ansi(.cyan))"
        }
        return description
    }

    public func describe(_ commands: [Command]) -> String {
        let maxLength = commands.map({ $0.name.count }).max() ?? 0
        let pad = "  "
        let splitter = "\("\(pad)>\(pad)".ansi(ToolCli.systemColor))"
        return commands
            .map({
                "\(pad)\($0.name.padding(maxLength).ansi(.green))\(splitter)\($0.overview)"
            })
            .joined(separator: "\n")
    }
}
