import re

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "r") as f:
    code = f.read()

s2 = """              Positioned(
                top: 100, left: 20, right: 20,
                child: Text('DIAGNOSTIC PATH: ${widget.photoPath}', style: const TextStyle(color: Colors.red, fontSize: 16, backgroundColor: Colors.black)),
              ),
              Positioned.fill(
                child: DetectionOverlayWidget("""

r2 = """              Positioned.fill(
                child: DetectionOverlayWidget("""

code = code.replace(s2, r2)

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "w") as f:
    f.write(code)

print("Reverted diagnostic text")
