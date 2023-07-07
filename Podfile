require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

source 'https://cdn.cocoapods.org/'
platform :ios, '15.0'

inhibit_all_warnings!

target 'Mastodon' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Mastodon
  config = use_native_modules!

  # Flags change depending on the env values.
  flags = get_default_flags()

  use_react_native!(
    :path => config[:reactNativePath],
    # Hermes is now enabled by default. Disable by setting this flag to false.
    # Upcoming versions of React Native may rely on get_default_flags(), but
    # we make it explicit here to aid in the React Native upgrade process.
    :hermes_enabled => flags[:hermes_enabled],
    :fabric_enabled => flags[:fabric_enabled],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  # UI
  pod 'XLPagerTabStrip', '~> 9.0.0'

  # misc
  pod 'SwiftGen', '~> 6.6.2'
  pod 'Kanna', '~> 5.2.2'
  pod 'Sourcery', '~> 1.9'

  # DEBUG
  pod 'FLEX', '~> 5.22.10', :configurations => ['Debug', "Release Snapshot"]
  
  target 'MastodonTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MastodonUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  react_native_post_install(
    installer,
    # Set `mac_catalyst_enabled` to `true` in order to apply patches
    # necessary for Mac Catalyst builds
    :mac_catalyst_enabled => false
  )
  __apply_Xcode_12_5_M1_post_install_workaround(installer)
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
    # https://github.com/CocoaPods/CocoaPods/issues/11402#issuecomment-1201464693
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
