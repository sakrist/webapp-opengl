// swift-tools-version:6.0
import PackageDescription

let shouldBuildForEmbedded =
    Context.environment["JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM"].flatMap(Bool.init) ?? false

let targetDependencies: [Target.Dependency] = shouldBuildForEmbedded
    ? [.product(name: "dlmalloc", package: "swift-dlmalloc"),
       .product(name: "emswiften", package: "emswiften"), ]
    : []

let dependencies: [Package.Dependency] = shouldBuildForEmbedded
    ? [ .package(url: "https://github.com/swiftwasm/swift-dlmalloc", from: "0.1.0"),
        .package(url: "https://github.com/sakrist/emswiften", branch: "main"),
    ] : []

let swiftSettings: [SwiftSetting] = shouldBuildForEmbedded ? [
                .enableExperimentalFeature("Embedded"),
                .enableExperimentalFeature("Extern"),
                .unsafeFlags([
                    "-Xfrontend", "-gnone",
                    "-Xfrontend", "-disable-stack-protector",
                ]),
            ] : []

let linkerSettings: [LinkerSetting] = shouldBuildForEmbedded ? [
                .unsafeFlags([
                    "-Xclang-linker", "-nostdlib",
                    "-Xlinker", "--no-entry",
                    "-Xlinker", "--export-if-defined=__main_argc_argv",
                    "-Xlinker", "--export-if-defined=_swjs_library_features",
                    "-Xlinker", "--export-if-defined=_swjs_call_host_function",
                    "-Xlinker", "--export-if-defined=_swjs_free_host_function",
                ]),
            ] : []

let package = Package(
    name: "Embedded",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", branch: "main"),
        .package(url: "https://github.com/sakrist/SwiftMath", branch: "feature/wasm-embedded-emsdk"),
    ] + dependencies,
    targets: [
        .executableTarget(
            name: "EmbeddedApp",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                "SwiftMath",
            ] + targetDependencies,
            cSettings: [.unsafeFlags(["-fdeclspec"])],
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        ),
    ],
    swiftLanguageModes: [.v5]
)
