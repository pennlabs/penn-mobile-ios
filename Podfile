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

pod 'OneTimePassword', '~> 3.2'

    target 'AutomatedScreenshotUITests' do
        inherit! :search_paths
        # Pods for testing
        pod 'SimulatorStatusMagic'
    end

end
