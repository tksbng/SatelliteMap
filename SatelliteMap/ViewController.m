//
//  ViewController.m
//  SatelliteMap
//
//  Created by Takeshi Bingo on 2013/08/31.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


//現在地を取得するメソッド
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //今いるユーザーの現在地を取得する
    CLLocationCoordinate2D newCenter = [[[aMap userLocation] location] coordinate];
    //もし、元々取得した緯度(または経度)と現在の緯度が異なる場合
    if (newCenter.latitude != curCenter.latitude || newCenter.longitude != curCenter.longitude){
        //新しく取得した緯度経度を現在地とする
        curCenter = newCenter;
    }
    return nil;
}
//加速度を取得するためのメソッド
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleratio
{
    //制限を加えて加速度の値を取得する（x,y,z軸それぞれ）
    accelX = (accelX * kFilteringFactor) + ([acceleratio x] * (1.0f - kFilteringFactor));
    accelY = (accelY * kFilteringFactor) + ([acceleratio y] * (1.0f - kFilteringFactor));
    accelZ = (accelZ * kFilteringFactor) + ([acceleratio z] * (1.0f - kFilteringFactor));
    
}
//　加速度センサを開始するメソッド
-(void)startAccelerometer {
    //　加速度センサを利用するために読み込む
    UIAccelerometer *theAccelerometer = [UIAccelerometer sharedAccelerometer];
    //　加速度センサを読み込む間隔を設定
    [theAccelerometer setUpdateInterval:(1.0f / kAccelerometerFrequency)];
    //　自分自身をデリゲートにセットして加速度センサを利用する
    [theAccelerometer setDelegate:self];
}
//　加速度センサを停止するメソッド
-(void)stopAccelerometer {
    // 加速度センサを利用するために読み込む
    UIAccelerometer *theAccelerometer = [UIAccelerometer sharedAccelerometer];
    //　加速度センサのデリゲートに何もセットせず、値を取得しない処理
    [theAccelerometer setDelegate:nil];
}

//　　地図を加速度にあわせて移動させるメソッド
- (void)tick:(NSTimer*)theTimer {
    //もし、中心地の緯度が存在するとき
    if ( curCenter.latitude ) {
        //地図から縮尺度を取得する
        MKCoordinateRegion regionOK = [aMap region];
        //現在地の中心を取得する
        CLLocationCoordinate2D center = regionOK.center;
        //加速度を加味して移動する距離を求める(緯度経度からメートル単位で値を算出)
        CGFloat dx = accelX * (distance/5.0f)/111.0f/1000.0f;
        CGFloat dy = accelY * (distance/5.0f)/111.0f/1000.0f;
        //　中心地に計算した移動距離分を加算する(X軸、Y軸それぞれ)
        center.longitude += dx;
        center.latitude += dy;
        
        //もし距離が300m以下になったら、
        if ( distance <= 300.0f ) {
            //タイマーを停止するメソッドを呼ぶ
            [self stopTimer];
            //加速度センサを終了するメソッドを呼ぶ
            [self stopAccelerometer];
            //距離を300mにする
            distance = 300.0f;
            MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(center, distance, distance);
            [aMap setRegion:region animated:YES];
            numEndingAnimation = 0;
            [self endingAnimation];
            //それ以外の場合
        } else {
            //distanceから、distanceの1/50の値を減らす
            distance -= (distance/50.0f);
            MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(center, distance, distance);
            [aMap setRegion:region animated:NO];
        }
        
        //加速度を加味した中心地に縮尺も併せて設定する
        //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, distance, distance);
        //アニメーションをつけながら位置を変更して移動する
        //[aMap setRegion:region animated:YES];
        //地図の左上の位置を設定する
        CLLocationCoordinate2D mapLeftTop = [aMap convertPoint:CGPointMake(0.0f, 0.0f) toCoordinateFromView:aMap];
        //地図の右下の値を設定する
        float screenSizeHeight =[[UIScreen mainScreen]bounds].size.height;
        CLLocationCoordinate2D mapRightBottom =
        [aMap convertPoint:CGPointMake(320.0f, screenSizeHeight) toCoordinateFromView:aMap];
        //もし、地図の右下の経度の値が180より大きくなった場合
        if (mapRightBottom.longitude > (+180.0f) ||
            //若しくは左上の経度の値が-180よりも小さくなった場合
            mapLeftTop.longitude < (-180.0f) ){
            //アニメーションをつけながら位置を変更する　
            [aMap setRegion:regionOK animated:YES];
        }
    }
}

//タイマーをストップさせるメソッド
-(void)stopTimer {
    //もしタイマーが存在するとき
    if ( aTimer ) {
        //タイマーを無効にする
        [aTimer invalidate];
        //タイマーに何もセットしない
        aTimer = nil;
    }
}
// タイマーを開始するメソッド
-(void)startTimer {
    //　もしタイマーが存在するなら
    if ( aTimer )
        //タイマーを終了させるメソッドを呼ぶ
        [self stopTimer];
    //タイマーをセットする
    aTimer = [NSTimer scheduledTimerWithTimeInterval:
              kTimerInterval target:self selector:@selector(tick:)
                                            userInfo:nil repeats:YES];
}

//　　エンディングアニメーションを行うメソッド
-(void)endingAnimation {
    //もし、アニメーション判別用の番号が0のとき
    if (numEndingAnimation == 0) {
        //アニメーション判別用の番号に1を足す
        numEndingAnimation++;
        //アニメーション条件の指定を開始
        [UIView beginAnimations:nil context:nil];
        //アニメーションの速度を設定 アニメーションを完了させるまでの秒数(float)
        [UIView setAnimationDuration:1.2f];
        //gradation2を表示させる
        [gradation2 setAlpha:1.0f];
        //デリゲートを自分自身に設定する
        [UIView setAnimationDelegate:self];
        //アニメーションが終了した後に呼ばれるメソッドを指定する
        [UIView setAnimationDidStopSelector:@selector(endingAnimation)];
        //アニメーションを開始する
        [UIView commitAnimations];
    }
    //もし、アニメーション判別用の番号が1のとき
    else if ( numEndingAnimation == 1 ) {
        //アニメーション判別用の番号に1を足す
        numEndingAnimation++;
        //オブジェクトを変形させるパラメータを設定
        CGAffineTransform t2 = CGAffineTransformMakeScale(1.0f, 0.4f);
        //マップの大きさを取得する
        CGRect r = [aMap frame];
        //マップの大きさの高さを30%にする
        float screenSizeHeight =[[UIScreen mainScreen]bounds].size.height;
        r.origin.y = screenSizeHeight * 0.3f;
        //アニメーション条件の指定を開始
        [UIView beginAnimations:nil context:nil];
        //アニメーションの速度を設定
        [UIView setAnimationDuration:2.0f];
        //先ほど設定したマップの大きさにする
        [aMap setFrame:r];
        //gradation2もマップと同じ大きさにする
        [gradation2 setFrame:r];
        //ピンの画像をパラメーターに従って変形する
        [pin setTransform:t2];
        //マップをパラメーターに従って変形する
        [aMap setTransform:t2];
        //gradation2をパラメーターに従って変形する
        [gradation2 setTransform:t2];
        //デリゲートを自分自身に設定する
        [UIView setAnimationDelegate:self];
        //アニメーションを停止させるメソッドを指定する
        [UIView setAnimationDidStopSelector:@selector(endingAnimation)];
        //アニメーションを開始する
        [UIView commitAnimations];
    }
    //もし、アニメーション判別用の番号が2のとき
    else if ( numEndingAnimation == 2 ) {
        //アニメーション判別用の番号に1を足す
        numEndingAnimation++;
        //マップの情報を取得する
        MKCoordinateRegion region = [aMap region];
        //マップの中心座標を取得する
        CLLocationCoordinate2D center = region.center;
        //マップの中心点を計算し取得する
        CGPoint pos = [aMap convertCoordinate:center toPointToView:[self view]];
        //アニメーション条件の指定を開始
        [UIView beginAnimations:nil context:nil];
        //アニメーションの速度を設定
        [UIView setAnimationDuration:2.0f];
        //ピンの場所をマップの中心点に移動させる
        [pin setCenter:pos];
        //デリゲートを自分自身に設定する
        [UIView setAnimationDelegate:self];
        //アニメーションを停止させるメソッドを指定する
        [UIView setAnimationDidStopSelector:@selector(endingAnimation)];
        //アニメーションを開始する
        [UIView commitAnimations];
    }
    //もし、アニメーション判別用の番号が3のとき
    else if ( numEndingAnimation == 3 ) {
        //アニメーション判別用の番号に1を足す
        numEndingAnimation++;
        //マップの情報を取得する
        MKCoordinateRegion region = [aMap region];
        //マップの中心座標を取得する
        CLLocationCoordinate2D center = region.center;
        //GPSから取得した現在地の緯度経度を取得する
        CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:curCenter.latitude longitude:curCenter.longitude];
        //アプリ上の地図の中心点の座標を取得する
        CLLocation *workLocation = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
        //現在地と地図の中心との距離を計算する
        CLLocationDistance resultDistance = [curLocation distanceFromLocation:workLocation];
        //計算した距離を引数にして、ラベルに表示させる
        [aLabel setText:[NSString stringWithFormat:@"距離 %.2f メートル",resultDistance]];
        //アニメーション条件の指定を開始
        [UIView beginAnimations:nil context:nil];
        //アニメーションの速度を設定
        [UIView setAnimationDuration:2.0f];
        //隠れていたラベルを表示させる
        [aLabel setAlpha:1.0f];
        //デリゲートを自分自身に設定する
        [UIView setAnimationDelegate:self];
        //アニメーションを停止させるメソッドを指定する
        [UIView setAnimationDidStopSelector:@selector(endingAnimation)];
        //アニメーションを開始する
        [UIView commitAnimations];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //MapViewのデリゲート
    [aMap setDelegate:self];
    // 加速度センサを開始するためのメソッドを呼ぶ
    [self startAccelerometer];
    //基準となる距離の初期値を設定
    distance = kDefaultDistance;
    //タイマーをスタートさせるメソッド
    [self startTimer];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
