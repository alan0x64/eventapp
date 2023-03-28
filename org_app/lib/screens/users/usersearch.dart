import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../utilities/shared.dart';
import '../../widgets/future_builder.dart';
import '../../widgets/search.dart';
import '../../widgets/user_card.dart';

SearchDelegate userSearch(int lnum,{
  String eventId = "",
  bool blacklist = false,
  bool showControl = true,
}) {
  return Search(
    categories: User.userSearchFields,
    body: (query, selectedCategory) {
      return BuildFuture(
        callback: () async {
          return await searchUsers(
              eventId, int.tryParse(query) != null ? int.parse(query) : query,
              fnum: selectedCategory, lnum: lnum);
        },
        mapper: (resData) {
          return mapObjs(resData.data['members'], toUser);
        },
        builder: (data) {
          List<dynamic> users = data;
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: data?.length,
            itemBuilder: (context, index) {
              User userx = users[index];
              return UserCard(
                eventId: eventId,
                user: userx,
                blacklist: blacklist,
              );
            },
          );
        },
      );
    },
  );
}
