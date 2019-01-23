// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Acknowledgements
  internal static let acknowledgements = L10n.tr("Localizable", "acknowledgements")
  /// ago
  internal static let ago = L10n.tr("Localizable", "ago")
  /// Bitrise User
  internal static let bitriseUser = L10n.tr("Localizable", "bitriseUser")
  /// 'Branch' parameter is empty. Branch is required for starting a build
  internal static let branchParamRequired = L10n.tr("Localizable", "branchParamRequired")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// Please check that required fields are filled in, and that Branch, Workflow and Commit Message fields contain valid strings.
  internal static let checkBuildParamsMsg = L10n.tr("Localizable", "checkBuildParamsMsg")
  /// d
  internal static let d = L10n.tr("Localizable", "d")
  /// days
  internal static let days = L10n.tr("Localizable", "days")
  /// Delete
  internal static let deletePasscodeCharacter = L10n.tr("Localizable", "deletePasscodeCharacter")
  /// Dismiss
  internal static let dismiss = L10n.tr("Localizable", "dismiss")
  /// Enter Current Passcode
  internal static let enterCurrentPasscode = L10n.tr("Localizable", "enterCurrentPasscode")
  /// Enter New Passcode
  internal static let enterNewPasscode = L10n.tr("Localizable", "enterNewPasscode")
  /// Enter your passcode
  internal static let enterYourPasscode = L10n.tr("Localizable", "enterYourPasscode")
  /// Find your project by name
  internal static let filterByProjectTitle = L10n.tr("Localizable", "filterByProjectTitle")
  /// hours
  internal static let hours = L10n.tr("Localizable", "hours")
  /// hr
  internal static let hr = L10n.tr("Localizable", "hr")
  /// hrs
  internal static let hrs = L10n.tr("Localizable", "hrs")
  /// Invalid Parameters
  internal static let invalidParams = L10n.tr("Localizable", "invalidParams")
  /// Invalid Passcode
  internal static let invalidPasscode = L10n.tr("Localizable", "invalidPasscode")
  /// Log In
  internal static let logIn = L10n.tr("Localizable", "logIn")
  /// Log Out
  internal static let logOut = L10n.tr("Localizable", "logOut")
  /// Are you sure you want to log out? You may need to generate a new access token next time you wish to use the app.
  internal static let logOutConfirmationMsg = L10n.tr("Localizable", "logOutConfirmationMsg")
  /// min
  internal static let min = L10n.tr("Localizable", "min")
  /// mins
  internal static let mins = L10n.tr("Localizable", "mins")
  /// minute
  internal static let minute = L10n.tr("Localizable", "minute")
  /// minutes
  internal static let minutes = L10n.tr("Localizable", "minutes")
  /// months
  internal static let months = L10n.tr("Localizable", "months")
  /// mth
  internal static let mth = L10n.tr("Localizable", "mth")
  /// mths
  internal static let mths = L10n.tr("Localizable", "mths")
  /// Passcodes do not match
  internal static let noMatchPasscode = L10n.tr("Localizable", "noMatchPasscode")
  /// You aren't part of any teams
  internal static let noOrganizations = L10n.tr("Localizable", "noOrganizations")
  /// No token saved in keychain
  internal static let noTokenInKeychain = L10n.tr("Localizable", "noTokenInKeychain")
  /// App property wasn't initialised in view controller. This property must be populated with a valid Bitrise App to allow posting new builds
  internal static let nullAppProperty = L10n.tr("Localizable", "nullAppProperty")
  /// Profile
  internal static let profile = L10n.tr("Localizable", "profile")
  /// Projects
  internal static let projects = L10n.tr("Localizable", "projects")
  /// Re-enter New Passcode
  internal static let reenterNewPasscode = L10n.tr("Localizable", "reenterNewPasscode")
  /// Reset passcode
  internal static let resetPasscode = L10n.tr("Localizable", "resetPasscode")
  /// Save
  internal static let save = L10n.tr("Localizable", "save")
  /// seconds
  internal static let seconds = L10n.tr("Localizable", "seconds")
  /// Set passcode grace period
  internal static let setGracePeriod = L10n.tr("Localizable", "setGracePeriod")
  /// Settings & Preferences
  internal static let settingsTitle = L10n.tr("Localizable", "settingsTitle")
  /// Settings
  internal static let settingsTitleShort = L10n.tr("Localizable", "settingsTitleShort")
  /// Showing all apps
  internal static let showingAllApps = L10n.tr("Localizable", "showingAllApps")
  /// Start Build
  internal static let startBuild = L10n.tr("Localizable", "startBuild")
  /// Unauthorized user
  internal static let unauthorizedUser = L10n.tr("Localizable", "unauthorizedUser")
  /// Value of 'enteredToken' isn't equal to text field value:
  internal static let unequalTokenInAuthTF = L10n.tr("Localizable", "unequalTokenInAuthTF")
  /// Unlock with Touch ID or Face ID
  internal static let unlockWithBio = L10n.tr("Localizable", "unlockWithBio")
  /// Unlock with passcode
  internal static let unlockWithPasscode = L10n.tr("Localizable", "unlockWithPasscode")
  /// You are part of the following teams:
  internal static let userTeamsHeader = L10n.tr("Localizable", "userTeamsHeader")
  /// weeks
  internal static let weeks = L10n.tr("Localizable", "weeks")
  /// Welcome,
  internal static let welcome = L10n.tr("Localizable", "welcome")
  /// wk
  internal static let wk = L10n.tr("Localizable", "wk")
  /// wks
  internal static let wks = L10n.tr("Localizable", "wks")
  /// years
  internal static let years = L10n.tr("Localizable", "years")
  /// Bitrise YML isn't available for this application
  internal static let ymlUnavailable = L10n.tr("Localizable", "ymlUnavailable")
  /// yr
  internal static let yr = L10n.tr("Localizable", "yr")
  /// yrs
  internal static let yrs = L10n.tr("Localizable", "yrs")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
