import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/points/points_config.dart';
import '../../../domain/entities/points/reward_rule.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_event.dart';
import '../../blocs/points/points_state.dart';

/// Admin configuration page for the points system.
///
/// Allows room administrators to:
/// - Toggle the points system on/off
/// - Edit points name and symbol
/// - Configure reward rules (action, points, daily limit, cooldown)
/// - Toggle leaderboard visibility and transfers
/// - Set a daily earn limit
class PointsAdminPage extends StatefulWidget {
  final String roomId;

  const PointsAdminPage({super.key, required this.roomId});

  @override
  State<PointsAdminPage> createState() => _PointsAdminPageState();
}

class _PointsAdminPageState extends State<PointsAdminPage> {
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  late TextEditingController _dailyLimitController;

  bool _isEnabled = true;
  bool _allowTransfers = false;
  bool _showLeaderboard = true;
  List<RewardRule> _rules = [];
  bool _isDirty = false;
  bool _isSaving = false;
  bool _hasAppliedInitialConfig = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _symbolController = TextEditingController();
    _dailyLimitController = TextEditingController();

    context.read<PointsBloc>().add(PointsLoadConfig(roomId: widget.roomId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _dailyLimitController.dispose();
    super.dispose();
  }

  void _applyConfig(PointsConfig config) {
    _nameController.text = config.pointsName;
    _symbolController.text = config.pointsSymbol;
    _dailyLimitController.text = config.dailyEarnLimit?.toString() ?? '';
    setState(() {
      _isEnabled = config.isEnabled;
      _allowTransfers = config.allowTransfers;
      _showLeaderboard = config.showLeaderboard;
      _rules = List.of(config.rules);
      _isDirty = false;
    });
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _save() {
    if (_isSaving) return;

    final dailyLimit = int.tryParse(_dailyLimitController.text);
    final config = PointsConfig(
      roomId: widget.roomId,
      isEnabled: _isEnabled,
      pointsName: _nameController.text.trim().isEmpty
          ? 'Points'
          : _nameController.text.trim(),
      pointsSymbol: _symbolController.text.trim().isEmpty
          ? 'PTS'
          : _symbolController.text.trim(),
      rules: _rules,
      allowTransfers: _allowTransfers,
      showLeaderboard: _showLeaderboard,
      dailyEarnLimit: dailyLimit,
    );

    setState(() => _isSaving = true);
    context.read<PointsBloc>().add(PointsUpdateConfig(config: config));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Points Settings'),
        backgroundColor: context.navBarColor,
        elevation: 0.5,
        actions: [
          if (_isDirty)
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<PointsBloc, PointsState>(
        listener: (context, state) {
          final shouldApplyInitialConfig =
              !_hasAppliedInitialConfig &&
              state.config != null &&
              state.status == PointsStatus.loaded;
          final shouldApplySavedConfig =
              _isSaving &&
              state.config != null &&
              state.status == PointsStatus.loaded;

          if (shouldApplyInitialConfig || shouldApplySavedConfig) {
            _applyConfig(state.config!);
            _hasAppliedInitialConfig = true;
            _isSaving = false;
          }
          if (state.status == PointsStatus.error) {
            if (_isSaving) {
              setState(() => _isSaving = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Failed to save configuration',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.config == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'General',
                children: [
                  _buildSwitchTile(
                    title: 'Enable Points System',
                    subtitle:
                        'Turn on points earning and rewards for this room',
                    value: _isEnabled,
                    onChanged: (v) {
                      setState(() => _isEnabled = v);
                      _markDirty();
                    },
                  ),
                  _buildTextField(
                    label: 'Points Name',
                    controller: _nameController,
                    hint: 'e.g. Points, Tokens, Stars',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Points Symbol',
                    controller: _symbolController,
                    hint: 'e.g. PTS, TKN',
                    maxLength: 5,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Features',
                children: [
                  _buildSwitchTile(
                    title: 'Show Leaderboard',
                    subtitle: 'Display public rankings for room members',
                    value: _showLeaderboard,
                    onChanged: (v) {
                      setState(() => _showLeaderboard = v);
                      _markDirty();
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Allow Transfers',
                    subtitle: 'Let members transfer points to each other',
                    value: _allowTransfers,
                    onChanged: (v) {
                      setState(() => _allowTransfers = v);
                      _markDirty();
                    },
                  ),
                  _buildTextField(
                    label: 'Daily Earn Limit',
                    controller: _dailyLimitController,
                    hint: 'No limit',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Reward Rules',
                trailing: IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                  onPressed: _showAddRuleDialog,
                ),
                children: [
                  if (_rules.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No rules configured',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._rules.asMap().entries.map(
                      (entry) => _RuleTile(
                        rule: entry.value,
                        isDark: context.isDarkMode,
                        onToggle: (enabled) {
                          setState(() {
                            _rules[entry.key] = RewardRule(
                              id: entry.value.id,
                              action: entry.value.action,
                              points: entry.value.points,
                              dailyLimit: entry.value.dailyLimit,
                              cooldown: entry.value.cooldown,
                              isEnabled: enabled,
                            );
                          });
                          _markDirty();
                        },
                        onDelete: () {
                          setState(() => _rules.removeAt(entry.key));
                          _markDirty();
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section builder
  // ---------------------------------------------------------------------------

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Common form widgets
  // ---------------------------------------------------------------------------

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (_) => _markDirty(),
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.textTertiary,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.dividerThinDark
                : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Add rule dialog
  // ---------------------------------------------------------------------------

  void _showAddRuleDialog() {
    PointsAction selectedAction = PointsAction.sendMessage;
    final pointsController = TextEditingController(text: '1');
    final dailyLimitController = TextEditingController();
    final cooldownController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: context.surfaceColor,
              title: const Text('Add Reward Rule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButton<PointsAction>(
                      value: selectedAction,
                      isExpanded: true,
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedAction = v);
                        }
                      },
                      items: PointsAction.values.map((action) {
                        return DropdownMenuItem(
                          value: action,
                          child: Text(
                            RewardRule(
                              id: '',
                              action: action,
                              points: 0,
                            ).actionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              color: context.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pointsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Points per action',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dailyLimitController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Daily limit (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cooldownController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Cooldown (seconds, optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final points = int.tryParse(pointsController.text) ?? 1;
                    final dailyLimit = int.tryParse(dailyLimitController.text);
                    final cooldownSec = int.tryParse(cooldownController.text);

                    final rule = RewardRule(
                      id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
                      action: selectedAction,
                      points: points,
                      dailyLimit: dailyLimit,
                      cooldown: cooldownSec != null
                          ? Duration(seconds: cooldownSec)
                          : null,
                    );

                    setState(() => _rules.add(rule));
                    _markDirty();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      pointsController.dispose();
      dailyLimitController.dispose();
      cooldownController.dispose();
    });
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _RuleTile extends StatelessWidget {
  final RewardRule rule;
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _RuleTile({
    required this.rule,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dividerThinOf(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: rule.isEnabled
                        ? context.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _buildSubtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: rule.isEnabled,
            onChanged: onToggle,
            activeTrackColor: AppColors.primary,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: context.textTertiary,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>['${rule.points} pts'];
    if (rule.dailyLimit != null) parts.add('max ${rule.dailyLimit}/day');
    if (rule.cooldown != null) {
      parts.add('${rule.cooldown!.inSeconds}s cooldown');
    }
    return parts.join(' | ');
  }
}
