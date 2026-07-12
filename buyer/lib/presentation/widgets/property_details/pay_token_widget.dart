import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_string_constants.dart';
import '../../pages/pay_token/pay_token_flow_page.dart';
import '../primary_blue_button.dart';

class PayTokenWidget extends StatelessWidget {
  final BoxDecoration? decoration;

  const PayTokenWidget({super.key, this.decoration});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Container(
      decoration: decoration ?? themeManager.payTokenSectionDecorationCommercial,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.payTokenDescription,
            style: TextStyle(color: AppColors.darkBlue, fontFamily: AppStrings.fontFamilyText, fontSize: 13),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: PrimaryGradientButton(
                      text: AppStrings.payToken,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PayTokenFlowPage()));
                      },
                      borderRadius: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/images/token_title_icon.svg", width: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.tokenTitle,
                          style: TextStyle(
                            color: AppColors.tokenTitleColor,
                            fontFamily: AppStrings.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppStrings.tokenTitleDescription,
                    style: TextStyle(color: AppColors.textGray80, fontFamily: AppStrings.fontFamilyText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
