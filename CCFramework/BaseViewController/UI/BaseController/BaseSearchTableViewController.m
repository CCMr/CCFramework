//
//  BaseSearchTableViewController.m
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "BaseSearchTableViewController.h"
#import "UIView+BUIView.h"
#import "UITableView+Additions.h"

@interface BaseSearchTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

/**
 *  @author CC, 15-08-21
 *
 *  @brief  搜索框
 *
 *  @since <#1.0#>
 */
@property (nonatomic, strong) UISearchBar *searchBar;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  TableView右边的IndexTitles数据源
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSMutableArray *sectionIndexTitles;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  搜索框绑定的控制器
 *
 *  @since <#1.0#>
 */
@property (nonatomic) UISearchDisplayController *searchController;

/**
 *  @author CC, 15-09-10
 *
 *  @brief  索引集合
 *
 *  @since 1.0
 */
@property (nonatomic, strong) UILocalizedIndexedCollation *theCollation;

@end

@implementation BaseSearchTableViewController

#pragma mark - Action

- (void)voiceButtonClicked:(UIButton *)sender {
    [self.searchDisplayController setActive:YES animated:YES];
}

- (void)configureSearchBarLeftIconButton {
    UITextField *searchField;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        searchField = [_searchBar.subviews objectAtIndex:1];
    else
        searchField = [((UIView *)[_searchBar.subviews objectAtIndex:0]).subviews lastObject];
    
    if ([searchField isKindOfClass:[UITextField class]]) {
        UIButton *leftIconButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [leftIconButton setImage:[UIImage imageNamed:@"VoiceSearchStartBtn"] forState:UIControlStateNormal];
        [leftIconButton setImage:[UIImage imageNamed:@"VoiceSearchStartBtn_HL"] forState:UIControlStateHighlighted];
        [leftIconButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        searchField.rightView = leftIconButton;
        searchField.rightViewMode = UITextFieldViewModeAlways;
    }
}

#pragma mark - Propertys

- (NSMutableArray *)filteredDataSource {
    if (!_filteredDataSource) {
        _filteredDataSource = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _filteredDataSource;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        _searchBar.delegate = self;
        
        _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsDelegate = self;
        _searchController.searchResultsDataSource = self;
    }
    return _searchBar;
}

- (NSString *)getSearchBarText {
    return self.searchDisplayController.searchBar.text.lowercaseString;
}

-(NSMutableDictionary *)DicDataSource
{
    if (!_dicDataSource) {
        _dicDataSource = [NSMutableDictionary dictionary];
    }
    return _dicDataSource;
}

/**
 *  @author CC, 15-09-10
 *
 *  @brief  检索索引
 *
 *  @return 索引集合
 *
 *  @since 1.0
 */
-(NSArray *)sectionIndexTitles
{
    if (!_sectionIndexTitles) {
        NSMutableArray *sectionIndex = [NSMutableArray array];
        [sectionIndex addObject:UITableViewIndexSearch];
        [sectionIndex addObjectsFromArray:[UILocalizedIndexedCollation.currentCollation sectionIndexTitles]];
        _sectionIndexTitles = sectionIndex;
    }
    return _sectionIndexTitles;
}

/**
 *  @author CC, 15-09-10
 *
 *  @brief  添加索引
 *
 *  @param title 索引标题
 *  @param index 插入下标
 *
 *  @since 1.0
 */
- (void)insetSectionIndexTitles: (NSString *)title
                          Index: (int)index
{
    [self.sectionIndexTitles insertObject:title atIndex:index];
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self configureSearchBarLeftIconButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _theCollation = [UILocalizedIndexedCollation currentCollation];
    [self configuraSectionIndexBackgroundColorWithTableView:self.tableView];
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView extraCellLineHidden];
    
    UIView *views = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    views.backgroundColor = [UIColor redColor];
    //    [self.tableView setTableHeaderView:views];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Content Filtering

/**
 *  @author CC, 15-09-10
 *
 *  @brief  检索数据源
 *
 *  @param searchText 检索关键字
 *  @param scope      <#scope description#>
 *
 *  @since 1.0
 */
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    [self.filteredDataSource removeAllObjects];
}

#pragma mark - SearchTableView Helper Method

- (BOOL)enableForSearchTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return YES;
    }
    return NO;
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    return YES;
}
#pragma mark - SearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

#pragma mark - UITableView DataSource

/**
 *  @author CC, 15-09-10
 *
 *  @brief  检索索引位置
 *
 *  @param tableView 当前表单
 *  @param title     索引
 *  @param index     当前位置
 *
 *  @return 返回索引位置
 *
 *  @since 1.0
 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger indexs = self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? index : index - 1;
    if ([title isEqualToString:@"{search}"]) {
        [tableView scrollRectToVisible:_searchBar.frame animated:NO];
        indexs = -1;
    }
    
    return indexs;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self enableForSearchTableView:tableView]) {
        return 1;
    }
    return self.ArrayDataSource.count > 0 ? self.ArrayDataSource.count : self.dicDataSource.count;
}

- (NSInteger)tableView: (UITableView *)tableView
 numberOfRowsInSection: (NSInteger)section
{
    if ([self enableForSearchTableView:tableView]) {
        return self.filteredDataSource.count;
    }
    return self.ArrayDataSource.count > 0 ? [self.ArrayDataSource[section] count] : [[self.dicDataSource objectForKey:[self.dicDataSource.allKeys objectAtIndex:section]] count];
}

- (CGFloat)tableView: (UITableView *)tableView heightForHeaderInSection :(NSInteger)section{
    return 22;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

#pragma mark - UITableView Delegate

//section 头部,为了IOS6的美化
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self enableForSearchTableView:tableView]) {
        return nil;
    }
    
    BOOL showSection = NO;
    if (self.ArrayDataSource.count) {
        showSection = [[self.ArrayDataSource objectAtIndex:section] count] != 0;
    }else if (self.dicDataSource.count)
        showSection = [[self.dicDataSource objectForKey:[self.dicDataSource.allKeys objectAtIndex:section]] count] != 0;
    
    //only show the section title if there are rows in the sections
    
    UIView *customHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 22.0f)];
    customHeaderView.backgroundColor = [UIColor colorWithRed:0.926 green:0.920 blue:0.956 alpha:1.000];
    
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 0, CGRectGetWidth(customHeaderView.bounds) - 15.0f, 22.0f)];
    headerLabel.text = (showSection) ? (self.sectionIndexTitles.count == [[_theCollation sectionTitles] count] ? [_sectionIndexTitles objectAtIndex:section] : [_sectionIndexTitles objectAtIndex:section + 1]) : nil;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    headerLabel.textColor = [UIColor darkGrayColor];
    
    [customHeaderView addSubview:headerLabel];
    return customHeaderView;
}

@end
