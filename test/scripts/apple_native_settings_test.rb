require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../../scripts/apple_native_settings'

class AppleNativeSettingsTest < Minitest::Test
  def test_floor_preserves_higher_targets
    assert_equal '17.0', N42AppleNative.deployment_floor('17.0', '16.0')
    assert_equal '12.0', N42AppleNative.deployment_floor('10.15', '12.0')
    assert_equal '12.0', N42AppleNative.deployment_floor(nil, '12.0')
  end

  def test_all_resolved_sqlite_bindings_are_retained_without_duplicate_flags
    flags = N42AppleNative.sqlite_link_flags(File.expand_path('../..', __dir__))
    assert_includes flags, '-Wl,-u,_sqlite3_key'
    assert_includes flags, '-Wl,-u,_sqlite3session_create'
    assert_includes flags, '-Wl,-u,_sqlite3changeset_apply'
    assert_includes flags, '-Wl,-export_dynamic'
    assert_equal flags.uniq, flags
    assert_operator flags.length, :>, 90
  end
  def test_link_flags_preserve_repeated_framework_tokens_and_are_idempotent
    original = ['$(inherited)', '-framework', 'SQLCipher', '-framework', 'WebKit']
    additions = ['-Wl,-u,_sqlite3_key', '-Wl,-export_dynamic']
    merged = N42AppleNative.append_link_flags(original, additions)
    assert_equal original + additions, merged
    assert_equal 2, merged.count('-framework')
    assert_equal merged, N42AppleNative.append_link_flags(merged, additions)
    assert_equal 5, original.length
  end

  def test_package_uri_paths_with_spaces
    Dir.mktmpdir('apple native ') do |parent|
      app = File.join(parent, 'checkout with spaces')
      package = File.join(app, 'packages', 'sqlite source')
      FileUtils.mkdir_p(File.join(app, '.dart_tool'))
      symbols_dir = File.join(package, 'lib', 'src', 'hook', 'compile')
      FileUtils.mkdir_p(symbols_dir)
      File.write(File.join(symbols_dir, 'used_symbols.dart'), "const symbols = ['sqlite3_open'];")
      escaped = URI::DEFAULT_PARSER.escape(package)
      ['../packages/sqlite%20source', "file://#{escaped}"].each do |root_uri|
        config = { 'packages' => [{ 'name' => 'sqlite3', 'rootUri' => root_uri }] }
        File.write(File.join(app, '.dart_tool', 'package_config.json'), JSON.generate(config))
        assert_equal ['-Wl,-export_dynamic', '-Wl,-u,_sqlite3_key', '-Wl,-u,_sqlite3_open'],
                     N42AppleNative.sqlite_link_flags(app)
      end
    end
  end

end
