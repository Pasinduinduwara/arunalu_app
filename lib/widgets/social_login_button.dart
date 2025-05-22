import 'package:flutter/material.dart';

enum SocialLoginType {
  facebook,
  google,
  apple,
}

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;

  const SocialLoginButton({
    Key? key,
    required this.type,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: _getIcon(),
      ),
    );
  }

  Widget _getIcon() {
    switch (type) {
      case SocialLoginType.facebook:
        return const Icon(
          Icons.facebook,
          color: Color(0xFF1877F2),
          size: 40,
        );
      case SocialLoginType.google:
        return const Icon(
          Icons.public,
          color: Color(0xFFDB4437),
          size: 40,
        );
      case SocialLoginType.apple:
        return const Icon(
          Icons.apple,
          color: Colors.black,
          size: 40,
        );
    }
  }
} 