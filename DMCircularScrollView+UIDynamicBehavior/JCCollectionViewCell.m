//
//  JCCollectionViewCell.m
//  DMCircularScrollView+UIDynamicBehavior
//
//  Created by Test OSX9 on 2015/11/2.
//
//

#import "JCCollectionViewCell.h"
#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (Shared)
+(CMMotionManager*)sharedMotionManager;
@end
@implementation CMMotionManager (Shared)

static CMMotionManager *motionmanager;
+ (CMMotionManager *)sharedMotionManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionmanager = [[CMMotionManager alloc] init];
    });
    return motionmanager;
}

@end


@implementation JCCollectionViewCell

-(void)cleanSubViews
{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
}

- (UIColor *) randomColor
{
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

-(void)startAnimation{
 
    [self cleanSubViews];
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(44, 0, 222, 222)];
    imageView.backgroundColor =  [self randomColor];
    [self addSubview:imageView];
    hookImageView = [[UIImageView alloc]initWithFrame:CGRectMake(150, 3, 12, 15)];
    hookImageView.backgroundColor = [UIColor blackColor];
    [self addSubview:hookImageView];

    UIDynamicBehavior *behavior = [[UIDynamicBehavior alloc] init];
    [self applyAttachBehaviorForObjects:behavior];
    [behavior addChildBehavior:[self createGravityBehaviorForObjects:@[imageView]]];
    [behavior addChildBehavior:[self createCollisionBehaviorForObjects:@[imageView]]];
    [behavior addChildBehavior:[self createItemBehavior]];
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    [_animator addBehavior:behavior];
    [self startUpdateAccelerometer];
}

- (void)applyAttachBehaviorForObjects:(UIDynamicBehavior *)behavior
{
    UIDynamicBehavior *attachmentBehavior = [self createAttachmentBehaviorForBallBearing:imageView toAnchor:hookImageView];
    [behavior addChildBehavior:attachmentBehavior];
}

- (UIDynamicBehavior *)createAttachmentBehaviorForBallBearing:(id<UIDynamicItem>)ballBearing toAnchor:(id<UIDynamicItem>)anchor
{
    //把引線attach到锚点上
    UIAttachmentBehavior *behavior = [[UIAttachmentBehavior alloc] initWithItem:ballBearing offsetFromCenter:UIOffsetMake(0, -125)
                                                               attachedToAnchor:CGPointMake([anchor center].x, [anchor center].y-5)];
    _attachment = behavior;
    return behavior;
}

- (UIDynamicBehavior *)createGravityBehaviorForObjects:(NSArray *)objects
{
    //    添加一个重力行為
    _gravity = [[UIGravityBehavior alloc] initWithItems:objects];
    _gravity.magnitude = 0.5;
    return _gravity;
}

- (UIDynamicBehavior *)createCollisionBehaviorForObjects:(NSArray *)objects
{
    //    添加一个碰撞行為
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:objects];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    return collision;
}

- (UIDynamicItemBehavior *)createItemBehavior
{
    //    为所有動力行為做一个公有配置，像空氣阻力，摩擦力，彈性密度等
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[imageView]];
    
    itemBehavior.elasticity = 1.0;
    itemBehavior.allowsRotation = YES;
    itemBehavior.resistance = 1.f;
    return itemBehavior;
}

- (void)startUpdateAccelerometer
{
    // Determine the update interval
    NSTimeInterval updateInterval = 0.05;
    // Create a CMMotionManager
    CMMotionManager *mManager = [CMMotionManager sharedMotionManager];
    
    // Check whether the accelerometer is available
    if ([mManager isAccelerometerAvailable] == YES) {
        // Assign the update interval to the motion manager
        [mManager setAccelerometerUpdateInterval:updateInterval];
        
        [mManager startAccelerometerUpdates];
        
        gravityTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(processMotion)];
        [gravityTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

-(void)processMotion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //update UI here
        CMMotionManager *mManager = [CMMotionManager sharedMotionManager];
        
        float accelerationX =  mManager.accelerometerData.acceleration.x;
        float accelerationY =  mManager.accelerometerData.acceleration.y;
        CGVector gravityDirection = { accelerationX * 1.0, accelerationY * -1.0 };
        [_gravity setGravityDirection:gravityDirection];
    });
}

@end
