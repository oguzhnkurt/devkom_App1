# Fix _BlockWidget class definition
/^class _BlockWidget extends StatelessWidget {$/,/^  \);$/ {
  /final _FallingBlock block;/!b
  a\
  final bool isSelected;\
  final VoidCallback onTap;
  /final VoidCallback onTapMotion;/d
  /final VoidCallback onTapLooks;/d
}
