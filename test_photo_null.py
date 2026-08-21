import re

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "r") as f:
    code = f.read()

s1 = """                  : Container(
                      color: const Color(0xFF0A1628),
                      child: const Center(
                        child: Icon(Icons.photo_camera_outlined,
                            size: 80, color: Colors.white24),
                      ),
                    ),"""

r1 = """                  : Container(
                      color: const Color(0xFF0A1628),
                      child: const Center(
                        child: Text("PHOTOPATH IS NULL", style: TextStyle(color: Colors.red, fontSize: 32)),
                      ),
                    ),"""

code = code.replace(s1, r1)

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "w") as f:
    f.write(code)

print("Added PHOTOPATH IS NULL visual check")
