//
//  ANMainTableViewController.m
//  DemoPhotoView
//
//  Created by Andrei Nechaev on 5/28/15.
//  Copyright (c) 2015 Andrei Nechaev. All rights reserved.
//

#import "ANMainTableViewController.h"
#import "ANPhotoCollectionTableViewCell.h"
#import "ANLoader.h"
#import "ANDataAccessObject.h"

@interface ANMainTableViewController ()

@property (nonatomic, strong) NSMutableArray *openedCellIndexes;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) ANLoader *loader;
@property (nonatomic, strong) ANDataAccessObject *dao;
@property (nonatomic, strong) NSMutableDictionary *heighForIndexes;

@end

@implementation ANMainTableViewController
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _loader = [[ANLoader alloc] init];
    _openedCellIndexes = [NSMutableArray new];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.center = self.view.center;
    _heighForIndexes = [NSMutableDictionary new];
    _dao = [ANDataAccessObject sharedManager];

    [self.view addSubview:self.indicatorView];
    [self.tableView registerClass:[ANPhotoCollectionTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.indicatorView startAnimating];
    [[NSNotificationCenter defaultCenter] addObserverForName:ANLoaderFetcherFinished object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"here %@", note.name);
        [self.indicatorView stopAnimating];
        [self.openedCellIndexes addObject:@(0)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ANDAOTempDataAccessed object:nil queue:nil usingBlock:^(NSNotification *note) {

        NSUInteger count = [self.dao.tempImageStorage count];
        if (count > 19) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Only 20 is allowed" message:@"You ran out of memory my little friend" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save All" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self save];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel  handler:nil];
            UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Reset All" style:UIAlertActionStyleDestructive  handler:^(UIAlertAction *action) {
                [self.dao.tempImageStorage removeAllObjects];
                [self.tableView reloadData];
                [self setTitle:[NSString stringWithFormat:@""]];
            }];
            
            [alertVC addAction:saveAction];
            [alertVC addAction:cancelAction];
            [alertVC addAction:resetAction];
            
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        if (count == 0) {
            [self setTitle:@""];
        }else {
            [self setTitle:[NSString stringWithFormat:@"%lu", count]];
        }
        
    }];
    
#warning comment it after first lunch
    [self.loader downloadImagesWith:arc4random()%50+1];
#warning uncomment it after first lunch
//    [self.loader runFetcher];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.dao imageStorage] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.openedCellIndexes containsObject:@(section)]) {
        return 1;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ANPhotoCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                                           forIndexPath:indexPath];
    if (!cell) {
        cell = [[ANPhotoCollectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.imageStorage = [self.dao imageStorage][indexPath.section];
    
    self.heighForIndexes[indexPath] = @([cell collectionRect].size.height);
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.heighForIndexes[indexPath] doubleValue];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.tableView reloadData];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
    UIButton *headerButton = [[UIButton alloc] initWithFrame:frame];
    headerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headerButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    headerButton.backgroundColor = [UIColor lightGrayColor];
    headerButton.tag = section;
    headerButton.backgroundColor = [UIColor darkGrayColor];
    NSString *folderName = [NSString stringWithFormat:@"Folder #%lu", section+1];
    [headerButton setTitle:folderName forState:UIControlStateNormal];
    [headerButton addTarget:self action:@selector(scrollTo:) forControlEvents:UIControlEventTouchUpInside];
    return headerButton;
}


- (void)scrollTo:(UIButton *)sender
{
    if (!sender.tag > [[self.dao imageStorage] count]) return;
    
    if (![self.openedCellIndexes containsObject:@(sender.tag)]) {
        [self.openedCellIndexes addObject:@(sender.tag)];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag]
                      withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else {
        sender.backgroundColor = [UIColor grayColor];
        [self.openedCellIndexes removeObject:@(sender.tag)];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag]
                      withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (IBAction)saveImages:(UIBarButtonItem *)sender {
    [self save];
}

- (void)save
{
    [self.loader saveImages:self.dao.tempImageStorage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loader runFetcher];
        [self.dao.tempImageStorage removeAllObjects];
    });
}

@end
