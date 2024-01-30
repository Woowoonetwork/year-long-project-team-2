import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/colors.dart';
import 'package:FoodHood/Screens/donor_pathway_1.dart';
import 'package:FoodHood/Screens/posting_detail.dart';

class OrderCard extends StatelessWidget {
  final String imageLocation;
  final String title;
  final List<String> tags;
  final String orderInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final Function(String) onTap;
  final String postId;
  final VoidCallback? onStatusPressed;

  const OrderCard({
    Key? key,
    required this.imageLocation,
    required this.title,
    required this.tags,
    required this.orderInfo,
    required this.onTap,
    required this.postId,
    this.onEdit,
    this.onCancel,
    this.onStatusPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onCardTap(context),
        child: _buildCardBody(context),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, VoidCallback action) {
    action();
    Navigator.pop(context);
  }

  void _onCardTap(BuildContext context) {
    onTap(postId);
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PostDetailView(postId: postId),
        ));
  }

  Widget _buildCardBody(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          _buildTitleSection(context),
          _buildTagSection(context),
          _buildOrderInfoSection(context),
          _buildStatusButton(context),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground, context),
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 20)],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: Image.asset(imageLocation,
          width: MediaQuery.of(context).size.width,
          height: 100,
          fit: BoxFit.cover),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(title,
          style: TextStyle(
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              fontSize: 18,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTagSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 7,
        children: tags
            .map((tag) =>
                _buildTag(tag, _generateTagColor(tags.indexOf(tag)), context))
            .toList(),
      ),
    );
  }

  Color _generateTagColor(int index) {
    List<Color> availableColors = [yellow, orange, blue, babyPink, Cyan];
    return availableColors[index % availableColors.length];
  }

  Widget _buildTag(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color:
                  CupertinoDynamicColor.resolve(CupertinoColors.black, context),
              fontSize: 10,
              letterSpacing: -0.40,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildOrderInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(orderInfo,
          style: TextStyle(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel, context),
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          onPressed: () => _handleStatusPress(context),
          child: Text('Status', style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context), // CupertinoDynamicColor.resolve(CupertinoColors.label, context
              fontWeight: FontWeight.w500,
            fontSize: 16)),
          borderRadius: BorderRadius.circular(16),
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondarySystemFill, context),
        ),
      ),
    );
  }

  void _handleStatusPress(BuildContext context) {
    onStatusPressed?.call();
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => DonorScreen(postId: postId),
        ));
  }
}
