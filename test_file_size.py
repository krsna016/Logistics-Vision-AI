import re

with open("apps/mobile/lib/features/camera/presentation/screens/camera_screen.dart", "r") as f:
    code = f.read()

s1 = """        final savedPath = await _imageStorage.saveImage(
          File(image.path),
          'gallery_layer_$truckId',
        );
        await _logReviewPhoto('gallery photo persisted', savedPath);"""

r1 = """        final savedPath = await _imageStorage.saveImage(
          File(image.path),
          'gallery_layer_$truckId',
        );
        AppLogger.fatal('GALLERY PICK: orig=${image.path} (size: ${await File(image.path).length()}) -> new=$savedPath (size: ${await File(savedPath).length()})');
        await _logReviewPhoto('gallery photo persisted', savedPath);"""

code = code.replace(s1, r1)

with open("apps/mobile/lib/features/camera/presentation/screens/camera_screen.dart", "w") as f:
    f.write(code)

print("Added file size debug")
