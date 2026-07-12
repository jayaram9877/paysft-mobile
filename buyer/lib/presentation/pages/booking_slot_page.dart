import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/property_details_model.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';
import 'main_tab_page.dart';

class BookingSlotPage extends StatefulWidget {
  final PropertyDetailsModel property;

  const BookingSlotPage({super.key, required this.property});

  @override
  State<BookingSlotPage> createState() => _BookingSlotPageState();
}

class _BookingSlotPageState extends State<BookingSlotPage> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _noteController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Set default date to tomorrow
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = [widget.property.mainImageUrl, ...widget.property.galleryImages];

    return Scaffold(
      backgroundColor: AppColors.backgroundGrayLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageAndPropertyInfoSection(images),
            _buildDateSection(),
            _buildAvailableTimeSection(),
            _buildNoteToBrokerSection(),
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final themeManager = ThemeManager();
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.bookingSlot,
        style: themeManager.bodyStyle.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
    );
  }

  Widget _buildImageAndPropertyInfoSection(List<String> images) {
    final themeManager = ThemeManager();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 232,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.gray300,
                            child: const Icon(Icons.image_not_supported, size: 64),
                          );
                        },
                      );
                    },
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ),
                  // Page indicator dots
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentPage ? AppColors.bluePrimary : AppColors.backgroundWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Property info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.property.title, style: themeManager.propertyTitleStyle),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundBlueVeryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.property.subtitle,
                            style: themeManager.propertySubtitleStyle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: AppColors.gray400),
                            const SizedBox(width: 4),
                            Text(
                              widget.property.location,
                              style: themeManager.propertyLocationStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.backgroundBlueSelected.withOpacity(0.1), shape: BoxShape.circle),
                    child: const AppSvgIcon(assetPath: 'assets/images/badge.svg', width: 24, height: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatFullDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildDateSection() {
    final themeManager = ThemeManager();
    final selectedDateText = _selectedDate != null ? _formatDate(_selectedDate!) : AppStrings.selectDate;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            AppStrings.date,
            style: themeManager.bookingSlotSectionTitleStyle,
          ),
          const SizedBox(height: 24),
          // Calendar icon, Date label, and date value
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Row(
              children: [
                const AppSvgIcon(assetPath: 'assets/images/booking_slot_calendar.svg', width: 36, height: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.date,
                        style: themeManager.bookingSlotDateLabelStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDateText,
                        style: themeManager.bookingSlotDateValueStyle,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          Divider(color: AppColors.borderGrayMedium, height: 1),
          const SizedBox(height: 16),
          // Description
          Text(
            AppStrings.dateCheckMessage,
            style: themeManager.bookingSlotDateLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTimeSection() {
    final themeManager = ThemeManager();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.availableTime,
            style: themeManager.bookingSlotSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          _buildTimeCategory(AppStrings.morning, ['10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM']),
          const SizedBox(height: 16),
          _buildTimeCategory(AppStrings.afternoon, ['01:30 PM', '02:00 PM', '03:00 PM']),
          const SizedBox(height: 16),
          _buildTimeCategory(AppStrings.evening, ['05:00 PM', '05:30 PM', '06:00 PM']),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderGrayMedium, height: 1),
          const SizedBox(height: 16),
          Text(
            AppStrings.timeCheckMessage,
            style: themeManager.bookingSlotDateLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCategory(String category, List<String> times) {
    final themeManager = ThemeManager();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: themeManager.bookingSlotTimeCategoryStyle,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: times.map((time) {
            final isSelected = _selectedTime == time;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = isSelected ? null : time;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.backgroundBlueVeryLight : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.bluePrimary : AppColors.borderGrayMedium, width: 1),
                ),
                child: Text(
                  time,
                  style: themeManager.bookingSlotTimeChipStyle,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteToBrokerSection() {
    final themeManager = ThemeManager();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.noteToBroker,
            style: themeManager.bookingSlotSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLength: 100,
            maxLines: 4,
            decoration: themeManager.textFieldDecoration(
              hintText: AppStrings.placeholder,
            ).copyWith(
              counterText: '${_noteController.text.length}/100',
              counterStyle: themeManager.captionSmallStyle.copyWith(fontSize: 12),
            ),
            onChanged: (value) {
              setState(() {}); // Update counter
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: SecondaryGrayButton(text: AppStrings.cancel, onTap: () => Navigator.pop(context)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryGradientButton(text: AppStrings.confirm, onTap: _handleConfirm),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirm() {
    // Validate date and time
    if (_selectedDate == null) {
      _showValidationError(AppStrings.pleaseSelectDate);
      return;
    }

    if (_selectedTime == null) {
      _showValidationError(AppStrings.pleaseSelectTime);
      return;
    }

    // If both are selected, show success popup
    _showBookingSuccessPopup();
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.validationError),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.ok))],
      ),
    );
  }

  void _showBookingSuccessPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _BookingSuccessPopup(
        onBookingDetailsTap: () => Navigator.pop(context),
        onExploreMoreTap: () {
          Navigator.pop(context); // Close success popup
          Navigator.pop(context); // Close booking slot page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainTabPage()),
            (route) => false,
          );
        },
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final maxDate = tomorrow.add(const Duration(days: 6)); // Next 7 days

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CalendarPicker(
        selectedDate: _selectedDate,
        minDate: tomorrow,
        maxDate: maxDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CalendarPicker extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime minDate;
  final DateTime maxDate;
  final Function(DateTime) onDateSelected;

  const _CalendarPicker({
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.onDateSelected,
  });

  @override
  State<_CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<_CalendarPicker> {
  late DateTime _currentMonth;
  DateTime? _tempSelectedDate;

  @override
  void initState() {
    super.initState();
    // Start with the month that contains the minDate
    _currentMonth = DateTime(widget.minDate.year, widget.minDate.month);
    _tempSelectedDate = widget.selectedDate;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Get the weekday of the first day (0 = Sunday, 6 = Saturday)
    final firstWeekday = firstDay.weekday % 7;

    // Get days from previous month
    final previousMonth = DateTime(month.year, month.month - 1, 0);
    final daysFromPreviousMonth = previousMonth.day;

    List<DateTime> days = [];

    // Add days from previous month
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(month.year, month.month - 1, daysFromPreviousMonth - i));
    }

    // Add days from current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Add days from next month to fill the grid (6 rows * 7 days = 42)
    final remainingDays = 42 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  bool _isDateSelectable(DateTime date) {
    // Normalize dates to compare only year, month, day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedMin = DateTime(widget.minDate.year, widget.minDate.month, widget.minDate.day);
    final normalizedMax = DateTime(widget.maxDate.year, widget.maxDate.month, widget.maxDate.day);

    return (normalizedDate.isAfter(normalizedMin.subtract(const Duration(days: 1))) &&
        normalizedDate.isBefore(normalizedMax.add(const Duration(days: 1))));
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }

  bool _canGoToPreviousMonth() {
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    return prevMonth.year > widget.minDate.year ||
        (prevMonth.year == widget.minDate.year && prevMonth.month >= widget.minDate.month);
  }

  bool _canGoToNextMonth() {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    return nextMonth.year < widget.maxDate.year ||
        (nextMonth.year == widget.maxDate.year && nextMonth.month <= widget.maxDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final days = _getDaysInMonth(_currentMonth);

    return Container(
      margin: const EdgeInsets.all(16), // 20px gap on all sides
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24), // Round rectangle on all sides
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20), // 20px padding inside the container
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
              ),

              // Title
              Text(AppStrings.selectDate, textAlign: TextAlign.center, style: themeManager.selectDateTitleStyle),
              const SizedBox(height: 20),

              // Calendar icon and info
              Row(
                children: [
                  const AppSvgIcon(assetPath: 'assets/images/booking_slot_calendar.svg', width: 36, height: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.calendar, style: themeManager.calendarTextStyle),
                      Text(AppStrings.setDateOnYourCalendar, style: themeManager.calendarSubtitleStyle),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider line
              Divider(color: AppColors.borderGrayMedium, height: 1),
              const SizedBox(height: 24),

              // Month navigation with circular arrow buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_getMonthName(_currentMonth)} ${_currentMonth.year}', style: themeManager.monthYearTextStyle),
                  Row(
                    children: [
                      // Previous month button - circular
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: _canGoToPreviousMonth()
                                ? AppColors.textDarkSecondary
                                : AppColors.textDarkSecondary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                            color: _canGoToPreviousMonth()
                                ? AppColors.textDarkSecondary
                                : AppColors.textDarkSecondary.withOpacity(0.3),
                          ),
                          onPressed: _canGoToPreviousMonth()
                              ? () {
                                  setState(() {
                                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                                  });
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Next month button - circular
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: _canGoToNextMonth()
                                ? AppColors.textDarkSecondary
                                : AppColors.textDarkSecondary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: _canGoToNextMonth() ? AppColors.textDarkSecondary : AppColors.textDarkSecondary.withOpacity(0.3),
                          ),
                          onPressed: _canGoToNextMonth()
                              ? () {
                                  setState(() {
                                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar grid in round rectangle container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGrayMedium, width: 1),
                ),
                child: Column(
                  children: [
                    // Day headers
                    Row(
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map(
                            (day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: themeManager.calendarDayHeaderStyle,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.borderGrayMedium, height: 1),
                    const SizedBox(height: 12),
                    // Calendar grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        final date = days[index];
                        final isCurrentMonthDay = date.month == _currentMonth.month;
                        final isSelectable = _isDateSelectable(date);
                        final isSelected = _isSameDay(_tempSelectedDate, date);

                        return GestureDetector(
                          onTap: isSelectable
                              ? () {
                                  setState(() {
                                    _tempSelectedDate = date;
                                  });
                                }
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.bluePrimary : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: isSelected
                                    ? themeManager.calendarDayNumberSelectedStyle
                                    : (isCurrentMonthDay
                                          ? (isSelectable
                                              ? themeManager.calendarDayNumberUnselectedStyle
                                              : themeManager.calendarDayNumberDisabledStyle)
                                          : themeManager.calendarDayNumberDisabledStyle),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryGradientButton(
                  text: AppStrings.save,
                  onTap: () {
                    if (_tempSelectedDate != null) {
                      widget.onDateSelected(_tempSelectedDate!);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingSuccessPopup extends StatelessWidget {
  final VoidCallback onBookingDetailsTap;
  final VoidCallback onExploreMoreTap;

  const _BookingSuccessPopup({required this.onBookingDetailsTap, required this.onExploreMoreTap});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return SizedBox(
      height: 538,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
              ),

              // SVG Icon
              const AppSvgIcon(assetPath: 'assets/images/bookingconrimed.svg', width: 208, height: 208),

              const SizedBox(height: 24),

              // Success title
              Text(
                AppStrings.bookingSuccessTitle,
                textAlign: TextAlign.center,
                style: themeManager.bookingSuccessTitleStyle,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                AppStrings.bookingSuccessDescription,
                textAlign: TextAlign.center,
                style: themeManager.bookingSuccessDescriptionStyle,
              ),

              const SizedBox(height: 24),

              // Booking Details with underline
              Column(
                children: [
                  GestureDetector(
                    onTap: onBookingDetailsTap,
                    child: Text(
                      AppStrings.bookingDetails,
                      textAlign: TextAlign.center,
                      style: themeManager.bookingDetailsLinkStyle,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(height: 1, width: 120, color: AppColors.bluePrimary),
                ],
              ),

              const SizedBox(height: 24),

              // Explore more button
              PrimaryGradientButton(text: AppStrings.exploreMore, onTap: onExploreMoreTap),
            ],
          ),
        ),
      ),
    );
  }
}
