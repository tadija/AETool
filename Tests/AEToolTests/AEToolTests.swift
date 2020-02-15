import XCTest
import AEShell
import AECli
@testable import AETool

final class AEToolTests: XCTestCase {

    // MARK: Tool

    lazy var tool: Tool = {
        let tool = Tool(with: TestConfig())
        tool.launch()
        return tool
    }()

    struct TestConfig: ToolConfig {
        var sourceURL: String {
            "https://github.com/tadija/ae.git"
        }

        var sourceDIR: String {
            "~/.ae"
        }

        var factory: ToolFactory {
            Factory()
        }

        struct Factory: ToolFactory {
            func makeCli() -> Cli {
                ToolCli(
                    name: "my",
                    overview: "test tool",
                    commands: makeCommands(),
                    help: "test help",
                    output: TestOutput()
                )
            }

            func makeCommands() -> [Command] {
                [Hello(), Err(), Thing()]
            }
        }

        struct Hello: Command {
            var overview: String {
                "outputs hello world"
            }

            func run(_ arguments: [String] = [], in cli: Cli) throws {
                cli.output("hello world")
            }
        }

        struct Err: Command {
            var overview: String {
                "runs unknown shell command"
            }

            func run(_ arguments: [String] = [], in cli: Cli) throws {
                try Shell().run("asd")
            }
        }

        struct Thing: Command {
            var overview: String {
                "does something"
            }

            var commands: [Command] {
                [Foo(), Bar()]
            }

            var help: String? {
                "USAGE: command [options]"
            }
        }

        struct Foo: Command {
            var overview: String {
                "foo something"
            }

            func run(_ arguments: [String] = [], in cli: Cli) throws {
                cli.output("foo")
            }
        }

        struct Bar: Command {
            var overview: String {
                "bar something"
            }

            func run(_ arguments: [String] = [], in cli: Cli) throws {
                cli.output("bar")
            }
        }
    }

    class TestOutput: Output {
        var lines = [String]()
        var error: Error = ""

        var text: String {
            lines
                .map({ $0.ansiStripped() })
                .filter({ !$0.starts(with: "<< ") })
                .filter({ !$0.starts(with: "\n>>") })
                .joined(separator: "\n")
        }

        func text(_ text: String) {
            lines.append(text)
        }

        func error(_ error: Error) {
            self.error = error
        }

        func reset() {
            lines.removeAll()
        }
    }

    var output: TestOutput {
        tool.cli.output as! TestOutput
    }

    var cli: ToolCli {
        tool.cli as! ToolCli
    }

    // MARK: Helpers

    let toolDescription = """
    test tool

      core   >  command which drives this thing
      hello  >  outputs hello world
      err    >  runs unknown shell command
      thing  >  does something

    test help
    """

    lazy var thingDescription: String = {
        return tool.cli.output.describe(TestConfig.Thing())
    }()

    let configOutput = """
    Global:
        Source URL: https://github.com/tadija/ae.git
        Source DIR: ~/.ae
        Bin DIR: /usr/local/bin
    Local:
        [:]
    """

    let fooOutput = "foo"
    let barOutput = "bar"

    let myUnknownCommand = "my: command not found: unknown"
    let thingUnknownCommand = "thing: command not found: unknown"

    lazy var toolHelp = try? cli.helpText(for: [])
    lazy var editHelp = try? cli.helpText(for: ["edit"])
    lazy var helpHelp = try? cli.helpText(for: ["help"])
    lazy var helloHelp = try? cli.helpText(for: ["hello"])
    lazy var thingHelp = try? cli.helpText(for: ["thing"])
    lazy var fooHelp = try? cli.helpText(for: ["foo"])

    // MARK: Tests

    func testCore() {
        tool.cli.run(["core", "config"])
        XCTAssertEqual(output.text, configOutput)
        output.reset()

        tool.cli.run(["config"])
        XCTAssertEqual(output.text, configOutput)
        output.reset()

        tool.cli.run(["core", "version"])
        XCTAssertEqual(output.text, global.version)
        output.reset()

        tool.cli.run(["version"])
        XCTAssertEqual(output.text, global.version)
        output.reset()
    }

    func testMy() {
        tool.cli.run([])
        XCTAssertEqual(output.text, toolDescription)
        output.reset()

        tool.cli.run(["unknown"])
        XCTAssertEqual(output.error.localizedDescription, "my: command not found: unknown")
        output.reset()

        tool.cli.run(["hello"])
        XCTAssertEqual(output.text, "hello world")
        output.reset()

        tool.cli.run(["thing"])
        XCTAssertEqual(output.text, thingDescription)
        output.reset()

        tool.cli.run(["thing", "unknown"])
        XCTAssertEqual(output.error.localizedDescription, "thing: command not found: unknown")
        output.reset()

        tool.cli.run(["thing", "foo"])
        XCTAssertEqual(output.text, fooOutput)
        output.reset()

        tool.cli.run(["thing", "bar"])
        XCTAssertEqual(output.text, barOutput)
        output.reset()

        tool.cli.run(["foo"])
        XCTAssertEqual(output.text, fooOutput)
        output.reset()

        tool.cli.run(["bar"])
        XCTAssertEqual(output.text, barOutput)
        output.reset()

        tool.cli.run(["err"])
        let localizedError = "Status: 127\nMessage: zsh:1: command not found: asd"
        XCTAssertEqual(output.error.localizedDescription, localizedError)
        output.reset()
    }

    func testHelp() {
        tool.cli.run(["core", "help"])
        XCTAssertEqual(output.text, toolHelp)
        output.reset()

        tool.cli.run(["help"])
        XCTAssertEqual(output.text, toolHelp)
        output.reset()

        tool.cli.run(["help", "core", "edit"])
        XCTAssertEqual(output.text, editHelp)
        output.reset()

        tool.cli.run(["help", "edit"])
        XCTAssertEqual(output.text, editHelp)
        output.reset()

        tool.cli.run(["help", "help"])
        XCTAssertEqual(output.text, helpHelp)
        output.reset()

        tool.cli.run(["help", "unknown"])
        XCTAssertEqual(output.error.localizedDescription, myUnknownCommand)
        output.reset()

        tool.cli.run(["help", "unknown", "reload"])
        XCTAssertEqual(output.error.localizedDescription, myUnknownCommand)
        output.reset()

        tool.cli.run(["help", "thing", "unknown"])
        XCTAssertEqual(output.error.localizedDescription, thingUnknownCommand)
        output.reset()

        tool.cli.run(["help", "hello"])
        XCTAssertEqual(output.text, helloHelp)
        output.reset()

        tool.cli.run(["help", "thing"])
        XCTAssertEqual(output.text, thingHelp)
        output.reset()

        tool.cli.run(["help", "thing", "unknown"])
        XCTAssertEqual(output.error.localizedDescription, thingUnknownCommand)
        output.reset()

        tool.cli.run(["help", "thing", "foo"])
        XCTAssertEqual(output.text, fooHelp)
        output.reset()
    }

    static var allTests = [
        ("testCore", testCore),
        ("testMy", testMy),
        ("testHelp", testHelp),
    ]

}
