import 'package:flutter/material.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/admob/banner_ad_load_widget.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, this.from});

  final String? from;

  @override
  State<CategoryList> createState() => _CategoryListState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => CategoryList(from: args?['from']?.toString() ?? ''),
    );
  }
}

class _CategoryListState extends State<CategoryList>
    with TickerProviderStateMixin {
  final ScrollController _pageScrollController = ScrollController();
  late AnimationController _gridController;
  late Animation<double> _gridFadeAnimation;

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _gridFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gridController,
        curve: Curves.easeIn,
      ),
    );

    _initCategories();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  Future<void> _initCategories() async {
    await context.read<FetchCategoryCubit>().fetchCategories();
    if (mounted) {
      _gridController.forward();
    }
    
    _pageScrollController.addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchCategoryCubit>().hasMoreData()) {
          context.read<FetchCategoryCubit>().fetchCategoriesMore();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: CustomAppBar(
        title: CustomText(UiUtils.translate(context, 'categoriesLbl')),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
        builder: (context, state) {
          final isTablet = ResponsiveHelper.isTablet(context) ||
              ResponsiveHelper.isLargeTablet(context);
          
          if (state is FetchCategoryInProgress) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 5 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) => const CustomShimmer(borderRadius: 20),
            );
          }

          if (state is FetchCategorySuccess) {
            return FadeTransition(
              opacity: _gridFadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _pageScrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: state.categories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 5 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return _buildCategoryItem(context, category, index);
                      },
                    ),
                  ),
                  if (state.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: UiUtils.progress(),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, dynamic category, int index) {
    return GestureDetector(
      onTap: () {
        if (widget.from == Routes.filterScreen) {
          Navigator.pop(context, category);
        } else {
          Constant.propertyFilter = null;
          HelperUtils.goToNextPage(
            Routes.propertiesList,
            context,
            false,
            args: {
              'catID': category.id,
              'catName': category.translatedName ?? category.category,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: context.color.borderColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54.rw(context),
              height: 54.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CustomImage(
                  imageUrl: category.image ?? '',
                  width: 32.rw(context),
                  height: 32.rh(context),
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CustomText(
                category.translatedName ?? category.category ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.color.textColorDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
