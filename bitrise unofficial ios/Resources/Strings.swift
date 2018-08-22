// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {
  /// Bitrise User
  internal static let bitriseUser = L10n.tr("Localizable", "bitriseUser")
  /// 'Branch' parameter is empty. Branch is required for starting a build
  internal static let branchParamRequired = L10n.tr("Localizable", "branchParamRequired")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// Please check that required fields are filled in, and that Branch, Workflow and Commit Message fields contain valid strings.
  internal static let checkBuildParamsMsg = L10n.tr("Localizable", "checkBuildParamsMsg")
  /// Dismiss
  internal static let dismiss = L10n.tr("Localizable", "dismiss")
  /// Invalid Parameters
  internal static let invalidParams = L10n.tr("Localizable", "invalidParams")
  /// Log In
  internal static let logIn = L10n.tr("Localizable", "logIn")
  /// Log Out
  internal static let logOut = L10n.tr("Localizable", "logOut")
  /// Are you sure you want to log out? You may need to generate a new access token next time you wish to use the app.
  internal static let logOutConfirmationMsg = L10n.tr("Localizable", "logOutConfirmationMsg")
  /// User doesn't belong to any organizations
  internal static let noOrganizations = L10n.tr("Localizable", "noOrganizations")
  /// No token saved in keychain
  internal static let noTokenInKeychain = L10n.tr("Localizable", "noTokenInKeychain")
  /// Profile
  internal static let profile = L10n.tr("Localizable", "profile")
  /// Projects
  internal static let projects = L10n.tr("Localizable", "projects")
  /// Showing all apps
  internal static let showingAllApps = L10n.tr("Localizable", "showingAllApps")
  /// Start Build
  internal static let startBuild = L10n.tr("Localizable", "startBuild")
  /// Bitrise YML isn't available for this application
  internal static let ymlUnavailable = L10n.tr("Localizable", "ymlUnavailable")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
