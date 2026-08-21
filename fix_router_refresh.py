import re

with open("apps/mobile/lib/navigation/app_router.dart", "r") as f:
    code = f.read()

s1 = """class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<User?>(authProvider, (_, __) => notifyListeners());
  }
}"""

r1 = """class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<User?>(authProvider, (previous, current) {
      if (previous?.id != current?.id) {
        notifyListeners();
      }
    });
  }
}"""

code = code.replace(s1, r1)

with open("apps/mobile/lib/navigation/app_router.dart", "w") as f:
    f.write(code)

print("Fixed _AuthRouterRefresh")
