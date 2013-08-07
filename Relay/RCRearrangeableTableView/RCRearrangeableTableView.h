//
//  RCRearrangeableTableView.h
//  Relay
//
//  Created by Max Shavrick on 8/6/13.
//

#import <UIKit/UIKit.h>

@protocol RCRearrangeableTableViewDelegate <NSObject>
- (void)tableView:(UITableView *)tableView movedCellFromIndex:(NSIndexPath *)idx toIndex:(NSIndexPath *)newIdx;
- (BOOL)tableView:(UITableView *)tableView canDragCell:(UITableViewCell *)cell;
@optional
- (void)tableView:(UITableView *)tableView cellDidBeginDragging:(UITableViewCell *)cell;
- (void)tableView:(UITableView *)tableView cellDidFinishDragging:(UITableViewCell *)cell;
@end

@interface RCRearrangeableTableView : UITableView <UIGestureRecognizerDelegate> {
	BOOL isRearranging;
	NSTimer *holdTimer;
	id <RCRearrangeableTableViewDelegate> rearrangeDelegate;
}
@property (nonatomic, assign) id <RCRearrangeableTableViewDelegate> rearrangeDelegate;
@property (nonatomic, assign) BOOL shouldImmobilizeFirstCell;
// for people who like to fake header views with cells
@end
