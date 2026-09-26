package com.it_nomads.fluttersecurestorage;

import android.content.Context;
import android.system.ErrnoException;
import android.system.Os;
import android.system.OsConstants;
import android.util.Xml;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.xmlpull.v1.XmlPullParser;

/** Disk-only validation: Android SharedPreferences silently treats XML/read errors as empty. */
final class StrictPreferencesSnapshot {
    final boolean exists;
    final Map<String, Object> values;
    private StrictPreferencesSnapshot(boolean exists, Map<String, Object> values) {
        this.exists = exists;
        this.values = values;
    }

    static StrictPreferencesSnapshot read(Context context, String name) throws Exception {
        File file = new File(context.getApplicationInfo().dataDir, "shared_prefs/" + name + ".xml");
        // SharedPreferences loading would delete/rename these files. Recovery needs explicit repair.
        if (exists(new File(file.getPath() + ".bak")))
            throw new IOException("Secure preferences backup requires repair: " + name);
        if (!exists(file)) return new StrictPreferencesSnapshot(false, new HashMap<>());
        if (!OsConstants.S_ISREG(Os.lstat(file.getPath()).st_mode))
            throw new IOException("Secure preferences is not a regular file: " + name);
        try (FileInputStream input = new FileInputStream(file)) {
            XmlPullParser parser = Xml.newPullParser();
            parser.setInput(input, "UTF-8");
            int event;
            do {
                event = parser.nextToken();
                if (event == XmlPullParser.DOCDECL || event == XmlPullParser.ENTITY_REF
                        || (event == XmlPullParser.TEXT && !parser.isWhitespace()))
                    throw new IOException("Invalid preferences prolog");
            } while (event != XmlPullParser.START_TAG && event != XmlPullParser.END_DOCUMENT);
            if (event != XmlPullParser.START_TAG || !parser.getName().equals("map")
                    || parser.getAttributeCount() != 0) throw new IOException("Invalid preferences root");
            Map<String, Object> values = new HashMap<>();
            while (parser.nextTag() == XmlPullParser.START_TAG) {
                String key = parser.getAttributeValue(null, "name");
                if (key == null || values.containsKey(key)) throw new IOException("Invalid/duplicate preference key");
                values.put(key, readValue(parser));
            }
            if (!parser.getName().equals("map")) throw new IOException("Invalid preferences end");
            while ((event = parser.nextToken()) != XmlPullParser.END_DOCUMENT) {
                if (event != XmlPullParser.COMMENT && event != XmlPullParser.IGNORABLE_WHITESPACE
                        && !(event == XmlPullParser.TEXT && parser.isWhitespace()))
                    throw new IOException("Trailing preferences content");
            }
            return new StrictPreferencesSnapshot(true, values);
        }
    }

    private static Object readValue(XmlPullParser parser) throws Exception {
        String tag = parser.getName();
        if (tag.equals("string")) {
            if (parser.getAttributeCount() != 1) throw new IOException("Invalid string attributes");
            return parser.nextText();
        }
        if (tag.equals("set")) {
            if (parser.getAttributeCount() != 1) throw new IOException("Invalid set attributes");
            Set<String> result = new HashSet<>();
            while (parser.nextTag() == XmlPullParser.START_TAG) {
                if (!parser.getName().equals("string") || parser.getAttributeCount() != 0)
                    throw new IOException("Invalid preference set");
                if (!result.add(parser.nextText())) throw new IOException("Duplicate set value");
            }
            if (!parser.getName().equals("set")) throw new IOException("Invalid set end");
            return result;
        }
        String value = parser.getAttributeValue(null, "value");
        if (value == null || parser.getAttributeCount() != 2 || !parser.nextText().isEmpty())
            throw new IOException("Invalid preference scalar");
        switch (tag) {
            case "boolean":
                if (!value.equals("true") && !value.equals("false")) throw new IOException("Invalid boolean");
                return Boolean.valueOf(value);
            case "int": return Integer.valueOf(value);
            case "long": return Long.valueOf(value);
            case "float": return Float.valueOf(value);
            default: throw new IOException("Unsupported preference type");
        }
    }

    private static boolean exists(File file) throws IOException {
        try { Os.lstat(file.getPath()); return true; }
        catch (ErrnoException error) {
            if (error.errno == OsConstants.ENOENT) return false;
            throw new IOException("Cannot inspect secure preferences", error);
        }
    }

    String string(String key, String fallback) throws IOException {
        Object value = values.get(key);
        if (value == null) return fallback;
        if (!(value instanceof String)) throw new IOException("Preference is not a string: " + key);
        return (String) value;
    }

    boolean flag(String key) throws IOException {
        Object value = values.get(key);
        if (value == null) return false;
        if (!(value instanceof Boolean)) throw new IOException("Preference is not a boolean: " + key);
        return (Boolean) value;
    }
}
