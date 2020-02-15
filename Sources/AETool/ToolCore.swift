/**
 *  https://github.com/tadija/AETool
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import AECli
import AEShell

public struct Core: Command {
    public var overview: String {
        "command which drives this thing"
    }

    public let commands: [Command] = [
        Config(),
        Edit(),
        Help(),
        Reload(),
        Update(),
        Version()
    ]

    public init() {}

    static let color: ANSI.Color = .cyan
}

struct Config: Command {
    var overview: String {
        "output current config"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        cli.output(global.description, color: Core.color)
    }
}

struct Edit: Command {
    var overview: String {
        "open this project in xcode"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        try Shell(at: global.sourceDIR).run("make edit")
    }
}

struct Help: Command {
    var overview: String {
        "output description for given command"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        guard let cli = cli as? ToolCli else {
            throw "help not available"
        }
        cli.output(
            try cli.helpText(for: arguments), color: Core.color
        )
    }
}

struct Reload: Command {
    var overview: String {
        "build & deploy tool to \(global.binDIR)"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        cli.output(
            try Shell(at: global.sourceDIR).run("make reload"),
            color: Core.color
        )
    }
}

struct Update: Command {
    var overview: String {
        "merge changes from \(global.sourceURL)"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        cli.output(
            try Shell(at: global.sourceDIR).run("make update"),
            color: Core.color
        )
    }
}

struct Version: Command {
    var overview: String {
        "output current version"
    }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        cli.output(global.version, color: Core.color)
    }
}
