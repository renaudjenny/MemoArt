import Foundation
import MarketingScreenshots

try MarketingScreenshots.run(
    devices: [
        .iPhone12ProMax,
        .iPhone12Pro,
        .iPhone8Plus,
        .iPhoneSE_2nd_Generation,
        .iPhoneSE_1st_Generation,

        .iPadPro_129_4th_Generation,
        .iPadPro_129_2nd_Generation,
        .iPadPro_110_1st_Generation,
        .iPadPro_97,

         .mac
    ],
    iOSProjectName: "MemoArt (iOS)",
    macProjectName: "MemoArt (macOS)"
)
