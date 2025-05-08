require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# TargetsToChangeToDynamic = ['MapboxMobileEvents']
TargetsToChangeToDynamic = []

rnMapboxMapsDefaultMapboxVersion = '~> 11.8.0'
$RNMBNAV = Object.new

def $RNMBNAV.post_install(installer)
  installer.pod_targets.each do |pod|
    if TargetsToChangeToDynamic.include?(pod.name)
      if pod.send(:build_type) != Pod::BuildType.dynamic_framework
        pod.instance_variable_set(:@build_type,Pod::BuildType.dynamic_framework)
        puts "* Changed #{pod.name} to `#{pod.send(:build_type)}`"
        fail "Unable to change build_type" unless mobile_events_target.send(:build_type) == Pod::BuildType.dynamic_framework
      end
    end
  end
end

def $RNMBNAV.pre_install(installer)
  installer.aggregate_targets.each do |target|
    target.pod_targets.select { |p| TargetsToChangeToDynamic.include?(p.name) }.each do |mobile_events_target|
      mobile_events_target.instance_variable_set(:@build_type,Pod::BuildType.dynamic_framework)
      puts "* Changed #{mobile_events_target.name} to #{mobile_events_target.send(:build_type)}"
      fail "Unable to change build_type" unless mobile_events_target.send(:build_type) == Pod::BuildType.dynamic_framework
    end
  end
end

Pod::Spec.new do |s|
  s.name         = "react-native-mapbox-navigation"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  Smart Mapbox turn-by-turn routing based on real-time traffic for React Native.
                   DESC
  s.homepage     = "https://github.com/homeeondemand/react-native-mapbox-navigation"
  s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "HOMEE" => "support@homee.com" }
  s.platforms    = { :ios => "14.0" }
  s.source       = { :git => "https://github.com/homeeondemand/react-native-mapbox-navigation.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  # Core React Native dependencies
  s.dependency "React-Core"
  s.dependency "React-RCTFabric"
  s.dependency "React-FabricComponents"
  
  # Additional React Native dependencies
  s.dependency "React-Core/DevSupport"
  s.dependency "React-Core/RCTWebSocket"
  s.dependency "React-RCTActionSheet"
  s.dependency "React-RCTAnimation"
  s.dependency "React-RCTBlob"
  s.dependency "React-RCTImage"
  s.dependency "React-RCTLinking"
  s.dependency "React-RCTNetwork"
  s.dependency "React-RCTSettings"
  s.dependency "React-RCTText"
  s.dependency "React-RCTVibration"
  
  # React Native new architecture dependencies
  s.dependency "React-Core/Default"
  s.dependency "React-cxxreact"
  s.dependency "React-jsi"
  s.dependency "React-jsiexecutor"
  s.dependency "React-jsinspector"
  s.dependency "React-callinvoker"
  s.dependency "React-runtimeexecutor"
  s.dependency "React-perflogger"
  s.dependency "React-logger"
  s.dependency "ReactCommon/turbomodule/core"
  s.dependency "Yoga"
  s.dependency "DoubleConversion"
  s.dependency "glog"
  s.dependency "RCT-Folly"
  s.dependency "boost"

  spm_dependency(
    s,
    url: 'https://github.com/mapbox/mapbox-navigation-ios.git',
    requirement: { kind: 'exactVersion', version: '3.5.0' },
    products: ['MapboxNavigationCore', 'MapboxNavigationUIKit']
  )
end

