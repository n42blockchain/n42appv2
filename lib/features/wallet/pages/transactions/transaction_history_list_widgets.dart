part of 'transaction_history_list.dart';

/// Filter bottom sheet UI mixin for [_TransactionHistoryListState].
///
/// Requires [_TransactionHistoryLogicMixin] to be applied first so that
/// filter state and logic methods are accessible.
mixin _TransactionHistoryWidgetsMixin on _TransactionHistoryLogicMixin {
  void showFilterSheet() {
    _TxFilter temp = filter;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSS) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.h,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Header row ----
                    _buildFilterHeader(ctx, setSS, () => temp = temp.clear(),
                        (t) => temp = t),
                    SizedBox(height: 12.h),

                    // ---- Direction ----
                    _buildDirectionSection(ctx, setSS, temp,
                        (t) => temp = t),
                    SizedBox(height: 12.h),

                    // ---- Status ----
                    _buildStatusSection(ctx, setSS, temp, (t) => temp = t),
                    SizedBox(height: 12.h),

                    // ---- Date range ----
                    _buildDateRangeSection(ctx, setSS, temp,
                        (t) => temp = t),
                    SizedBox(height: 16.h),

                    // ---- Confirm ----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => filter = temp);
                          Navigator.pop(ctx);
                        },
                        child: Text(S.of(ctx).g_key_78),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterHeader(
    BuildContext ctx,
    StateSetter setSS,
    VoidCallback onClear,
    ValueChanged<_TxFilter> onUpdate,
  ) {
    return Row(
      children: [
        Text(
          S.of(ctx).g_key_filter,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => setSS(onClear),
          child: Text(S.of(ctx).g_key_reset),
        ),
      ],
    );
  }

  Widget _buildDirectionSection(
    BuildContext ctx,
    StateSetter setSS,
    _TxFilter temp,
    ValueChanged<_TxFilter> onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(ctx).g_key_tx_filter_direction,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: temp.direction == null,
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(direction: null))),
            ),
            ChoiceChip(
              label: Text(S.of(ctx).g_key_t_4),
              selected: temp.direction == 'out',
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(direction: 'out'))),
            ),
            ChoiceChip(
              label: Text(S.of(ctx).g_key_t_5),
              selected: temp.direction == 'in',
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(direction: 'in'))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection(
    BuildContext ctx,
    StateSetter setSS,
    _TxFilter temp,
    ValueChanged<_TxFilter> onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(ctx).g_key_wallet_k33,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: temp.status == null,
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(status: null))),
            ),
            // state 1 = Complete
            ChoiceChip(
              label: Text(S.of(ctx).g_key_t_1),
              selected: temp.status == 1,
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(status: 1))),
            ),
            // state 0 = Pending
            ChoiceChip(
              label: Text(S.of(ctx).g_key_t_2),
              selected: temp.status == 0,
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(status: 0))),
            ),
            // state 2 = Failure
            ChoiceChip(
              label: Text(S.of(ctx).g_key_t_3),
              selected: temp.status == 2,
              onSelected: (_) =>
                  setSS(() => onUpdate(temp.copyWith(status: 2))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeSection(
    BuildContext ctx,
    StateSetter setSS,
    _TxFilter temp,
    ValueChanged<_TxFilter> onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(ctx).g_key_tx_filter_date_range,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            temp.dateFrom == null && temp.dateTo == null
                ? '${S.of(ctx).g_key_tx_filter_date_from} → ${S.of(ctx).g_key_tx_filter_date_to}'
                : '${temp.dateFrom != null ? DateFormat('yyyy-MM-dd').format(temp.dateFrom!) : S.of(ctx).g_key_tx_filter_date_from}'
                    ' → '
                    '${temp.dateTo != null ? DateFormat('yyyy-MM-dd').format(temp.dateTo!) : S.of(ctx).g_key_tx_filter_date_to}',
            style: TextStyle(fontSize: 14.sp),
          ),
          trailing: Icon(
            Icons.calendar_today_outlined,
            size: 20.r,
          ),
          onTap: () async {
            final range = await showDateRangePicker(
              context: ctx,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: temp.dateFrom != null
                  ? DateTimeRange(
                      start: temp.dateFrom!,
                      end: temp.dateTo ?? DateTime.now(),
                    )
                  : null,
            );
            if (range != null) {
              setSS(() => onUpdate(temp.copyWith(
                    dateFrom: range.start,
                    dateTo: range.end,
                  )));
            }
          },
        ),
        if (temp.dateFrom != null || temp.dateTo != null)
          TextButton(
            onPressed: () => setSS(
              () => onUpdate(temp.copyWith(
                dateFrom: null,
                dateTo: null,
              )),
            ),
            child: const Text('Clear dates'),
          ),
      ],
    );
  }
}
