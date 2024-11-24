// Run with "swift install.swift" command
import Foundation

let destinationFolder = "Library/Developer/Xcode/Templates/File Templates/Source"
let homeDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
let destinationFolderURL = homeDirectoryURL.appendingPathComponent(destinationFolder)

func install() {
  
  let fileManager = FileManager.default
  let currentPath = fileManager.currentDirectoryPath

  do {
      let files = try fileManager.contentsOfDirectory(atPath: currentPath)
      for file in files {
        if file == "install.swift" || file == ".DS_Store" {
          continue
        }
        let template = file
        let templateURL = URL(fileURLWithPath: template)
        let destinationFileURL = destinationFolderURL.appendingPathComponent(template)

        if FileManager.default.fileExists(atPath: destinationFileURL.path) {
            try FileManager.default.removeItem(at: destinationFileURL)
            try FileManager.default.copyItem(at: templateURL, to: destinationFileURL)
            print("✅ Template already exists. So has been replaced successfully 🎉.")
        } else {
            if FileManager.default.fileExists(atPath: destinationFolderURL.path) == false {
                try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            try FileManager.default.copyItem(at: templateURL, to: destinationFileURL)
            print("✅ Template installed successfully 🎉.")
        }
      }
  } catch {
    print("❌ Ooops! Something went wrong.")
  }
}

install()
