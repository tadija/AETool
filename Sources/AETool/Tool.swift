/**
 *  https://github.com/tadija/AETool
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import AECli

private var tool: Tool {
    .current
}

public final class Tool {
    private static var _current: Tool?

    static var current: Tool {
        guard let instance = _current else {
            fatalError("`launch()` not called")
        }
        return instance
    }

    let config: ToolConfig

    let cli: Cli

    let memory = ToolMemory()

    public init(with config: ToolConfig) {
        self.config = config
        self.cli = config.factory.makeCli()
    }

    public func launch() {
        Self._current = self
        cli.launch()
    }
}

public var global: ToolConfig {
    tool.config
}

public var local: FileConfig {
    .init("\(tool.cli.name).json")
}

public var memory: ToolMemory {
    tool.memory
}
