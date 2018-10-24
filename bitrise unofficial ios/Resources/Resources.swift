// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let launchScreen = ImageAsset(name: "LaunchScreen")
  }
  internal enum Colors {
    internal static let bitriseGreen = ColorAsset(name: "BitriseGreen")
    internal static let bitriseGrey = ColorAsset(name: "BitriseGrey")
    internal static let bitriseOrange = ColorAsset(name: "BitriseOrange")
    internal static let bitrisePurple = ColorAsset(name: "BitrisePurple")
    internal static let bitriseYellow = ColorAsset(name: "BitriseYellow")
    internal static let canaryYellow = ColorAsset(name: "CanaryYellow")
    internal static let fieldGreen = ColorAsset(name: "FieldGreen")
    internal static let lightBlue = ColorAsset(name: "LightBlue")
    internal static let lushPurple = ColorAsset(name: "LushPurple")
    internal static let saladGreen = ColorAsset(name: "SaladGreen")
    internal static let testViewFill = ColorAsset(name: "TestViewFill")
  }
  internal enum Icons {
    internal static let applicationAndroid = ImageAsset(name: "application_android")
    internal static let applicationAndroidGrey = ImageAsset(name: "application_android_grey")
    internal static let applicationDefault = ImageAsset(name: "application_default")
    internal static let applicationIos = ImageAsset(name: "application_ios")
    internal static let applicationIosColor = ImageAsset(name: "application_ios_color")
    internal static let applicationIosGrey = ImageAsset(name: "application_ios_grey")
    internal static let applicationReactGrey = ImageAsset(name: "application_react_grey")
    internal static let applicationXamarin = ImageAsset(name: "application_xamarin")
    internal static let applicationXamarinGrey = ImageAsset(name: "application_xamarin_grey")
    internal static let branch = ImageAsset(name: "branch")
    internal static let buildAborted = ImageAsset(name: "build_aborted")
    internal static let buildAbortedWhite = ImageAsset(name: "build_aborted_white")
    internal static let buildFailed = ImageAsset(name: "build_failed")
    internal static let buildFailedWhite = ImageAsset(name: "build_failed_white")
    internal static let buildRunning = ImageAsset(name: "build_running")
    internal static let buildRunningWhite = ImageAsset(name: "build_running_white")
    internal static let buildSucceeded = ImageAsset(name: "build_succeeded")
    internal static let buildSucceededWhite = ImageAsset(name: "build_succeeded_white")
    internal static let chevron = ImageAsset(name: "chevron")
    internal static let clock = ImageAsset(name: "clock")
    internal static let close = ImageAsset(name: "close")
    internal static let log = ImageAsset(name: "log")
    internal static let message = ImageAsset(name: "message")
    internal static let projects = ImageAsset(name: "projects")
    internal static let providerBitbucket = ImageAsset(name: "provider_bitbucket")
    internal static let providerGithub = ImageAsset(name: "provider_github")
    internal static let providerGitlab = ImageAsset(name: "provider_gitlab")
    internal static let `repeat` = ImageAsset(name: "repeat")
    internal static let user = ImageAsset(name: "user")
    internal static let userLrg = ImageAsset(name: "user_lrg")
    internal static let workflow = ImageAsset(name: "workflow")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
