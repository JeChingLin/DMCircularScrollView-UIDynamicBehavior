//
//  JCCollectionViewCell.h
//  DMCircularScrollView+UIDynamicBehavior
//
//  Created by Test OSX9 on 2015/11/2.
//
//

#import <UIKit/UIKit.h>

@interface JCCollectionViewCell : UICollectionViewCell
{
    UIDynamicAnimator *_animator;
    UIAttachmentBehavior *_attachment;
    UIImageView *imageView;
    UIImageView *hookImageView ;
    UIGravityBehavior *_gravity;
    CADisplayLink *gravityTimer;
}

-(void)startAnimation;
@end
