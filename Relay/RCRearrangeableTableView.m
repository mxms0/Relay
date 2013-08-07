//
//  RCRearrangeableTableView.m
//  Relay
//
//  Created by Max Shavrick on 8/6/13.
//

#import "RCRearrangeableTableView.h"

@implementation RCRearrangeableTableView
@synthesize rearrangeDelegate;

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super cellForRowAtIndexPath:indexPath];
	if ([[cell gestureRecognizers] count] < 2) {
		UIPanGestureRecognizer *lpress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasPanned:)];
		[cell addGestureRecognizer:lpress];
		[lpress setDelegate:self];
		[lpress release];
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasHeld:)];
		[longPress setCancelsTouchesInView:NO];
		[longPress setDelegate:self];
		[cell addGestureRecognizer:longPress];
		[longPress release];
	}
	return cell;
}

- (void)cellWasHeld:(UILongPressGestureRecognizer *)longPressGesture {
	if ([[longPressGesture view] isKindOfClass:[UITableViewCell class]]) {
		UITableViewCell *cell = (UITableViewCell *)[longPressGesture view];
		if (![rearrangeDelegate tableView:self canDragCell:cell])
			return;
	}
	if (!isRearranging) {
		if (holdTimer) return;
		holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(targetBeginLongPress:) userInfo:[longPressGesture view] repeats:NO];
	}
}

- (void)targetBeginLongPress:(NSTimer *)timer {
	if (!isRearranging) {
		holdTimer = nil;
		isRearranging = YES;
		UITableViewCell *cell = (UITableViewCell *)[timer userInfo];
		[rearrangeDelegate tableView:self cellDidBeginDragging:cell];
		
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)cellWasPanned:(UIPanGestureRecognizer *)panGesture {
	UITableViewCell *cell = (UITableViewCell *)[panGesture view];
	NSIndexPath *pf = [self indexPathForCell:cell];
		switch ([panGesture state]) {
			case UIGestureRecognizerStateBegan: {
				if (isRearranging) {
					[[cell superview] bringSubviewToFront:cell];
					[self setScrollEnabled:NO];
					for (UIGestureRecognizer *gz in [cell gestureRecognizers]) {
						if ([gz isKindOfClass:[UILongPressGestureRecognizer class]]) {
							[gz setEnabled:NO];
							break;
						}
					}
				}
				break;
			}
			case UIGestureRecognizerStateChanged:
				if (isRearranging) {
					// find subview.
					CGPoint tr = [panGesture translationInView:self];
					BOOL goingDown = (tr.y > 0);
					CGPoint cr = CGPointMake([cell center].x, cell.center.y + tr.y);
					CGRect frame = CGRectMake(0, cr.y - (cell.frame.size.height/2), cell.frame.size.width, cell.frame.size.height);
					CGRect bounds = [self rectForSection:pf.section];
					CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:pf.section];
					CGRect realBounds = CGRectMake(0, bounds.origin.y + (3 * headerHeight), bounds.size.width, bounds.size.height - (4 * headerHeight));
					if (CGRectIntersectsRect(realBounds, frame))
						[cell setFrame:frame];
					[panGesture setTranslation:CGPointZero inView:self];
					for (UITableViewCell *aCell in [self visibleCells]) {
						NSIndexPath *newPath = [self indexPathForCell:aCell];
						if (newPath.section != pf.section) continue;
						if (aCell != cell) {
							if (CGRectIntersectsRect(aCell.frame, cell.frame)) {
								CGFloat hheight = aCell.frame.origin.y + (aCell.frame.size.height/2);
								CGFloat mheight = cell.frame.origin.y + (cell.frame.size.height/2);
								CGFloat offst = fabsf(mheight - hheight);
								if (offst < aCell.frame.size.height/2) {
									[UIView animateWithDuration:0.1 animations:^ {
										[aCell setFrame:CGRectMake(0, aCell.frame.origin.y - (!goingDown ? -aCell.frame.size.height : aCell.frame.size.height), aCell.frame.size.width, aCell.frame.size.height)];
									}];
								}
								break;
							}
						}
					}
				}
				break;
			case UIGestureRecognizerStatePossible:
				break;
			default:
				for (UIGestureRecognizer *gz in [cell gestureRecognizers]) {
					if ([gz isKindOfClass:[UILongPressGestureRecognizer class]]) {
						[gz setEnabled:YES];
						break;
					}
				}
				[self setScrollEnabled:YES];
				for (UITableViewCell *aCell in [self visibleCells]) {
					if (CGRectIntersectsRect(aCell.frame, cell.frame)) {
						if (cell != aCell) {
							CGFloat hheight = aCell.frame.size.height + aCell.frame.origin.y;
							CGFloat wheight = cell.frame.size.height + cell.frame.origin.y;
							CGFloat difst = wheight - hheight;
							[UIView animateWithDuration:0.1 animations:^ {
								if (difst > 0) {
									[cell setFrame:CGRectMake(0, aCell.frame.origin.y + aCell.frame.size.height, aCell.frame.size.width, aCell.frame.size.height)];
								}
								else {
									[cell setFrame:CGRectMake(0, aCell.frame.origin.y - aCell.frame.size.height, aCell.frame.size.width, aCell.frame.size.height)];
								}
							}];
							[rearrangeDelegate tableView:self cellDidFinishDragging:cell];
							CGRect bounds = [self rectForSection:pf.section];
							CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:pf.section];
							CGFloat offy = (cell.frame.origin.y - bounds.origin.y)/headerHeight;
							[rearrangeDelegate tableView:self movedCellFromIndex:pf toIndex:[NSIndexPath indexPathForRow:offy inSection:pf.section]];
							[self reloadData];
							break;
						}
					}
					else {
						
						
					}
				}
				isRearranging = NO;
				break;
		}
}

@end
