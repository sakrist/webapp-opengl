// swift-tools-version:6.0
import PackageDescription

let shouldBuildForEmbedded =
    Context.environment["JAVASCRIPTKIT_EXPERIMENTAL_EMBEDDED_WASM"].flatMap(Bool.init) ?? false

let extraDependencies: [Target.Dependency] = shouldBuildForEmbedded
    ? [.product(name: "dlmalloc", package: "swift-dlmalloc")]
    : []

let package = Package(
    name: "Embedded",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/swift-dlmalloc", from: "0.1.0"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", branch: "main"),
        .package(path: "../emswiften")
    ],
    targets: [
        .executableTarget(
            name: "EmbeddedApp",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "emswiften", package: "emswiften"), 
            ] + extraDependencies,
            cSettings: [.unsafeFlags(["-fdeclspec"])],
            swiftSettings: shouldBuildForEmbedded ? [
                .enableExperimentalFeature("Embedded"),
                .enableExperimentalFeature("Extern"),
                .unsafeFlags([
                    "-Xfrontend", "-gnone",
                    "-Xfrontend", "-disable-stack-protector",
                ]),
            ] : nil,
            linkerSettings: shouldBuildForEmbedded ? [
                .unsafeFlags([
                    "-Xclang-linker", "-nostdlib",
                    "-Xlinker", "--no-entry",
                    "-Xlinker", "--export-if-defined=__main_argc_argv",
                    "-Xlinker", "--export-if-defined=_swjs_library_features",
                    "-Xlinker", "--export-if-defined=_swjs_call_host_function",
                    "-Xlinker", "--export-if-defined=_swjs_free_host_function",
                ]),
            ] : nil
        ),
    ],
    swiftLanguageModes: [.v5]
)
