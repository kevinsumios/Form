#import "FORMFieldValuesTableViewController.h"
#import "FORMFieldValue.h"
#import "FORMField.h"
#import "FORMFieldValueCell.h"

@interface FORMFieldValuesTableViewController ()

@property (nonatomic) NSArray *values;
@property NSMutableArray *selectedValues;

@end

@implementation FORMFieldValuesTableViewController

#pragma mark - Getters

- (FORMFieldValuesTableViewHeader *)headerView {
    if (_headerView) return _headerView;

    _headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:FORMFieldValuesTableViewHeaderIdentifier];

    return _headerView;
}

#pragma mark - Setters

- (void)setField:(FORMField *)field {
    _field = field;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonDidTap)];
        BOOL shouldShowDoneButton = (_field.type == FORMFieldTypeDate || _field.type == FORMFieldTypeDateTime || _field.type == FORMFieldTypeTime);
        if (shouldShowDoneButton) {
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap)];
            self.navigationItem.rightBarButtonItems = @[done, clear];
        } else {
            self.navigationItem.rightBarButtonItem = clear;
        }

        self.title = self.field.title;
    }

    self.values = [NSArray arrayWithArray:field.values];
    self.headerView.field = field;
    
    if(field.type == FORMFieldTypeMultiselect){
        NSString *stringValues = self.field.value;
        if([stringValues isKindOfClass:[NSString class]]){
            self.selectedValues = [[NSMutableArray alloc] initWithArray:[stringValues componentsSeparatedByString:@","]];
        }else{
            self.selectedValues = [[NSMutableArray alloc] init];
        }
    }
    self.tableView.allowsMultipleSelection = (field.type == FORMFieldTypeMultiselect);
    [self.tableView reloadData];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;

    self.tableView.rowHeight = FORMFieldValuesCellHeight;

    [self.tableView registerClass:[FORMFieldValueCell class] forCellReuseIdentifier:FORMFieldValueCellIdentifer];
    [self.tableView registerClass:[FORMFieldValuesTableViewHeader class] forHeaderFooterViewReuseIdentifier:FORMFieldValuesTableViewHeaderIdentifier];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonDidTap)];
        self.navigationItem.leftBarButtonItem = cancel;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Navigation Buttons Actions

- (void)cancelButtonDidTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonDidTap {
    FORMFieldValue *fieldValue = [FORMFieldValue new];
    fieldValue.value = @YES;

    if ([self.delegate respondsToSelector:@selector(fieldValuesTableViewController:didSelectedValue:)]) {
        [self.delegate fieldValuesTableViewController:self
                                     didSelectedValue:fieldValue];
    }
}

- (void)clearButtonDidTap {
    FORMFieldValue *fieldValue = [FORMFieldValue new];
    fieldValue.value = @NO;

    if ([self.delegate respondsToSelector:@selector(fieldValuesTableViewController:didSelectedValue:)]) {
        [self.delegate fieldValuesTableViewController:self
                                     didSelectedValue:fieldValue];
    }
}

#pragma mark - TableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.headerView.field = self.field;

    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 0.0f;

    if (self.customHeight > 0.0f) {
        headerHeight = self.customHeight;
    } else if (self.field.info) {
        [self.headerView setField:self.field];
        headerHeight = [self.headerView labelHeight];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        headerHeight = FORMFieldValuesCellHeight;
    }

    return headerHeight;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FORMFieldValueCell *cell = [tableView dequeueReusableCellWithIdentifier:FORMFieldValueCellIdentifer];

    FORMFieldValue *fieldValue = self.values[indexPath.row];
    cell.fieldValue = fieldValue;

    if ([self.field.value isKindOfClass:[FORMFieldValue class]]) {
        FORMFieldValue *currentFieldValue = self.field.value;

        if (self.field.type == FORMFieldTypeMultiselect) {
            NSString *stringValue = currentFieldValue.valueID;
            if([stringValue containsString:fieldValue.valueID]){
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
                if(![self.selectedValues containsObject:[(FORMFieldValue*)self.values[indexPath.row] value]]){
                    [self.selectedValues addObject:[(FORMFieldValue*)self.values[indexPath.row] value]];
                }
            }
        }else{
            if ([currentFieldValue identifierIsEqualTo:fieldValue.valueID]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
        }
    } else {
        
        if (self.field.type == FORMFieldTypeMultiselect) {
            NSString *stringValue = self.field.value;
            if([stringValue containsString:fieldValue.valueID]){
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
                if(![self.selectedValues containsObject:[(FORMFieldValue*)self.values[indexPath.row] value]]){
                    [self.selectedValues addObject:[(FORMFieldValue*)self.values[indexPath.row] value]];
                }
            }
        }else{
            if ([fieldValue identifierIsEqualTo:self.field.value]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FORMFieldValue *fieldValue;
    if ([self.delegate respondsToSelector:@selector(fieldValuesTableViewController:didSelectedValue:)]) {
        
        if(_field.type == FORMFieldTypeMultiselect){
            if(![self.selectedValues containsObject:[(FORMFieldValue*)self.values[indexPath.row] value]]){
                [self.selectedValues addObject:[(FORMFieldValue*)self.values[indexPath.row] value]];
            }
            fieldValue = [[FORMFieldValue alloc]init];
            fieldValue.value = [self.selectedValues componentsJoinedByString:@","];
            fieldValue.valueID = fieldValue.value;
            fieldValue.title = [self.selectedValues componentsJoinedByString:@","];

        }else{
            fieldValue = self.values[indexPath.row];

        }
        
        [self.delegate fieldValuesTableViewController:self
                                     didSelectedValue:fieldValue];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FORMFieldValue *fieldValue;
    if ([self.delegate respondsToSelector:@selector(fieldValuesTableViewController:didSelectedValue:)]) {
        
        if(_field.type == FORMFieldTypeMultiselect){
            if([self.selectedValues containsObject:[(FORMFieldValue*)self.values[indexPath.row] value]]){
                [self.selectedValues removeObject:[(FORMFieldValue*)self.values[indexPath.row] value]];
            }
            fieldValue = [[FORMFieldValue alloc]init];
            fieldValue.value = [self.selectedValues componentsJoinedByString:@","];
            fieldValue.valueID = fieldValue.value;
            fieldValue.title = [self.selectedValues componentsJoinedByString:@","];

        }else{
            fieldValue = [[FORMFieldValue alloc]init];
            
        }
        
        [self.delegate fieldValuesTableViewController:self
                                     didSelectedValue:fieldValue];
    }
}

@end
