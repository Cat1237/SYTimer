
Pod::Spec.new do |spec|
  spec.name         = 'SYTimer'
  spec.version      = '0.1.6'
  spec.license      =  { :type => 'MIT',  }
  spec.homepage     = 'https://github.com/wangson1237/SYTimer'
  spec.authors      = { 'Wangson1237' => 'wangson1237@outlook.com'}
  spec.summary      = 'Base on CFRunLoop Timer for iOS.'
  spec.source       = { :git => 'https://github.com/wangson1237/SYTimer.git', :tag => spec.version.to_s }
  spec.module_name  = 'SYTimer'
  spec.header_dir   = 'SYTimer'

  spec.ios.deployment_target = '10.0'

  # Subspecs
  spec.subspec 'Core' do |core|
    core.compiler_flags = '-fno-exceptions -Wno-implicit-retain-self'
    core.public_header_files = [
      'Source/*.h'
    ]
    
    core.source_files = [
      'Source/**/*.{h,mm}'
    ]
  end

  # Include these by default for backwards compatibility.
  spec.default_subspecs = 'Core'

  spec.library = 'c++'
  spec.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
   }
   
end
