import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_view.dart';
import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/pages/login/login_viewmodel.dart';
import 'package:flutter_mvvm/pages/login/login_page_extensions.dart';



/// 登录页面View
class LoginPage extends BaseView<LoginViewModel> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginViewModel createViewModel() => LoginViewModel();

  @override
  bool get showAppBar => false;

  @override
  Widget buildContent(BuildContext context) {
    return buildLoginBackground(
      context,
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ScreenAdapter.setHeight(60)),
              buildLoginHeader(context),
              SizedBox(height: ScreenAdapter.setHeight(40)),
              buildLoginForm(context, viewModel),
              SizedBox(height: ScreenAdapter.setHeight(24)),
              buildLoginButton(context, viewModel),
              SizedBox(height: ScreenAdapter.setHeight(16)),
              buildForgotPasswordLink(context, viewModel),
              SizedBox(height: ScreenAdapter.setHeight(40)),
              buildRegisterLink(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }
}