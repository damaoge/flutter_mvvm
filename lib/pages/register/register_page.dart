import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_view.dart';
import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/pages/register/register_viewmodel.dart';
import 'package:flutter_mvvm/pages/register/register_page_extensions.dart';
/// 注册页面
class RegisterPage extends BaseView<RegisterViewModel> {
  const RegisterPage({super.key});

  @override
  RegisterViewModel createViewModel() => RegisterViewModel();

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      body: buildRegisterPageBackground(
        context,
        SingleChildScrollView(
          padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ScreenAdapter.setHeight(60)),
              
              // 页面标题
              buildRegisterHeader(context),
              
              SizedBox(height: ScreenAdapter.setHeight(40)),
              
              // 注册表单
              buildRegisterForm(context, viewModel),
              
              SizedBox(height: ScreenAdapter.setHeight(16)),
              
              // 条款同意
              buildTermsAgreement(context, viewModel),
              
              SizedBox(height: ScreenAdapter.setHeight(32)),
              
              // 注册按钮
              buildRegisterButton(context, viewModel),
              
              SizedBox(height: ScreenAdapter.setHeight(24)),
              
              // 登录链接
              buildLoginLink(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }
}