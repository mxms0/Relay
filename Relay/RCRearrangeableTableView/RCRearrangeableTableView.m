//
//  RCRearrangeableTableView.m
//  Relay
//
//  Created by Max Shavrick on 8/6/13.
//

#import "RCRearrangeableTableView.h"

@implementation RCRearrangeableTableView
@synthesize rearrangeDelegate, shouldImmobilizeFirstCell;

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super cellForRowAtIndexPath:indexPath];
	if ([[cell gestureRecognizers] count] < 2) {
		// add our gestures to cell
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

- (BOOL)isRearranging {
	return isRearranging;
}

- (void)cellWasHeld:(UILongPressGestureRecognizer *)longPressGesture {
	UITableViewCell *cell = (UITableViewCell *)[longPressGesture view];
	if (![rearrangeDelegate tableView:self canDragCell:cell]) return;
	// make sure this cell is not stationary..
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
		// usually used to identify to the user that an action has occured from their long-press
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)cellWasPanned:(UIPanGestureRecognizer *)panGesture {
	UITableViewCell *cell = (UITableViewCell *)[panGesture view];
	NSIndexPath *idx = [self indexPathForCell:cell];
	switch ([panGesture state]) {
		case UIGestureRecognizerStateBegan: {
			if (isRearranging) {
				[[cell superview] bringSubviewToFront:cell];
				[self setScrollEnabled:NO];
				for (UIGestureRecognizer *gz in [cell gestureRecognizers]) {
					if ([gz isKindOfClass:[UILongPressGestureRecognizer class]]) {
						[gz setEnabled:NO];
						// have to disable long press gesture so it doesnt keep firing
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
				[panGesture setTranslation:CGPointZero inView:self];
				// reset gesture offset
				BOOL goingDown = (tr.y > 0);
				CGRect frame = CGRectMake(0, (cell.center.y + tr.y) - (cell.frame.size.height/2), cell.frame.size.width, cell.frame.size.height);
				CGRect bounds = [self rectForSection:idx.section];
				CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:idx.section];
				int _pfx = (2 + (int)shouldImmobilizeFirstCell);
				CGRect realBounds = CGRectMake(0, bounds.origin.y + headerHeight + ((_pfx -1) * cell.frame.size.height), bounds.size.width, bounds.size.height - (headerHeight + ((_pfx) * cell.frame.size.height)));
				// keep the moving cell inside of its section.
				if (CGRectIntersectsRect(realBounds, frame))
					[cell setFrame:frame];
				for (UITableViewCell *aCell in [self visibleCells]) {
					NSIndexPath *newPath = [self indexPathForCell:aCell];
					if (newPath.section != idx.section) continue;
					// should make things just a tad bit faster, skipping cells we definitely wont touch
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
			if (!isRearranging) return;
			for (UIGestureRecognizer *gz in [cell gestureRecognizers]) {
				if ([gz isKindOfClass:[UILongPressGestureRecognizer class]]) {
					[gz setEnabled:YES];
					break;
				}
			}
			[self setScrollEnabled:YES];
			int count = 0;
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
						if ([rearrangeDelegate respondsToSelector:@selector(tableView:cellDidBeginDragging:)])
							[rearrangeDelegate tableView:self cellDidFinishDragging:cell];
						CGRect bounds = [self rectForSection:idx.section];
						CGFloat offy = (cell.frame.origin.y - bounds.origin.y)/cell.frame.size.height;
						[rearrangeDelegate tableView:self movedCellFromIndex:idx toIndex:[NSIndexPath indexPathForRow:offy inSection:idx.section]];
						[self reloadData]; // theiostream was here
						isRearranging = NO;
						return;
					}
				}
				count++;
			}
			CGRect boundingBox = [self rectForSection:idx.section];
			if (cell.frame.origin.y + 44 >= (boundingBox.origin.y + boundingBox.size.height)) {
				[UIView animateWithDuration:0.1 animations:^ {
					[cell setFrame:CGRectMake(0, (boundingBox.origin.y + boundingBox.size.height) - cell.frame.size.height, cell.frame.size.width, cell.frame.size.height)];
				}];
				if ([rearrangeDelegate respondsToSelector:@selector(tableView:cellDidBeginDragging:)])
					[rearrangeDelegate tableView:self cellDidFinishDragging:cell];
				[rearrangeDelegate tableView:self movedCellFromIndex:idx toIndex:[NSIndexPath indexPathForRow:count inSection:idx.section]];
				[self reloadData];
			}
			isRearranging = NO;
			break;
	}
}

@end
