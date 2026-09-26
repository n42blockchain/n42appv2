require 'minitest/autorun'
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

end
