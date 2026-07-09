# Regras do ProGuard para Ofuscação Avançada
# Este arquivo configura a ofuscação do código Android

# Manter classes do Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Manter MainActivity e classes do app
-keep class com.tomato.streaming.** { *; }

# Manter classes nativas
-keepclasseswithmembernames class * {
    native <methods>;
}

# Ofuscar todos os outros códigos
-repackageclasses ''
-allowaccessmodification
-dontpreverify

# Remover logs em produção
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Ofuscação agressiva de nomes
-obfuscationdictionary obfuscation-dictionary.txt
-classobfuscationdictionary obfuscation-dictionary.txt
-packageobfuscationdictionary obfuscation-dictionary.txt

# Otimizações adicionais
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5

# Manter SQLite
-keep class androidx.sqlite.** { *; }
-keep class org.sqlite.** { *; }

# Manter Gson/JSON
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }

# Manter WorkManager
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(...);
}

# Manter AdMob
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Manter Notificações
-keep class androidx.core.app.NotificationCompat { *; }
-keep class com.dexterous.** { *; }

# Remover atributos de debug
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
