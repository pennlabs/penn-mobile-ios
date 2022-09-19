# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

inhibit_all_warnings!

target 'PennMobile' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for PennMobile

pod 'SCLAlertView'
pod 'ScrollableGraphView'

pod 'XLPagerTabStrip', '~> 9.0' # Only used for GSR, should be deleted
pod 'SwiftLint'

end

target 'AutomatedScreenshotUITests' do
    #inherit! :search_paths
    # Pods for testing
    pod 'SimulatorStatusMagic'
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      end
    end
end
