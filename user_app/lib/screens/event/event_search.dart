import 'package:EventLink/widgets/status_filter.dart';
import 'package:EventLink/widgets/type_filter.dart';
import 'package:flutter/material.dart';

import '../../models/event.dart';
import '../../utilities/shared.dart';
import '../../widgets/event_card.dart';
import '../../widgets/future_builder.dart';
import '../../widgets/search.dart';

SearchDelegate eventSearchWidget(VoidCallback? setState) {
  return Search(
    categories: Event.eventSearchFields,
    body: (query, selectedCategory, selectedStatus, selectedType) {
      return BuildFuture(
        callback: () async {
          return await searchEvents(
              int.tryParse(query) != null ? int.parse(query) : query,
              fnum: selectedCategory,
              selectedStatus,
              selectedType);
        },
        mapper: (resData) {
          return mapObjs(resData.data['events'], toEvent);
        },
        builder: (data) {
          List<dynamic> events = data;
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: data?.length,
            itemBuilder: (context, index) {
              Event eventx = events[index];
              return EventCard(eventx: eventx);
            },
          );
        },
      );
    },
  );
}
