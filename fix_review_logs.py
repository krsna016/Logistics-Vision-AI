import re

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "r") as f:
    code = f.read()

s1 = """                              Text(
                                'Captured photo could not be displayed.\\n'
                                'Review diagnostics were recorded.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),"""

r1 = """                              Text(
                                'Error: ${error.toString()}\\nPath: ${widget.photoPath}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                              ),"""

code = code.replace(s1, r1)

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "w") as f:
    f.write(code)

print("Added on-screen extreme logs for image loading")
