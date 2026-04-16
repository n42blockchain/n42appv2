import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/common/web3_identity_card.dart';

// Minimal widget host: no localization delegates needed because
// Web3IdentityCard uses null-safe ?. getters with string fallbacks.
Widget _buildCard(Web3IdentityCard card) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: card)),
  );
}

const _address = '0x71C7656EC7ab88b098defB751B7401B5f6d8976F';
const _shortAddress = '0x71C7...976F'; // abbreviateAddress result

void main() {
  group('Web3IdentityCard', () {
    group('wallet address display', () {
      testWidgets('shows abbreviated address', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        // Address appears in both the name header and the address row
        expect(find.text(_shortAddress), findsAtLeastNWidgets(1));
      });

      testWidgets('shows copy button', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      });
    });

    group('display name priority', () {
      testWidgets('uses displayName when provided', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(
            walletAddress: _address,
            displayName: 'Alice Smith',
          ),
        ));
        expect(find.text('Alice Smith'), findsOneWidget);
      });

      testWidgets('falls back to ensName when displayName is null', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(
            walletAddress: _address,
            ensName: 'vitalik.eth',
          ),
        ));
        // ensName appears as display name header AND in ENS badge
        expect(find.text('vitalik.eth'), findsAtLeastNWidgets(1));
      });

      testWidgets('falls back to abbreviated address when both null', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        expect(find.text(_shortAddress), findsAtLeastNWidgets(1));
      });
    });

    group('ENS badge', () {
      testWidgets('shows ENS name text when ensName is provided', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(
            walletAddress: _address,
            ensName: 'vitalik.eth',
          ),
        ));
        // ENS badge displays the ensName text
        expect(find.text('vitalik.eth'), findsAtLeastNWidgets(1));
      });

      testWidgets('hides ENS name when ensName is null', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        expect(find.text('vitalik.eth'), findsNothing);
      });
    });

    group('NFT avatar', () {
      testWidgets('shows NFT text badge when isNftAvatar=true', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(
            walletAddress: _address,
            isNftAvatar: true,
          ),
        ));
        // NFT badge shows "NFT" text as fallback
        expect(find.text('NFT'), findsOneWidget);
      });

      testWidgets('hides NFT badge when isNftAvatar=false (default)', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        expect(find.text('NFT'), findsNothing);
      });
    });

    group('N42 user badge', () {
      testWidgets('shows N42 badge when isN42User=true', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(
            walletAddress: _address,
            isN42User: true,
          ),
        ));
        expect(find.text('N42'), findsOneWidget);
      });

      testWidgets('hides N42 badge when isN42User=false (default)', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        expect(find.text('N42'), findsNothing);
      });
    });

    group('message button', () {
      testWidgets('shows message button when onMessage is provided', (tester) async {
        await tester.pumpWidget(_buildCard(
          Web3IdentityCard(
            walletAddress: _address,
            isN42User: true,
            onMessage: () {},
          ),
        ));
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('hides message button when onMessage is null (default)', (tester) async {
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: _address),
        ));
        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('calls onMessage when button is tapped', (tester) async {
        var called = false;
        await tester.pumpWidget(_buildCard(
          Web3IdentityCard(
            walletAddress: _address,
            isN42User: true,
            onMessage: () => called = true,
          ),
        ));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(called, isTrue);
      });

      testWidgets('shows wallet-only hint when !isN42User and onMessage is set',
          (tester) async {
        await tester.pumpWidget(_buildCard(
          Web3IdentityCard(
            walletAddress: _address,
            isN42User: false,
            onMessage: () {},
          ),
        ));
        // Hint text fallback string from web3WalletOnlyHint
        expect(
          find.textContaining('no N42 account', findRichText: true),
          findsWidgets,
        );
      });

      testWidgets('hides wallet-only hint when isN42User=true', (tester) async {
        await tester.pumpWidget(_buildCard(
          Web3IdentityCard(
            walletAddress: _address,
            isN42User: true,
            onMessage: () {},
          ),
        ));
        expect(
          find.textContaining('no N42 account', findRichText: true),
          findsNothing,
        );
      });
    });

    group('short address edge cases', () {
      testWidgets('short address (≤12 chars) is shown as-is', (tester) async {
        const short = '0xDEADBEEF';
        await tester.pumpWidget(_buildCard(
          const Web3IdentityCard(walletAddress: short),
        ));
        // Should appear at least once (in name + address row)
        expect(find.text(short), findsAtLeastNWidgets(1));
      });
    });

    group('dark mode', () {
      testWidgets('renders without errors in dark mode', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Web3IdentityCard(
                walletAddress: _address,
                isDark: true,
                isN42User: true,
                isNftAvatar: true,
                ensName: 'alice.eth',
                onMessage: () {},
              ),
            ),
          ),
        ));
        expect(find.byType(Web3IdentityCard), findsOneWidget);
      });
    });
  });
}
