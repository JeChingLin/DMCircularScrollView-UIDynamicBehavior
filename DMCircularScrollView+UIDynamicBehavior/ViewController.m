//
//  ViewController.m
//  DMCircularScrollView+UIDynamicBehavior
//
//  Created by Test OSX9 on 2015/11/2.
//
//

#import "ViewController.h"
#import "DMCircularScrollView.h"
#import "JCCollectionViewCell.h"


#define WIDTH 300

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong) DMCircularScrollView *collectionScrollView;
@property(nonatomic, strong) NSArray *collectionItemsArray;
@end
static NSString *JCCellIdentifier = @"JCCellIdentifier";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initCollectionScrollView];
    
    __weak ViewController *weakSelf = self;
    
    _collectionItemsArray = [self generateCollectionViews:15 width:WIDTH];
    
    [_collectionScrollView setPageCount:[_collectionItemsArray count]
                         withDataSource:^UIView *(NSUInteger pageIndex) {
                             return [weakSelf.collectionItemsArray objectAtIndex:pageIndex];
                         }];
    
    // How to handle page events change
    _collectionScrollView.handlePageChange =  ^(NSUInteger currentPageIndex,NSUInteger previousPageIndex) {
        NSLog(@"COLLECTIONS HAS CHANGED. CURRENT COLLECTIONS IS %lu (prev=%lu)",(unsigned long)currentPageIndex,(unsigned long)previousPageIndex);
        
        
        [weakSelf.collectionItemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            for (UIView *sb in [(UIView*)obj subviews]) {
                if ([sb isKindOfClass:[UICollectionView class]]) {
                    UICollectionView *cv = (UICollectionView*)sb ;
                    if (idx == currentPageIndex) {
                    }
                    else{
                        [cv setScrollsToTop:YES];
                        [cv setContentOffset:CGPointZero animated:NO];
                    }
                }
            }
        }];
    };

    [self.view addSubview:_collectionScrollView];
}


-(void)initCollectionScrollView
{
    _collectionScrollView =[[DMCircularScrollView alloc] initWithFrame:CGRectMake(10, 64, WIDTH, 440)];
    _collectionScrollView.userInteractionEnabled = YES;
    _collectionScrollView.pageWidth = 300;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *) generateCollectionViews:(NSUInteger) number width:(CGFloat) wd {
    NSMutableArray *views_list = [[NSMutableArray alloc] init];
    
    for (NSUInteger k = 0;  k < number;  k++) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowLayout setItemSize:CGSizeMake(wd, 300)];
        [flowLayout setSectionInset:UIEdgeInsetsMake(13, 0, 25, 0)];
        [flowLayout setMinimumLineSpacing:10];
        [flowLayout setMinimumInteritemSpacing:10];
        
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, wd, 440)];
        UICollectionView *cv = [[UICollectionView alloc]initWithFrame:backView.bounds                                     collectionViewLayout:flowLayout];
        [cv registerClass:[JCCollectionViewCell class] forCellWithReuseIdentifier:JCCellIdentifier];
        cv.tag = k;
        cv.delegate = self;
        cv.dataSource = self;
        cv.backgroundColor = [UIColor clearColor];
        [backView addSubview:cv];
        [views_list addObject:backView];;
    }
    return views_list;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 15;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JCCellIdentifier forIndexPath:indexPath];
    
    [cell startAnimation];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   NSLog(@"COLLECTIONS HAS SELECTED. SELECTED COLLECTIONS IS %lu (tag=%lu)",indexPath.item, collectionView.tag);
}

@end
