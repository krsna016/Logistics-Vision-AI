# Flutter plugins and Google ML Kit publish their own consumer rules. Keep
# model metadata annotations used reflectively by ML Kit text recognition.
-keepattributes *Annotation*

# The Flutter ML Kit wrapper can initialize optional OCR scripts, while this
# app deliberately bundles and requests only the Latin recognizer.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
