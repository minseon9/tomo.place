import 'package:app/domains/auth/core/entities/authentication_result.dart';
import 'package:flutter/material.dart';

class AuthStatusCard extends StatelessWidget {
  const AuthStatusCard({
    super.key,
    required this.authResult,
    this.onRefresh,
    this.onLogout,
  });

  final AuthenticationResult authResult;
  final VoidCallback? onRefresh;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16.0),
            _buildStatusInfo(),
            const SizedBox(height: 16.0),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(_getStatusIcon(), color: _getStatusColor(), size: 24.0),
        const SizedBox(width: 8.0),
        Text(
          'Authentication Status',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: _getStatusColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status: ${_getStatusText()}',
          style: const TextStyle(fontSize: 16.0),
        ),
        if (authResult.message != null) ...[
          const SizedBox(height: 8.0),
          Text(
            'Message: ${authResult.message}',
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        ],
        if (authResult.token != null) ...[
          const SizedBox(height: 8.0),
          Text(
            'Access Token: ${authResult.token!.accessToken.substring(0, 10)}...',
            style: const TextStyle(fontSize: 12.0, fontFamily: 'monospace'),
          ),
          Text(
            'Expires: ${_formatDateTime(authResult.token!.accessTokenExpiresAt)}',
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onRefresh != null)
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        if (onRefresh != null && onLogout != null) const SizedBox(width: 8.0),
        if (onLogout != null)
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (authResult.status) {
      case AuthenticationStatus.authenticated:
        return Icons.check_circle;
      case AuthenticationStatus.unauthenticated:
        return Icons.cancel;
      case AuthenticationStatus.expired:
        return Icons.warning;
    }
  }

  Color _getStatusColor() {
    switch (authResult.status) {
      case AuthenticationStatus.authenticated:
        return Colors.green;
      case AuthenticationStatus.unauthenticated:
        return Colors.red;
      case AuthenticationStatus.expired:
        return Colors.orange;
    }
  }

  String _getStatusText() {
    switch (authResult.status) {
      case AuthenticationStatus.authenticated:
        return 'Authenticated';
      case AuthenticationStatus.unauthenticated:
        return 'Unauthenticated';
      case AuthenticationStatus.expired:
        return 'Expired';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
