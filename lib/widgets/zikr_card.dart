import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fazkorony/services/dhikr_events.dart';

class ZikrCard extends StatefulWidget {
  final ZikrItem item;
  final Function(int)? onCounterChanged;

  const ZikrCard({super.key, 
    required this.item,
    this.onCounterChanged,
  });

  @override
  _ZikrCardState createState() =>
      _ZikrCardState();
}

class _ZikrCardState
    extends State<ZikrCard> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    final bool isComplete =
        widget.item.repeat > 0 &&
            counter >=
                widget.item.repeat;

    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.symmetric(
              vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      color: isComplete
          ? Colors.green.shade50
          : null,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              widget.item.text,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                  fontSize: 18,
                  height: 1.6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  widget.item.reference,
                  style: TextStyle(
                      color: Colors
                          .grey[600]),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.share,
                          color: Colors
                              .blue),
                      onPressed: () =>
                          Share.share(
                              widget
                                  .item
                                  .text),
                    ),
                    Container(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .deepPurple[50],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons
                                    .add,
                                color: Colors
                                    .deepPurple),
                            onPressed:
                                isComplete
                                    ? null
                                    : _incrementCounter,
                          ),
                          Text(
                            '$counter',
                            style:
                                const TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: Colors
                                  .deepPurple,
                            ),
                          ),
                          if (widget
                                  .item
                                  .repeat >
                              0)
                            Padding(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal:
                                      4),
                              child:
                                  Text(
                                '/${widget.item.repeat}',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      14,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ),
                          if (counter >
                              0)
                            IconButton(
                              icon: const Icon(
                                  Icons
                                      .refresh,
                                  size:
                                      20,
                                  color:
                                      Colors.redAccent),
                              onPressed:
                                  _resetCounter,
                              tooltip:
                                  'إعادة التصفير',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _incrementCounter() {
    if (widget.item.repeat > 0 &&
        counter >= widget.item.repeat) {
      return;
    }

    setState(() {
      counter++;
      widget.onCounterChanged
          ?.call(counter);
    });
    // سجل حدث قراءة ذِكر واحد (يُحترم تفعيل الإحصاءات من الإعدادات)
    DhikrEvents.recordRead(context, category: 'generic');
  }

  void _resetCounter() {
    setState(() {
      counter = 0;
      widget.onCounterChanged
          ?.call(counter);
    });
  }
}

class ZikrItem {
  final String id;
  final String text;
  final String reference;
  final int repeat;

  ZikrItem({
    required this.id,
    required this.text,
    required this.reference,
    this.repeat = 0,
  });
}
