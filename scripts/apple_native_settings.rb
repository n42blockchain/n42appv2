# Shared by Apple Podfiles; preserve newer target floors and sqlite3 FFI symbols.
require 'json'
require 'uri'
require 'rubygems'

module N42AppleNative
  def self.deployment_floor(current, minimum)
    return minimum if current.nil? || current.empty?
    [Gem::Version.new(current), Gem::Version.new(minimum)].max.to_s
  end

  def self.append_link_flags(existing, additions)
    existing + additions.reject { |flag| existing.include?(flag) }.uniq
  end

  def self.sqlite_link_flags(app_root)
    config_path = File.join(app_root, '.dart_tool', 'package_config.json')
    config = JSON.parse(File.read(config_path))
    sqlite = config.fetch('packages').find { |package| package.fetch('name') == 'sqlite3' }
    raise 'sqlite3 must be resolved before pod install' unless sqlite
    root_uri = URI.parse(sqlite.fetch('rootUri'))
    unless root_uri.scheme.nil? || root_uri.scheme == 'file'
      raise "sqlite3 package root must use a local file URI: #{root_uri.scheme}"
    end
    decoded_path = URI::DEFAULT_PARSER.unescape(root_uri.path)
    root = File.expand_path(decoded_path, File.dirname(config_path))
    symbols_path = File.join(root, 'lib/src/hook/compile/used_symbols.dart')
    symbols = File.read(symbols_path).scan(/'(sqlite3\w+)'/).flatten
    raise 'sqlite3 binding symbol inventory is empty' if symbols.empty?
    # -u protects each FFI entry from dead stripping; export_dynamic keeps global
    # executable symbols visible to native-assets lookup in release builds.
    ['-Wl,-export_dynamic', *(['sqlite3_key'] + symbols).uniq.map { |s| "-Wl,-u,_#{s}" }]
  end
end
