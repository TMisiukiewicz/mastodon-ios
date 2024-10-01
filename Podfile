require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

source 'https://cdn.cocoapods.org/'
platform :ios, '15.1'

inhibit_all_warnings!

config = nil

target 'Mastodon' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Mastodon
  config = use_native_modules!

  puts "config: #{config}"

  use_react_native!(
    :path => config[:reactNativePath],
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
    config[:reactNativePath],
      :mac_catalyst_enabled => false,
      # :ccache_enabled => true
  )
  
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
