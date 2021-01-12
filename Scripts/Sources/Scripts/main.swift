import Foundation
import XCResultKit

// Set the list of devices you want screenshot to be taken on
let devicesName = [
//    "iPhone 12 Pro Max",
    "iPhone 8 Plus",
]

let derivedDataPath = "/tmp/DerivedDataMarketing"
let exportFolder = "/tmp/ExportedScreenshots"

guard shell(command: .mkdir, arguments: ["-p", exportFolder]).status == 0
else {
    throw ScriptError.commandFailed("mkdir failed to create the folder \(exportFolder)")
}

print("📺 Starting generating Marketing screenshots...")
for deviceName in devicesName {
    print("📱 Currently running on Simulator named: \(deviceName)")
    print("     👷‍♀️ Generation of screenshots for \(deviceName) via test plan in progress")
    print("     🐢 This usually takes some time...")

    let iOSMarketingTestPlan = shell(command: .xcodebuild, arguments: [
        "test",
        "-scheme", "MemoArt (iOS)",
        "-destination", "platform=iOS Simulator,name=\(deviceName)",
        "-derivedDataPath", derivedDataPath,
        "-testPlan", "Marketing",
    ])

    guard iOSMarketingTestPlan.status == 0 else {
        print("Marketing UITests failed with errors")
        print(iOSMarketingTestPlan.output ?? "Cannot print xcodebuild errors...")
        continue
    }
    print("     ✅ Generation of screenshots for \(deviceName) via test plan done")

    print("     👷‍♀️ Extraction and renaming of screenshots for \(deviceName) in progress")

    let path = "\(derivedDataPath)/Logs/Test/LogStoreManifest.plist"

    guard let manifestPlist = try? String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
    else {
        print("Error, cannot read manifest Plist for this path: \(path)")
        continue
    }

    guard let extractXCResultFileRegExp = try? NSRegularExpression(
        pattern: "<key>fileName</key>.*?<string>(.*?)</string>",
        options: NSRegularExpression.Options.dotMatchesLineSeparators
    )
    else {
        print("Error, cannot build the regular expression to extract the XCResult file")
        continue
    }

    let range = NSRange(location: 0, length: manifestPlist.utf16.count)
    let xcresultFileNames: [String] = extractXCResultFileRegExp.matches(in: manifestPlist, options: [], range: range).flatMap { match in
        (1..<match.numberOfRanges).map { rangeIndex in
            let captureRange = match.range(at: rangeIndex)
            let lowerIndex = manifestPlist.utf16.index(manifestPlist.startIndex, offsetBy: captureRange.lowerBound)
            let upperIndex = manifestPlist.utf16.index(manifestPlist.startIndex, offsetBy: captureRange.upperBound)
            return String(manifestPlist.utf16[lowerIndex..<upperIndex]) ?? "Error"
        }
    }

    guard let lastXCResultFileName = xcresultFileNames.last
    else {
        print("Error, no XCResult file found!")
        continue
    }
    let lastXCResultFileNameURL = URL(fileURLWithPath: "\(derivedDataPath)/Logs/Test/\(lastXCResultFileName)")
    let result = XCResultFile(url: lastXCResultFileNameURL)

    guard let testPlanRunSummariesId = result.getInvocationRecord()?.actions.first?.actionResult.testsRef?.id
    else {
        print("Error, no TestPlan found!")
        continue
    }
    for summary in result.getTestPlanRunSummaries(id: testPlanRunSummariesId)?.summaries ?? [] {
        print("         ⛏ extraction for the configuration \(summary.name) in progress")
        for test in summary.testableSummaries.first?.tests.first?.subtestGroups.first?.subtestGroups.first?.subtests ?? [] {
            let normalizedTestName = test.name
                .replacingOccurrences(of: "test", with: "")
                .replacingOccurrences(of: "Screenshot()", with: "")
            print("             👉 extraction of \(normalizedTestName) in progress")

            guard let summaryId = test.summaryRef?.id
            else {
                print("Error, cannot get summary id from \(summary.name) for \(test.name)")
                continue
            }

            guard let payloadId = result.getActionTestSummary(id: summaryId)?
                    .activitySummaries.first(where: { $0.activityType == "com.apple.dt.xctest.activity-type.attachmentContainer" })?
                    .attachments.first?.payloadRef?.id
            else {
                print("Error, cannot get payload id from \(summary.name) for \(test.name)")
                continue
            }

            guard let screenshotData = result.getPayload(id: payloadId)
            else {
                print("Error, cannot get data from the screenshot of \(summary.name) for \(test.name)")
                continue
            }

            do {
                let path = "\(exportFolder)/Screenshot \(deviceName) \(summary.name) \(normalizedTestName).png"
                try screenshotData.write(to: URL(fileURLWithPath: path))
                print("              📸 \(normalizedTestName) is available here: \(path)")
            } catch {
                print("Error, can't export the file correctly: \(error)")
            }
        }
    }
}

guard shell(command: .open, arguments: [exportFolder]).status == 0
else {
    throw ScriptError.commandFailed("Error, cannot open the folder \(exportFolder) automatically")
}
