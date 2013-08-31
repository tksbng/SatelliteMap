//
//  ViewController.h
//  SatelliteMap
//
//  Created by Takeshi Bingo on 2013/08/31.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKUserLocation.h>
// 加速度センサから値を取得するための間隔
#define kAccelerometerFrequency 20.0f
// 加速度センサから取得する値を制限する
#define kFilteringFactor 0.98f
//　　タイマーの間隔
#define kTimerInterval 0.1f
//　　地図の縮尺を判断するデフォルトの値
#define kDefaultDistance (111.0f * 1000.0f * 90.0f)

@interface ViewController : UIViewController
<
//MapView用
MKMapViewDelegate
// 加速度センサ
,UIAccelerometerDelegate
>

    
{
    //エンディングアニメーション番号
    NSInteger numEndingAnimation;

    //地図を移動させるためのタイマー
    NSTimer* aTimer;
    //縮尺を判断するための長さ
    CLLocationDistance distance;
    //加速度センサから取得した値を格納する変数
    UIAccelerationValue accelX, accelY, accelZ;
    //　現在地取得用
    CLLocationCoordinate2D curCenter;
    //　地図表示用
    IBOutlet MKMapView *aMap;
    //　画面中心のピン
    IBOutlet UIImageView *pin;
    //　演出効果用グラデーション
    IBOutlet UIImageView *gradation2;
    //　結果表示用ラベル
    IBOutlet UILabel *aLabel;
}
@end
