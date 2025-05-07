import 'package:bookstore_app/models/book_model/book_model.dart';
import 'package:bookstore_app/view/home/widgets/book_horizontal_card.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({
    super.key,
    required this.books,
  });

  final List<BookModel> books;

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _current = 0;
  late final List<Widget> _items;

  @override
  void initState() {
    super.initState();
    _items =
        widget.books.map((book) => BookHorizontalCard(book: book)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: 180.h,
              width: double.infinity,
              child: CarouselSlider(
                items: _items,
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  autoPlay: false,
                  padEnds: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _items.asMap().entries.map(
              (entry) {
                return Container(
                  height: 8.h,
                  width: 8.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(
                      _current == entry.key ? 0.8 : 0.3,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
