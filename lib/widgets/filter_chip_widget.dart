import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/dto/listing_filter.dart';
import '../movie_list/controller/movie_list_controller.dart';


class FilterChipWidget extends StatelessWidget {
  final MovieListController controller;

  const FilterChipWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ListingFilter.predefinedFilters.length,
        itemBuilder: (context, index) {
          final filter = ListingFilter.predefinedFilters[index];
          return _buildFilterChip(filter);
        },
      ),
    );
  }

  Widget _buildFilterChip(ListingFilter filter) {
    return GetBuilder<MovieListController>(
      id: 'filter_${filter.title}', // Unique ID for this specific chip
      builder: (controller) {
        final isSelected = controller.selectedFilter.value?.title == filter.title;

        return Container(
          margin: const EdgeInsets.only(right: 12),
          child: FilterChip(
            label: Text(
              filter.displayName,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                controller.loadMoviesWithFilter(filter);
              }
            },
            backgroundColor: Colors.grey[800],
            selectedColor: Colors.white,
            checkmarkColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.grey[600]!,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}

class FilterChipWidgetWithController extends StatelessWidget {
  final MovieListController controller;

  const FilterChipWidgetWithController({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ListingFilter.predefinedFilters.length,
        itemBuilder: (context, index) {
          final filter = ListingFilter.predefinedFilters[index];
          final isSelected = controller.selectedFilter.value?.title == filter.title;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.loadMoviesWithFilter(filter);
                }
              },
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.white : Colors.grey[600]!,
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      )),
    );
  }
}

