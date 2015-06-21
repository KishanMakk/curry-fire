//
//  TKPagedScrollView.m
//  Created by Devin Ross on 6/18/15.
//
/*
 
 curryfire || https://github.com/devinross/curry-fire
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKPagedScrollView.h"
#import "UIView+Positioning.h"

@interface TKPagedScrollView () <UIScrollViewDelegate>
@end

@implementation TKPagedScrollView

- (id) initWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame direction:TKPageScrollDirectionVertical];
    return self;
}
- (id) initWithFrame:(CGRect)frame direction:(TKPageScrollDirection)direction{
    if(!(self=[super initWithFrame:frame])) return nil;
    
    self.clipsToBounds = YES;
    _scrollDirection = direction;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollView];
    _currentPage = 0;
    
    
    return self;
}


#pragma mark Private Functions
- (void) _setupPages{
    
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    UIView *nextView = self.pages[self.currentPage];
    
    if(self.scrollDirection == TKPageScrollDirectionVertical)
        self.scrollView.contentHeight = nextView.height;
    else
        self.scrollView.contentWidth = nextView.width;


    CGFloat min = 0;
    for(NSInteger i=self.currentPage;i<self.pages.count;i++){
        
        UIView *page = self.pages[i];
        if(self.scrollDirection == TKPageScrollDirectionVertical){
            page.minY = min;
            min = page.maxY;
        }else{
            page.minX = min;
            min = page.maxX;
        }
        [self.scrollView addSubview:page];
        
    }
    CGFloat max = 0;
    for(NSInteger i=self.currentPage-1;i>=0;i--){
        UIView *page = self.pages[i];
        
        if(self.scrollDirection == TKPageScrollDirectionVertical){
            page.maxY = max;
            max = page.minY;
        }else{
            page.maxX = max;
            max = page.minX;
        }
        [self.scrollView addSubview:page];
        


        
    }
    

    
}

#pragma mark Actions
- (void) scrollToPreviousPage{
    
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = currentPage - 1;
    if(nextPage < 0) return;
    
    BOOL showVert = self.scrollView.showsVerticalScrollIndicator;
    BOOL interactive = self.scrollView.userInteractionEnabled;
    self.scrollView.userInteractionEnabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    UIView *nextView = self.pages[nextPage];
    
    
    for(UIView *subview in self.pages)
        [subview moveToView:self.scrollView.superview];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    self.scrollView.contentHeight = nextView.height;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        nextView.maxY = self.scrollView.maxY;
        
        CGFloat minY = self.scrollView.maxY;
        for(NSInteger i=currentPage;i<self.pages.count;i++){
            UIView *page = self.pages[i];
            page.minY = minY;
            minY = page.maxY;
        }
        
        CGFloat maxY = nextView.minY;
        for(NSInteger i=nextPage-1;i>=0;i--){
            UIView *page = self.pages[i];
            page.maxY = maxY;
            maxY = page.minY;
        }
        
        
    } completion:^(BOOL finished) {
        
        
        _currentPage = nextPage;
        
        if(self.scrollDirection == TKPageScrollDirectionVertical)
            self.scrollView.contentHeight = nextView.height;
        else
            self.scrollView.contentWidth = nextView.width;
        
        [self.scrollView setContentOffset:CGPointMake(0, nextView.height-self.scrollView.height) animated:NO];
        
        for(UIView *subview in self.pages)
            [subview moveToView:self.scrollView];
        
        self.scrollView.userInteractionEnabled = interactive;
        self.scrollView.showsVerticalScrollIndicator = showVert;
        
        if([self.delegate respondsToSelector:@selector(pagedScrollView:didMoveToPage:)])
            [self.delegate pagedScrollView:self didMoveToPage:self.currentPage];

        
    }];
}
- (void) scrollToNextPage{
    
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = currentPage + 1;
    if(nextPage >= self.pages.count) return;
    
    BOOL showVert = self.scrollView.showsVerticalScrollIndicator;
    BOOL interactive = self.scrollView.userInteractionEnabled;
    self.scrollView.userInteractionEnabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    UIView *nextView = self.pages[nextPage];
    
    for(UIView *subview in self.pages)
        [subview moveToView:self.scrollView.superview];
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGFloat min = 0;
        for(NSInteger i=nextPage;i<self.pages.count;i++){
            UIView *page = self.pages[i];
            
            if(self.scrollDirection==TKPageScrollDirectionVertical){
                page.minY = min;
                min = page.maxY;
            }else{
                page.minX = min;
                min = page.maxX;
            }
            
            
        }
        
        CGFloat max = 0;
        for(NSInteger i=nextPage-1;i>=0;i--){
            UIView *page = self.pages[i];
            
            
            if(self.scrollDirection==TKPageScrollDirectionVertical){
                page.maxY = max;
                max = page.minY;
            }else{
                page.maxX = max;
                max = page.minX;
            }
            
            
        }
        
        
    } completion:^(BOOL finished) {
        
        _currentPage = nextPage;
        [self.scrollView setContentOffset:CGPointZero animated:NO];
        
        if(self.scrollDirection == TKPageScrollDirectionVertical)
            self.scrollView.contentHeight = nextView.height;
        else
            self.scrollView.contentWidth = nextView.width;
        
        [self.scrollView setContentOffset:CGPointZero animated:NO];
        for(UIView *subview in self.pages)
            [subview moveToView:self.scrollView];
        self.scrollView.userInteractionEnabled = interactive;
        self.scrollView.showsVerticalScrollIndicator = showVert;
        
        
        if([self.delegate respondsToSelector:@selector(pagedScrollView:didMoveToPage:)])
            [self.delegate pagedScrollView:self didMoveToPage:self.currentPage];

        
    }];
    
}
- (void) scrollToPage:(NSInteger)page animated:(BOOL)animated{
	if(page < 0 || page >= self.pages.count) return;

	_currentPage = page;
	
	[self _setupPages];

	
	
}


#pragma mark UIScrollViewDelegate
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    

    if(scrollView.contentOffset.y + scrollView.height > scrollView.contentHeight){
        [self scrollToNextPage];
        
        
    }
    
    if(scrollView.contentOffset.y < 0){
        [self scrollToPreviousPage];
    }
    
    if([self.delegate respondsToSelector:@selector(pagedScrollViewDidEndDragging:willDecelerate:)])
        [self.delegate pagedScrollViewDidEndDragging:self willDecelerate:decelerate];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(pagedScrollViewDidScroll:)])
        [self.delegate pagedScrollViewDidScroll:self];
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(pagedScrollViewWillBeginDragging:)])
        [self.delegate pagedScrollViewWillBeginDragging:self];
}
- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(pagedScrollViewWillBeginDecelerating:)])
        [self.delegate pagedScrollViewWillBeginDecelerating:self];
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(pagedScrollViewDidEndDecelerating:)])
        [self.delegate pagedScrollViewDidEndDecelerating:self];
}
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(pagedScrollViewDidEndScrollingAnimation:)])
        [self.delegate pagedScrollViewDidEndScrollingAnimation:self];
}
- (BOOL) scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if(![self.delegate respondsToSelector:@selector(pagedScrollViewShouldScrollToTop:)])
        return self.scrollDirection == TKPageScrollDirectionVertical;
    return [self.delegate pagedScrollViewShouldScrollToTop:self];
}
- (void) scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if([self.delegate respondsToSelector:@selector(pagedScrollViewDidScrollToTop:)])
        [self.delegate pagedScrollViewDidScrollToTop:self];
}


#pragma mark Properties
- (void) setPages:(NSArray *)pages{
    [_pages makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _pages = pages;
    [self _setupPages];
}
- (void) setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    [self _setupPages];
}

@end