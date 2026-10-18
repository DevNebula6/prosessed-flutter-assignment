# These plugins reach their Android code from Dart through JNI, looking
# classes and methods up by name. R8 can't see those lookups, so it strips or
# renames what they need; shared_preferences then failed at startup and the
# release app never got past the splash.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.github.dart_lang.jni.** { *; }

# The Kotlin runtime classes package:jni looks up for suspend functions.
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.** { *; }
