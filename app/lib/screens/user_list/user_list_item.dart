import 'package:app/models/user.dart';
import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({
    required this.user,
    super.key,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // ユーザーアイコン
          Padding(
            padding: const EdgeInsets.all(12),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: user.imageUrl != null
                  ? NetworkImage(user.imageUrl!)
                  : null,
              child: user.imageUrl == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
          ),
          // ユーザー情報
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.id != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${user.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  if (user.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // 右矢印アイコン
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
