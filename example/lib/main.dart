import 'package:flutter/material.dart';
import 'package:deeplink_sdk/deeplink_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepLink SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DeepLinkExampleScreen(),
    );
  }
}

class DeepLinkExampleScreen extends StatefulWidget {
  const DeepLinkExampleScreen({super.key});

  @override
  State<DeepLinkExampleScreen> createState() => _DeepLinkExampleScreenState();
}

class _DeepLinkExampleScreenState extends State<DeepLinkExampleScreen> {
  final List<DeepLinkData> _deepLinkHistory = [];
  String _currentRoute = '/';
  Map<String, dynamic> _routeParams = {};

  @override
  void initState() {
    super.initState();
    _initializeDeepLinking();
  }

  Future<void> _initializeDeepLinking() async {
    // Configure deep link handler
    final config = DeepLinkConfig(
      defaultScheme: 'myapp',
      defaultHost: 'example.com',
      allowedSchemes: ['myapp', 'https', 'http'],
      allowedHosts: ['example.com', 'app.example.com'],
      enableLogging: true,
      errorHandler: (url, error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deep link error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // Initialize the handler
    await DeepLinkHandler.instance.initialize(
      config: config,
      observers: [
        LoggingDeepLinkObserver(),
        AnalyticsDeepLinkObserver(
          trackEvent: (event, params) {
            print('Analytics Event: $event');
            print('Parameters: $params');
          },
        ),
      ],
    );

    // Set the context for routing
    DeepLinkHandler.instance.router.setContext(context);

    // Register routes
    _registerRoutes();

    // Listen to deep link stream
    DeepLinkHandler.instance.deepLinkStream.listen((deepLinkData) {
      setState(() {
        _deepLinkHistory.add(deepLinkData);
      });
    });
  }

  void _registerRoutes() {
    DeepLinkHandler.instance.registerRoutes({
      '/': (context, params) async {
        setState(() {
          _currentRoute = '/';
          _routeParams = params.allParameters;
        });
        _showRouteSnackBar('Home', params);
        return true;
      },
      '/product/:id': (context, params) async {
        setState(() {
          _currentRoute = '/product/${params.pathParam('id')}';
          _routeParams = params.allParameters;
        });
        _showRouteSnackBar('Product', params);
        return true;
      },
      '/user/:userId/profile': (context, params) async {
        setState(() {
          _currentRoute = '/user/${params.pathParam('userId')}/profile';
          _routeParams = params.allParameters;
        });
        _showRouteSnackBar('User Profile', params);
        return true;
      },
      '/search': (context, params) async {
        setState(() {
          _currentRoute = '/search';
          _routeParams = params.allParameters;
        });
        _showRouteSnackBar('Search', params);
        return true;
      },
      '/settings/*section': (context, params) async {
        setState(() {
          _currentRoute = '/settings/${params.pathParam('section')}';
          _routeParams = params.allParameters;
        });
        _showRouteSnackBar('Settings', params);
        return true;
      },
    });
  }

  void _showRouteSnackBar(String routeName, RouteParams params) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigated to: $routeName'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Params',
          onPressed: () {
            _showParamsDialog(params);
          },
        ),
      ),
    );
  }

  void _showParamsDialog(RouteParams params) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Route Parameters'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Path Parameters:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...params.pathParameters.entries
                  .map((e) => Text('${e.key}: ${e.value}')),
              const SizedBox(height: 16),
              const Text('Query Parameters:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...params.queryParameters.entries
                  .map((e) => Text('${e.key}: ${e.value}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _testDeepLink(String url) {
    DeepLinkHandler.instance.handleDeepLink(url);
  }

  void _clearHistory() {
    setState(() {
      _deepLinkHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeepLink SDK Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Route',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentRoute,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'monospace',
                            color: Colors.blue,
                          ),
                    ),
                    if (_routeParams.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Parameters:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ..._routeParams.entries.map(
                        (e) => Text('${e.key}: ${e.value}'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test Deep Links',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _testDeepLink('myapp://example.com/'),
                  child: const Text('Home'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _testDeepLink('myapp://example.com/product/123'),
                  child: const Text('Product 123'),
                ),
                ElevatedButton(
                  onPressed: () => _testDeepLink(
                      'myapp://example.com/user/456/profile?tab=posts'),
                  child: const Text('User Profile'),
                ),
                ElevatedButton(
                  onPressed: () => _testDeepLink(
                      'myapp://example.com/search?q=flutter&category=mobile'),
                  child: const Text('Search'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _testDeepLink('myapp://example.com/settings/privacy'),
                  child: const Text('Settings'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _testDeepLink('https://example.com/product/789'),
                  child: const Text('Web Link'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Deep Link History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (_deepLinkHistory.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No deep links received yet'),
                ),
              )
            else
              ..._deepLinkHistory.reversed.map(
                (deepLink) => Card(
                  child: ListTile(
                    leading: Icon(
                      deepLink.source == DeepLinkSource.internal
                          ? Icons.home
                          : Icons.link,
                      color: deepLink.source == DeepLinkSource.internal
                          ? Colors.blue
                          : Colors.green,
                    ),
                    title: Text(
                      deepLink.uri.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: Text(
                      '${deepLink.source.toString().split('.').last} - ${deepLink.timestamp.toString()}',
                    ),
                    onTap: () => _showDeepLinkDetails(deepLink),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomDeepLinkDialog(),
        tooltip: 'Test Custom Deep Link',
        child: const Icon(Icons.add_link),
      ),
    );
  }

  void _showDeepLinkDetails(DeepLinkData deepLink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deep Link Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('URL', deepLink.uri.toString()),
              _buildDetailRow('Scheme', deepLink.scheme),
              _buildDetailRow('Host', deepLink.host ?? 'N/A'),
              _buildDetailRow('Path', deepLink.path),
              _buildDetailRow('Source', deepLink.source.toString()),
              _buildDetailRow('Timestamp', deepLink.timestamp.toString()),
              if (deepLink.queryParameters.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Query Parameters:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...deepLink.queryParameters.entries
                    .map((e) => Text('${e.key}: ${e.value}')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showCustomDeepLinkDialog() {
    final controller = TextEditingController(text: 'myapp://example.com/');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Custom Deep Link'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Deep Link URL',
            hintText: 'myapp://example.com/path',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _testDeepLink(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Test'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    DeepLinkHandler.instance.dispose();
    super.dispose();
  }
}
