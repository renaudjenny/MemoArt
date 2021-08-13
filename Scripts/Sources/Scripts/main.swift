import Foundation
import MarketingScreenshots

try MarketingScreenshots.iOS(
    devices: [
        .iPhoneSE_1st_Generation,
        .iPhone8Plus,
        .iPhoneSE_2nd_Generation,
        .iPhone12Pro,
        .iPhone12ProMax,

        .iPadPro_97,
        .iPadPro_129_2nd_Generation,
        .iPadPro_110_1st_Generation,
        .iPadPro_129_4th_Generation,
    ],
    projectName: "MemoArt (iOS)"
)

try MarketingScreenshots.macOS(projectName: "MemoArt (macOS)")
