//
//  CCCVisualConstants.h
//  YourCoast
//
//  Created by Tyson on 2018-03-02.
//  Copyright © 2018 MetaLab. All rights reserved.
//

NS_INLINE CGFloat SafeBottomInset()
{
    CGFloat safeBottomInset = 0;
    if (@available(iOS 11, *))
    {
        safeBottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    return safeBottomInset;
}
