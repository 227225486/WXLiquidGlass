//
//  CCLiquidGlassSettingsViewController.m
//  WXLiquidGlass
//

#import "CCLiquidGlassSettingsViewController.h"

NSString * const WXLTransparentModeKey    = @"wxl_transparentMode";
NSString * const WXLChatBubbleEnabledKey  = @"wxl_chatBubbleEnabled";
NSString * const WXLTabBarEnabledKey      = @"wxl_tabBarEnabled";
NSString * const WXLGradientTopKey        = @"wxl_gradientTop";

@interface CCLiquidGlassSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UISwitch *transparentSwitch;
@property (nonatomic, strong) UISwitch *bubbleSwitch;
@property (nonatomic, strong) UISwitch *tabBarSwitch;
@property (nonatomic, strong) UISwitch *gradientSwitch;
@end

@implementation CCLiquidGlassSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"液态玻璃";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(doneTapped:)];

    [self loadSettings];
}

#pragma mark - 开关懒加载

- (UISwitch *)transparentSwitch {
    if (!_transparentSwitch) {
        _transparentSwitch = [[UISwitch alloc] init];
        [_transparentSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _transparentSwitch;
}

- (UISwitch *)bubbleSwitch {
    if (!_bubbleSwitch) {
        _bubbleSwitch = [[UISwitch alloc] init];
        [_bubbleSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _bubbleSwitch;
}

- (UISwitch *)tabBarSwitch {
    if (!_tabBarSwitch) {
        _tabBarSwitch = [[UISwitch alloc] init];
        [_tabBarSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _tabBarSwitch;
}

- (UISwitch *)gradientSwitch {
    if (!_gradientSwitch) {
        _gradientSwitch = [[UISwitch alloc] init];
        [_gradientSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _gradientSwitch;
}

#pragma mark - 读写

- (void)loadSettings {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.transparentSwitch.on = [d objectForKey:WXLTransparentModeKey] ? [d boolForKey:WXLTransparentModeKey] : WXLDefaultTransparentMode;
    self.bubbleSwitch.on      = [d objectForKey:WXLChatBubbleEnabledKey] ? [d boolForKey:WXLChatBubbleEnabledKey] : WXLDefaultChatBubbleEnabled;
    self.tabBarSwitch.on      = [d objectForKey:WXLTabBarEnabledKey] ? [d boolForKey:WXLTabBarEnabledKey] : WXLDefaultTabBarEnabled;
    self.gradientSwitch.on    = [d objectForKey:WXLGradientTopKey] ? [d boolForKey:WXLGradientTopKey] : WXLDefaultGradientTop;
}

- (void)switchChanged:(UISwitch *)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (sender == self.transparentSwitch) {
        [d setBool:sender.on forKey:WXLTransparentModeKey];
    } else if (sender == self.bubbleSwitch) {
        [d setBool:sender.on forKey:WXLChatBubbleEnabledKey];
    } else if (sender == self.tabBarSwitch) {
        [d setBool:sender.on forKey:WXLTabBarEnabledKey];
    } else if (sender == self.gradientSwitch) {
        [d setBool:sender.on forKey:WXLGradientTopKey];
    }
    [d synchronize];
}

- (void)doneTapped:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 3; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        case 1: return 1;
        case 2: return 1;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"导航栏";
        case 1: return @"底部 TabBar";
        case 2: return @"聊天气泡";
        default: return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) return @"开关即时生效，回到聊天界面查看效果。";
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"透明模式";
            cell.accessoryView = self.transparentSwitch;
        } else {
            cell.textLabel.text = @"渐变顶部";
            cell.accessoryView = self.gradientSwitch;
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"底栏总开关";
        cell.accessoryView = self.tabBarSwitch;
    } else {
        cell.textLabel.text = @"气泡开关";
        cell.accessoryView = self.bubbleSwitch;
    }
    return cell;
}

@end
