// Set the list of devices you want screenshot to be taken on
let devicesName = [
    "iPhone 12 Pro Max"
]

// Help you generate & find generated screenshots
// See https://rderik.com/blog/understanding-xcuitest-screenshots-and-how-to-access-them/
let derivedDataPath = "/tmp/DerivedDataMarketing"

print("Run Marketing screenshots generation...")
for deviceName in devicesName {
    print("Currently running on Simulator named: \(deviceName)")

    let iOSMarketingTestPlan = shell(command: .xcodebuild, arguments: [
        "test",
        "-scheme", "MemoArt (iOS)",
        "-destination", "platform=iOS Simulator,name=\(deviceName)",
        "-derivedDataPath", derivedDataPath,
        "-testPlan", "Marketing",
    ])

    // LATEST_XCRESULTS=`plutil -extract logs xml1 -o - ${DERIVED_DATA_PATH}/Logs/Test/LogStoreManifest.plist | xmllint --xpath 'string(//dict[1]/string[contains(text(),"xcresult")])' -`

    let plutilExtractLogs = shell(command: .plutil, arguments: [
        "-extract", "logs", "xml1",
        "-o", "-", "\(derivedDataPath)/Logs/Test/LogStoreManifest.plist"
    ])

    guard
        plutilExtractLogs.status == 0,
        let plutilExtractLogsOutput = plutilExtractLogs.output
    else {
        print("plutil finished with errors")
        print(plutilExtractLogs.output ?? "Cannot print errors...")
        continue
    }

    let xmllint = shell(command: .xmllint, arguments: [
        "--xpath",
        "string(//dict[1]/string[contains(text(),\"xcresult\")])",
        plutilExtractLogsOutput
    ])

    guard
        xmllint.status == 0,
        let xmllintOutput = xmllint.output
    else {
        print("xmllint finished with errors")
        print(xmllint.output ?? "Cannot print errors...")
        continue
    }

    print(xmllintOutput)
}
