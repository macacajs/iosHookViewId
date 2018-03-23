# iosHookViewId

---

A solution for ios hook view id(给iOS应用自动生成控件id)

# 特别说明
本思路来源于yulingtianxia的博客 http://yulingtianxia.com/blog/2016/03/28/Add-UITest-Label-for-UIAutomation/，后期得知作者已将源码开源，地址如下，大家也可以直接引用源码：
https://github.com/yulingtianxia/TBUIAutoTest
感谢原作者的分享及开源

# 使用说明

将如下四个文件拖进iOS项目目录下并参与编译即可生效(利用了OC的category特性)

```objc
iosHookViewId/hookViewId/UIResponder+UIAutoTest.h
iosHookViewId/hookViewId/UIResponder+UIAutoTest.m
iosHookViewId/hookViewId/UIView+UIAutoTest.h
iosHookViewId/hookViewId/UIView+UIAutoTest.m
```

