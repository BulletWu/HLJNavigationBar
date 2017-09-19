Pod::Spec.new do |s|
  s.name             = 'HLJNavigationBar'
  s.version          = '0.1.1'
  s.summary          = '导航栏处理 HLJNavigationBar.'

  s.description      = <<-DESC
                        1.提供2种方法处理导航栏隐藏显示
                        ／*
                        hlj_prefersNavigationBarHidden ,直接hidden导航栏
                        hlj_navBarBgAlpha,修改透明度
                        *／
                        2.导航栏颜色可变
                        3.导航栏颜色，透明度变化，过渡
                        4.自定义返回按钮，不使用leftBarButtonItem
                        5.支持 滑动，点击返回事件的回调
                        /*
                        - (BOOL)navigationShouldPop; //是否允许触发返
                        - (void)navigationDidPop;//pop成功 ，因为侧滑返回可能取消
                        - (void)navigationPopCancel;//侧滑返回取消
                        */
                        6.支持状态栏颜色智能根据背景色 改变
                        /*
                        损失一点空闲的cpu，去做（大家考虑使用）
                        */
                        7.支持动态更新切换NavigationItem
                       DESC

  s.homepage         = 'https://github.com/BulletWu/HLJNavigationBar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bullet_wu' => 'bullet_wu@163.com' }
  s.source           = { :git => 'https://github.com/BulletWu/HLJNavigationBar.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'HLJNavigationBar/Classes/**/*'
end
