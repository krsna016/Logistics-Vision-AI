import re

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "r") as f:
    code = f.read()

s1 = """                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_outlined,
                                  size: 72, color: Colors.white38),
                              SizedBox(height: 12),
                              Text(
                                'Error: ${error.toString()}\\nPath: ${widget.photoPath}',"""

r1 = """                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.broken_image_outlined,
                                  size: 72, color: Colors.white38),
                              const SizedBox(height: 12),
                              Text(
                                'Error: ${error.toString()}\\nPath: ${widget.photoPath}',"""

code = code.replace(s1, r1)

with open("apps/mobile/lib/features/layer/presentation/screens/layer_review_screen.dart", "w") as f:
    f.write(code)

print("Fixed const issue")
