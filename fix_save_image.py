import re

with open("apps/mobile/lib/core/storage/image_storage_service.dart", "r") as f:
    code = f.read()

s1 = """    final destination = p.join(basePath, fileName);
    await imageFile.copy(destination);
    return destination;"""

r1 = """    final destination = p.join(basePath, fileName);
    // Use Isolate to avoid main thread lag while ensuring flush: true
    // File.copy() on some OEM Android versions doesn't fully flush synchronously, 
    // causing FileImage to read a truncated file on the next screen.
    await Isolate.run(() {
      final bytes = imageFile.readAsBytesSync();
      File(destination).writeAsBytesSync(bytes, flush: true);
    });
    return destination;"""

code = code.replace(s1, r1)

with open("apps/mobile/lib/core/storage/image_storage_service.dart", "w") as f:
    f.write(code)

print("Fixed saveImage flush")
