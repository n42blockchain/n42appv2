import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Status setting page (WeChat-style)
class StatusPage extends StatefulWidget {
  final String? currentStatus;

  const StatusPage({super.key, this.currentStatus});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  List<StatusCategory> _getCategories(BuildContext context) {
    final s = S.of(context);
    return [
      StatusCategory(
        title: s?.profileMoodAndThoughts ?? 'Mood & Thoughts',
        items: [
          StatusItem(
            icon: Icons.sentiment_very_satisfied,
            text: s?.profileStatusHappy ?? 'Happy',
          ),
          StatusItem(
            icon: Icons.sentiment_dissatisfied,
            text: s?.profileStatusCracked ?? 'Shattered',
          ),
          StatusItem(
            icon: Icons.auto_awesome,
            text: s?.profileStatusLucky ?? 'Lucky',
          ),
          StatusItem(
            icon: Icons.wb_sunny_outlined,
            text: s?.profileStatusSunny ?? 'Sunny',
          ),
          StatusItem(
            icon: Icons.airline_seat_recline_normal,
            text: s?.profileStatusTired ?? 'Tired',
          ),
          StatusItem(
            icon: Icons.psychology_outlined,
            text: s?.profileStatusDaydream ?? 'Daydream',
          ),
          StatusItem(
            icon: Icons.flash_on,
            text: s?.profileStatusRushing ?? 'Rushing',
          ),
          StatusItem(icon: Icons.mood_bad, text: 'emo'),
          StatusItem(
            icon: Icons.cloud_outlined,
            text: s?.profileStatusOverthinking ?? 'Overthinking',
          ),
          StatusItem(
            icon: Icons.celebration,
            text: s?.profileStatusEnergized ?? 'Energized',
          ),
          StatusItem(icon: Icons.smart_toy_outlined, text: 'bot'),
        ],
      ),
      StatusCategory(
        title: s?.profileWorkAndStudy ?? 'Work & Study',
        items: [
          StatusItem(
            icon: Icons.construction,
            text: s?.profileStatusWorking ?? 'Working',
          ),
          StatusItem(
            icon: Icons.menu_book,
            text: s?.profileStatusStudying ?? 'Studying',
          ),
          StatusItem(
            icon: Icons.work_outline,
            text: s?.profileStatusBusy ?? 'Busy',
          ),
          StatusItem(
            icon: Icons.catching_pokemon,
            text: s?.profileStatusSlacking ?? 'Slacking',
          ),
          StatusItem(
            icon: Icons.flight_takeoff,
            text: s?.profileStatusTraveling ?? 'Traveling',
          ),
          StatusItem(
            icon: Icons.directions_run,
            text: s?.profileStatusGoingHome ?? 'Going Home',
          ),
          StatusItem(
            icon: Icons.do_not_disturb_on_outlined,
            text: s?.profileStatusDnd ?? 'Do Not Disturb',
          ),
        ],
      ),
      StatusCategory(
        title: s?.profileActivities ?? 'Activities',
        items: [
          StatusItem(
            icon: Icons.surfing,
            text: s?.profileStatusHanging ?? 'Hanging Out',
          ),
          StatusItem(
            icon: Icons.check_circle_outline,
            text: s?.profileStatusCheckIn ?? 'Check In',
          ),
          StatusItem(
            icon: Icons.fitness_center,
            text: s?.profileStatusExercising ?? 'Exercising',
          ),
          StatusItem(
            icon: Icons.coffee_outlined,
            text: s?.profileStatusCoffee ?? 'Coffee',
          ),
          StatusItem(
            icon: Icons.local_cafe_outlined,
            text: s?.profileStatusBubbleTea ?? 'Bubble Tea',
          ),
          StatusItem(
            icon: Icons.rice_bowl,
            text: s?.profileStatusEating ?? 'Eating',
          ),
          StatusItem(
            icon: Icons.child_friendly,
            text: s?.profileStatusParenting ?? 'Parenting',
          ),
          StatusItem(
            icon: Icons.public,
            text: s?.profileStatusSavingWorld ?? 'Saving World',
          ),
          StatusItem(
            icon: Icons.camera_alt_outlined,
            text: s?.profileStatusSelfie ?? 'Selfie',
          ),
        ],
      ),
      StatusCategory(
        title: s?.profileRest ?? 'Rest',
        items: [
          StatusItem(
            icon: Icons.self_improvement,
            text: s?.profileStatusRetreat ?? 'Retreat',
          ),
          StatusItem(
            icon: Icons.home_outlined,
            text: s?.profileStatusHome ?? 'Home',
          ),
          StatusItem(
            icon: Icons.bedtime_outlined,
            text: s?.profileStatusSleeping ?? 'Sleeping',
          ),
          StatusItem(
            icon: Icons.pets,
            text: s?.profileStatusCatLover ?? 'Cat Lover',
          ),
          StatusItem(
            icon: Icons.pets_outlined,
            text: s?.profileStatusDogWalking ?? 'Walking Dog',
          ),
          StatusItem(
            icon: Icons.sports_esports,
            text: s?.profileStatusGaming ?? 'Gaming',
          ),
          StatusItem(
            icon: Icons.headphones,
            text: s?.profileStatusListening ?? 'Listening',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B9A6B), Color(0xFFB5A87A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomInput(),
                      ...categories.map((category) => _buildCategory(category)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  S.of(context)?.profileSetStatus ?? 'Set Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  S.of(context)?.profileVisibleToFriends24h ??
                      'Visible to friends for 24 hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildCustomInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () => _showCustomStatusDialog(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              S.of(context)?.profileWriteStatus ?? 'Write Status',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(StatusCategory category) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              category.title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Wrap(
              spacing: 0,
              runSpacing: 8,
              children: category.items
                  .map((item) => _buildStatusItem(item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(StatusItem item) {
    final isSelected = widget.currentStatus == item.text;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, item.text);
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 32 - 16) / 5,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(item.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              item.text,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomStatusDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.profileWriteStatus ?? 'Write Status'),
        content: TextField(
          controller: _customController,
          autofocus: true,
          maxLength: 20,
          decoration: InputDecoration(
            hintText:
                S.of(context)?.profileEnterYourStatus ?? 'Enter your status...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_customController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.pop(context, _customController.text.trim());
              }
            },
            child: Text(S.of(context)?.profileOk ?? 'OK'),
          ),
        ],
      ),
    );
  }
}

/// Status category
class StatusCategory {
  final String title;
  final List<StatusItem> items;

  StatusCategory({required this.title, required this.items});
}

/// Status item
class StatusItem {
  final IconData icon;
  final String text;

  StatusItem({required this.icon, required this.text});
}
