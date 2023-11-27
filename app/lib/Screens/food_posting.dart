// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FoodPosting());
}

class FoodPostingBig extends StatelessWidget {
  const FoodPostingBig({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: FoodPosting(),
    );
  }
}

class FoodPosting extends StatelessWidget {
  const FoodPosting({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Chicken and Rice'),
        leading: CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.heart),
              onPressed: () {
                
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.share),
              onPressed: () {
                
              },
            ),
          ],
        ),
      ),
      child: const FoodPostingContent(),
    );
  }
}

class FoodPostingContent extends StatefulWidget {
  const FoodPostingContent({super.key});

  @override
  _FoodPostingContentState createState() => _FoodPostingContentState();
}

class _FoodPostingContentState extends State<FoodPostingContent> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200.0,
            color: Colors.grey,
            child: const Center(
              child: Text(
                'Image',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chicken and Rice',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Succulent grilled chicken breast marinated in a zesty lemon-garlic sauce, served atop a bed of fluffy cilantro-lime rice. Accompanied by a side of steamed asparagus spears and drizzled with a tangy mango salsa.',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 16.0),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harry Styles',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating:',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            '4.5/5',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CupertinoCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.nosign, size: 24.0, color: Color.fromARGB(255, 255, 0, 0)),
                        Text('Expiration Date',
                        style: TextStyle(fontSize: 10.0),
                    ),
                    ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: CupertinoCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.bag, size: 24.0, color: Color.fromARGB(255, 35, 21, 158)),
                        Text(
                          'Pickup Time',
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: CupertinoCard(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.exclamationmark_bubble, size: 24.0, color: Color.fromARGB(255, 255, 222, 9)),
                        Text('Allergens',
                        style: TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const CupertinoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text('Pickup point'),
                SizedBox(height: 8.0),
                Text('Meeting time'),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const CupertinoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allergens',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Peanuts'),
              ],
            ),
          ),
          const SizedBox(height: 100.0), 
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {});
    });
  }
}

class CupertinoCard extends StatelessWidget {
  final Widget child;

  const CupertinoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.5),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
