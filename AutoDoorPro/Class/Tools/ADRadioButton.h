//
//  ADRadioButton.h
//  AutoDoorPro
//
//  Created by 梁彬 on 2017/7/26.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectedBlock)(NSInteger index);

@interface ADRadioButton : UIView

/**
 每行多少个
 */
@property (nonatomic,assign) NSInteger rowCount;

/**
 按钮的资源(名字、图片)
 */
@property (nonatomic,copy) NSArray *buttonSettings;

@property (nonatomic,copy) selectedBlock block;

@property (nonatomic,assign) NSInteger selectedIndex;





@end


@class ADRadioButtonCellModel;

typedef void(^touchBlock)();

@interface ADRadioButtonCell : UICollectionViewCell

@property (nonatomic,strong) ADRadioButtonCellModel *model;

@property (nonatomic,copy) touchBlock block;



@end

@interface ADRadioButtonCellModel : NSObject


@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *iconName;

@property (nonatomic,assign) BOOL isSelected;

@end
