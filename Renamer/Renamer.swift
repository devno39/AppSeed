#!/usr/bin/env swift

import Foundation

final class Renamer: NSObject {
    // MARK: - Properties
    let fileManager = FileManager.default
    var processedPaths = [String]()
    
    var oldName: String
    let newName: String
    
    // MARK: - Init
    init(oldName: String, newName: String) {
        self.oldName = oldName
        self.newName = newName
    }
    
    // MARK: - API
    func run() {
        var currentPath = fileManager.currentDirectoryPath
        let scriptPath: URL = URL(fileURLWithPath: currentPath)
        let folderPath: URL = scriptPath.deletingLastPathComponent()
        
        print("Script is running in directory: \(folderPath.path)")
        
        if let oldProjectName = findOldProjectName(folderPath) {
            oldName = oldProjectName
            print("Old project name found: \(oldName). Processing continues.")
        } else {
            print("Error: Could not detect an .xcodeproj file in \(folderPath.path).")
            print("Please provide the old project name manually:")
            if let name = readLine(), !name.isEmpty {
                oldName = name
            } else {
                print("No project name entered. Exiting.")
                exit(1)
            }
        }
        
        if fileManager.changeCurrentDirectoryPath(folderPath.path) {
            print("\nSuccess: Changed to project directory.")
            currentPath = fileManager.currentDirectoryPath
        } else {
            print("Error: Could not change to project directory at \(folderPath.path). Exiting.")
            exit(1)
        }
        
        print("Current directory is \(currentPath)")
        print("\n------------------------------------------")
        print("Rename Xcode Project from [\(oldName)] to [\(newName)]")
        print("------------------------------------------\n")
        
        if validatePath(currentPath) {
            enumeratePath(currentPath)
        } else {
            print("Error: Xcode project or workspace with name [\(oldName)] not found.")
            exit(1)
        }
        
        print("\n------------------------------------------")
        print("Xcode Project Rename Finished!")
        print("------------------------------------------\n")
    }
    
    // MARK: - Helpers
    private func findOldProjectName(_ projectFolderPath: URL) -> String? {
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: projectFolderPath, includingPropertiesForKeys: nil, options: [])
            print("Searching for .xcodeproj in \(projectFolderPath.path)...")
            guard let projectFileName = directoryContents.filter({ $0.pathExtension == "xcodeproj" }).first?.deletingPathExtension().lastPathComponent else {
                return nil
            }
            return projectFileName
        } catch {
            print("Error reading directory contents: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func validatePath(_ path: String) -> Bool {
        let projectPath = path.appending("/\(oldName).xcodeproj")
        let workspacePath = path.appending("/\(oldName).xcworkspace")
        let isValid = fileManager.fileExists(atPath: projectPath) || fileManager.fileExists(atPath: workspacePath)
        return isValid
    }
    
    private func enumeratePath(_ path: String) {
        let enumerator = fileManager.enumerator(atPath: path)
        while let element = enumerator?.nextObject() as? String {
            let itemPath = path.appending("/\(element)")
            if !processedPaths.contains(itemPath) && !shouldSkip(element) {
                processPath(itemPath)
            }
        }
    }
    
    private func processPath(_ path: String) {
        print("Processing: \(path)")
        
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                enumeratePath(path)
            } else {
                updateContentsOfFile(atPath: path)
            }
            renameItem(atPath: path)
        }
        
        processedPaths.append(path)
    }
    
    private func shouldSkip(_ element: String) -> Bool {
        guard
            !element.hasPrefix("."),
            !element.contains(".DS_Store"),
            !element.contains("Carthage"),
            !element.contains("Pods"),
            !element.contains("fastlane"),
            !element.contains("build")
        else { return true }
        
        let fileExtension = URL(fileURLWithPath: element).pathExtension
        switch fileExtension {
        case "appiconset", "json", "png", "xcuserstate":
            return true
        default:
            return false
        }
    }
    
    private func updateContentsOfFile(atPath path: String) {
        do {
            let oldContent = try String(contentsOfFile: path, encoding: .utf8)
            if oldContent.contains(oldName) {
                var newContent = oldContent.replacingOccurrences(of: oldName, with: newName)
                if oldContent.contains("\(oldName)Tests") || oldContent.contains("\(oldName)UITests") {
                    let testClassOldName = oldName.replacingOccurrences(of: "-", with: "_")
                    newContent = newContent.replacingOccurrences(of: testClassOldName, with: newName)
                }
                try newContent.write(toFile: path, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error updating file: \(error.localizedDescription)")
        }
    }
    
    private func renameItem(atPath path: String) {
        do {
            let oldItemName = URL(fileURLWithPath: path).lastPathComponent
            if oldItemName.contains(oldName) {
                let newItemName = oldItemName.replacingOccurrences(of: oldName, with: newName)
                let directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
                let newPath = directoryURL.appendingPathComponent(newItemName).path
                try fileManager.moveItem(atPath: path, toPath: newPath)
                print("-- Renamed: \(oldItemName) -> \(newItemName)")
            }
        } catch {
            print("Error renaming file: \(error.localizedDescription)")
        }
    }
}

let arguments = CommandLine.arguments
if arguments.count == 3 {
    let oldName = arguments[1]
    let newName = arguments[2].replacingOccurrences(of: " ", with: "")
    let renamer = Renamer(oldName: oldName, newName: newName)
    renamer.run()
} else {
    print("Invalid number of arguments! Expected OLD and NEW project name.")
}
