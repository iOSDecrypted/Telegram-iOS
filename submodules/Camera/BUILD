load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load(
    "@build_bazel_rules_apple//apple:resources.bzl",
    "apple_resource_bundle",
    "apple_resource_group",
)
load("//build-system/bazel-utils:plist_fragment.bzl",
    "plist_fragment",
)

sgDeps = [
    "//Swiftgram/SGSimpleSettings:SGSimpleSettings"
]

filegroup(
    name = "CameraMetalResources",
    srcs = glob([
        "MetalResources/**/*.*",
    ]),
    visibility = ["//visibility:public"],
)

plist_fragment(
    name = "CameraBundleInfoPlist",
    extension = "plist",
    template =
    """
    <key>CFBundleIdentifier</key>
    <string>org.telegram.Camera</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleName</key>
    <string>Camera</string>
    """
)

apple_resource_bundle(
    name = "CameraBundle",
    infoplists = [
        ":CameraBundleInfoPlist",
    ],
    resources = [
        ":CameraMetalResources",
    ],
)

swift_library(
    name = "Camera",
    module_name = "Camera",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    data = [
        ":CameraBundle",
    ],
    deps = sgDeps + [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/Display:Display",
        "//submodules/ImageBlur:ImageBlur",
        "//submodules/TelegramCore:TelegramCore",
        "//submodules/Utils/DeviceModel",
        "//submodules/rlottie:RLottieBinding",
        "//submodules/AppBundle",
        "//submodules/GZip",
    ],
    visibility = [
        "//visibility:public",
    ],
)
