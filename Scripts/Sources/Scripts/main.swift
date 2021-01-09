print("Run Marketing screenshots generation...")

let macOSTest = shell(command: .xcodebuild, arguments: ["clean", "test", "-scheme", "Memo Art (macOS)"])

print(macOSTest.output ?? "Error")
