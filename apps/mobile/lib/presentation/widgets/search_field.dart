import 'package:flutter/material.dart';
import '../../core/presentation/layout/responsive.dart';

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const SearchField({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 20),
        hintText: 'Search Truck Number, Driver or Carrier',
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppResponsive.isCompact(context) ? 14 : 20,
          vertical: AppResponsive.isCompact(context) ? 10 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
                child: const Icon(Icons.clear, size: 20),
              )
            : null,
      ),
      onChanged: (val) {
        widget.onChanged(val);
        setState(() {});
      },
    );
  }
}
