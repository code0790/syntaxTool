// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

@main
struct syntaxTool: ParsableCommand {
    @Argument(help: "Path to a Swift source file.")
    var filePath: String
    
    mutating func run() throws {
        let source = try String(contentsOfFile: filePath, encoding: .utf8)
        let tree = Parser.parse(source: source)
        let visitor = FullVisitor(viewMode: .sourceAccurate)
        visitor.walk(tree)
        
        //Graphs
        let gHvisitor = GraphBuilderVisitor(viewMode: .sourceAccurate)
        gHvisitor.walk(tree)
        
        print(gHvisitor.functions)
    }
}
