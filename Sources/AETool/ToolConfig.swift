/**
 *  https://github.com/tadija/AETool
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import AECli

public protocol ToolConfig: CustomStringConvertible {
    var version: String { get }

    var sourceURL: String { get }
    var sourceDIR: String { get }

    var binDIR: String { get }

    var factory: ToolFactory { get }
}

public extension ToolConfig {
    var version: String {
        "0.1.0"
    }

    var binDIR: String {
        "/usr/local/bin"
    }

    var description: String {
        """
        Global:
            Source URL: \(sourceURL)
            Source DIR: \(sourceDIR)
            Bin DIR: \(binDIR)
        Local:
            \(local.description)
        """
    }
}

public protocol ToolFactory {
    var aliases: KeyValuePairs<String, String> { get }

    func makeCli() -> Cli
    func makeCommands() -> [Command]
}

public extension ToolFactory {
    var aliases: KeyValuePairs<String, String> { [:] }

    func makeCommands() -> [Command] {
        return []
    }
}
