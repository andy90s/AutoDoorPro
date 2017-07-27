//
//  ADRadioButton.m
//  AutoDoorPro
//
//  Created by 梁彬 on 2017/7/26.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "ADRadioButton.h"

@interface ADRadioButton()<UICollectionViewDelegate,UICollectionViewDataSource> {
    
    
}

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong) __block NSMutableArray *dataArray;

@end

@implementation ADRadioButton

- (instancetype)init {
    if (self = [super init]) {
        //[self setupUserInterface];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setupUserInterface];
    }
    return self;
}



- (void)setupUserInterface {
    
    [self addSubview:self.collectionView];
}

- (void)setButtonSettings:(NSArray *)buttonSettings {
    
    for (NSArray *array in buttonSettings) {
        ADRadioButtonCellModel *model = [ADRadioButtonCellModel new];
        model.title = array[0];
        model.iconName = array[1];
        model.isSelected = NO;
        [self.dataArray addObject:model];
    }
    _buttonSettings = buttonSettings;
    
    [self.collectionView reloadData];
}

- (void)setRowCount:(NSInteger)rowCount {
    _rowCount = rowCount;
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    ADRadioButtonCellModel *model = self.dataArray[_selectedIndex];
    model.isSelected = YES;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ADRadioButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ADRadioButtonCell" forIndexPath:indexPath];
    ADRadioButtonCellModel *model = self.dataArray[indexPath.item];
    [cell setModel:model];
    
    weakify(self);
    cell.block = ^() {
        strongify(self);
        for (ADRadioButtonCellModel *model in self.dataArray) {
            model.isSelected = NO;
        }
        model.isSelected = YES;
        
        [self.collectionView reloadData];
        
        if (_block) {
            _block(indexPath.item);
        }
    };
    
    
    return cell;
}

#pragma mark - lazy

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds
    collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = false;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ADRadioButtonCell class] forCellWithReuseIdentifier:@"ADRadioButtonCell"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [UICollectionViewFlowLayout new];
        _flowLayout.itemSize = CGSizeMake(self.bounds.size.width/3, self.bounds.size.height);
        _flowLayout.minimumLineSpacing = 0.f;
        _flowLayout.minimumInteritemSpacing = 0.f;
    }
    return _flowLayout;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

@end

@interface ADRadioButtonCell()

/**
 图片按钮
 */
@property (nonatomic,strong) UIButton *iconButton;

/**
 标题
 */
@property (nonatomic,strong) UILabel *titleLabel;



@end

@implementation ADRadioButtonCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.iconButton];
        [self.contentView addSubview:self.titleLabel];
        [self configMasonry];
    }
    return self;
}

- (void)buttonClick {
    if (_block) {
        _block();
    }
}


- (void)setModel:(ADRadioButtonCellModel *)model {
    _model = model;
    self.titleLabel.text = _model.title;
    if (model.isSelected) {
        [self.iconButton setImage:[UIImage imageNamed:@"iconselected"] forState:UIControlStateNormal];
    } else {
        [self.iconButton setImage:[UIImage imageNamed:@"iconunselected"] forState:UIControlStateNormal];
    }
}

- (void)configMasonry {
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.height.width.offset(30);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconButton.mas_right);
    }];
}

- (UIButton *)iconButton {
    if (!_iconButton) {
        _iconButton = [UIButton new];
        [_iconButton setImage:[UIImage imageNamed:@"iconunselected"] forState:UIControlStateNormal];
        [_iconButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}


@end

@implementation ADRadioButtonCellModel


@end
