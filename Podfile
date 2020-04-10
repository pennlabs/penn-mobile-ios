# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PennMobile' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for PennMobile

pod 'MBProgressHUD', '~> 0.8' # old objc library, should be replaced

pod 'Fabric', '~> 1.10.2' # Required by Firebase.
pod 'Crashlytics', '~> 3.14.0' # Required by Firebase.
pod 'Firebase', '~> 4.7' # Firebase not yet supported by SPM. May be a while.

pod 'XLPagerTabStrip', '~> 9.0' # Only used for GSR, should be deleted

# WKZombie should be moved to SPM eventually, but something is broken with the current SPM implementation
pod 'WKZombie', :git => 'https://github.com/pennlabs/WKZombie.git', :commit => '536f6e8aa0e8438fe711fff6420908bc67edb056'
pod 'OneTimePassword', '~> 3.2'

    target 'AutomatedScreenshotUITests' do
        inherit! :search_paths
        # Pods for testing
        pod 'SimulatorStatusMagic'
    end

end
