// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
internal typealias AssetType = ImageAsset

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {

    // swiftlint:disable trailing_comma
    internal static let allColors: [ColorAsset] = [
    ]
    internal static let allImages: [ImageAsset] = [
    ]
    // swiftlint:enable trailing_comma
    @available(*, deprecated, renamed: "allImages")
    internal static let allValues: [AssetType] = allImages
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

    // swiftlint:disable trailing_comma
    internal static let allColors: [ColorAsset] = [
      bitriseGreen,
      bitriseGrey,
      bitriseOrange,
      bitrisePurple,
      bitriseYellow,
      canaryYellow,
      fieldGreen,
      lightBlue,
      lushPurple,
      saladGreen,
      testViewFill,
    ]
    internal static let allImages: [ImageAsset] = [
    ]
    // swiftlint:enable trailing_comma
    @available(*, deprecated, renamed: "allImages")
    internal static let allValues: [AssetType] = allImages
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
    internal static let buildAborted = ImageAsset(name: "build_aborted")
    internal static let buildFailed = ImageAsset(name: "build_failed")
    internal static let buildRunning = ImageAsset(name: "build_running")
    internal static let buildSucceeded = ImageAsset(name: "build_succeeded")
    internal static let close = ImageAsset(name: "close")
    internal static let projects = ImageAsset(name: "projects")
    internal static let providerBitbucket = ImageAsset(name: "provider_bitbucket")
    internal static let providerGithub = ImageAsset(name: "provider_github")
    internal static let providerGitlab = ImageAsset(name: "provider_gitlab")
    internal static let user = ImageAsset(name: "user")

    // swiftlint:disable trailing_comma
    internal static let allColors: [ColorAsset] = [
    ]
    internal static let allImages: [ImageAsset] = [
      applicationAndroid,
      applicationAndroidGrey,
      applicationDefault,
      applicationIos,
      applicationIosColor,
      applicationIosGrey,
      applicationReactGrey,
      applicationXamarin,
      applicationXamarinGrey,
      buildAborted,
      buildFailed,
      buildRunning,
      buildSucceeded,
      close,
      projects,
      providerBitbucket,
      providerGithub,
      providerGitlab,
      user,
    ]
    // swiftlint:enable trailing_comma
    @available(*, deprecated, renamed: "allImages")
    internal static let allValues: [AssetType] = allImages
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

internal extension Image {
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

private final class BundleToken {}
