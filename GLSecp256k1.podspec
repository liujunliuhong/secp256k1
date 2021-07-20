Pod::Spec.new do |s|
    s.name                       = 'GLSecp256k1'
    s.homepage                   = 'https://github.com/UnExVirgo/secp256k1'
    s.summary                    = 'secp256k1, support pod'
    s.description                = 'secp256k1, support pod.'
    s.author                     = { 'liujunliuhong' => '1035841713@qq.com' }
    s.version                    = '1.0.0'
    s.source                     = { :git => 'https://github.com/UnExVirgo/secp256k1.git', :tag => s.version.to_s }
    s.platform                   = :ios, '10.0'
    s.license                    = { :type => 'MIT', :file => 'LICENSE' }
    s.module_name                = 'GLSecp256k1'
    s.swift_version              = '5.0'
    s.ios.deployment_target      = '10.0'
    s.requires_arc               = true
    s.static_framework           = true
    s.vendored_libraries         = 'Sources/*.a'
    s.source_files               = 'Sources/*.h'
    s.public_header_files        = 'Sources/*.h'
  end