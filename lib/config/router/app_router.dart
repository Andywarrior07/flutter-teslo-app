import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/router/app_router_notifier.dart';
import 'package:teslo_shop/features/auth/auth.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:teslo_shop/features/products/products.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
      initialLocation: '/splash',
      refreshListenable: goRouterNotifier,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const CheckAuthScreen(),
        ),

        ///* Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        ///* Product Routes
        GoRoute(
          path: '/',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/product/:productId',
          builder: (context, state) => ProductScreen(
            productId: state.params['productId'] ?? 'no-id',
          ),
        ),
      ],
      redirect: (context, state) {
        final goingTo = state.subloc;
        final authStatus = goRouterNotifier.authStatus;
        print('GoRouter authStatus: $authStatus, isGoingTo: $goingTo');
        if (goingTo == '/splash' && authStatus == AuthStatus.checking) {
          return null;
        }

        if (authStatus == AuthStatus.unauthenticated) {
          if (goingTo == '/login' || goingTo == '/register') return null;

          return '/login';
        }

        if (authStatus == AuthStatus.authenticated) {
          if (goingTo == '/login' ||
              goingTo == '/register' ||
              goingTo == '/splash') return '/';
        }

        return null;
      });
});
