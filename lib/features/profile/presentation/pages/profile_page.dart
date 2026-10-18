import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your cart and wishlist on this device will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    // The user saved at sign-in fills the header straight away, even offline;
    // /auth/me adds the contact details.
    final user = context.select(
      (AuthCubit cubit) => switch (cubit.state) {
        Authenticated(:final user) => user,
        _ => null,
      },
    );
    final state = context.watch<ProfileCubit>().state;
    final profile = switch (state) {
      ProfileLoaded(:final profile) => profile,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProfileCubit>().load(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _Header(
                  name: profile?.fullName ?? user?.fullName ?? '',
                  username: profile?.username ?? user?.username ?? '',
                  image: profile?.image ?? user?.image,
                ),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: switch (state) {
                    ProfileLoaded(:final profile) => _ContactDetails(profile),
                    ProfileLoading() => const _ContactDetailsSkeleton(),
                    ProfileError(:final failure) => ListTile(
                      leading: const Icon(Icons.cloud_off_rounded),
                      title: const Text("Couldn't load your details"),
                      subtitle: Text(failure.message),
                      trailing: TextButton(
                        onPressed: () => context.read<ProfileCubit>().load(),
                        child: const Text('Retry'),
                      ),
                    ),
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.username, this.image});

  final String name;
  final String username;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = this.image;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: image == null
              ? null
              : CachedNetworkImageProvider(image),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          name,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (username.isNotEmpty)
          Text(
            '@$username',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails(this.profile);

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.mail_outline_rounded),
          title: const Text('Email'),
          subtitle: Text(profile.email),
        ),
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: const Text('Phone'),
          subtitle: Text(profile.phone),
        ),
        if (profile.location case final location?)
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Location'),
            subtitle: Text(location),
          ),
      ],
    );
  }
}

class _ContactDetailsSkeleton extends StatelessWidget {
  const _ContactDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            const ListTile(
              leading: ShimmerBox(width: 24, height: 24, radius: 12),
              title: ShimmerBox(width: 80, height: 14),
              subtitle: Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: ShimmerBox(width: 180, height: 12),
              ),
            ),
        ],
      ),
    );
  }
}
