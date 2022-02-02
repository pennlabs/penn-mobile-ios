# Uncomment the next line to define a global platform for your project
#platform :ios

inhibit_all_warnings!

target 'PennMobile' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for PennMobile

pod 'MBProgressHUD', '~> 0.8' # old objc library, should be replaced
pod 'SCLAlertView'
pod 'ScrollableGraphView'

pod 'XLPagerTabStrip', '~> 9.0' # Only used for GSR, should be deleted
pod 'SwiftLint'

# WKZombie should be moved to SPM eventually, but something is broken with the current SPM implementation
#pod 'WKZombie', :git => 'https://github.com/pennlabs/WKZombie.git', :commit => '536f6e8aa0e8438fe711fff6420908bc67edb056'
pod 'OneTimePassword', '~> 3.2'

    target 'AutomatedScreenshotUITests' do
        inherit! :search_paths
        # Pods for testing
        pod 'SimulatorStatusMagic'
    end

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      end
    end
end
