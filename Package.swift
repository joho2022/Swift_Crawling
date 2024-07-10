// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift_Crawling",
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.2"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1"))
    ],
    targets: [
        .executableTarget(
            name: "Swift_Crawling",
            dependencies: [
                "SwiftSoup",
                "Alamofire"
            ],
            path: "Sources"
        )
    ]
)
