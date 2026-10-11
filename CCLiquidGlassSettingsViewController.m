//
//  CCLiquidGlassSettingsViewController.m
//  WXLiquidGlass
//

#import "CCLiquidGlassSettingsViewController.h"

NSString * const WXLTransparentModeKey    = @"wxl_transparentMode";
NSString * const WXLChatBubbleEnabledKey  = @"wxl_chatBubbleEnabled";
NSString * const WXLTabBarEnabledKey      = @"wxl_tabBarEnabled";
NSString * const WXLGradientTopKey        = @"wxl_gradientTop";

@interface CCLiquidGlassSettingsViewController ()
@property (nonatomic, strong) UISwitch *transparentSwitch;
@property (nonatomic, strong) UISwitch *tabBarSwitch;
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

- (UISwitch *)transparentSwitch {
    if (!_transparentSwitch) {
        _transparentSwitch = [[UISwitch alloc] init];
        [_transparentSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _transparentSwitch;
}

- (UISwitch *)tabBarSwitch {
    if (!_tabBarSwitch) {
        _tabBarSwitch = [[UISwitch alloc] init];
        [_tabBarSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValue dumpChanged];
    }
    return _tabBarSwitch;
}



- (void)loadSettings {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.transparentSwitch.on = [d objectForKey:WXLTransparentModeKey] ? [d boolForKey:WXLTransparentModeKey] : WXLDefaultTransparentMode;
    self.tabBarSwitch.on      = [d objectForKey:WXLTabBarEnabledKey] ? [d boolForKey:WXLTabBarEnabledKey] : WXLDefaultTabBarEnabled;
}

- (void)switchChanged:(UISwitch *)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (sender == self.transparentSwitch) {
        [d setBool:sender.on forKey:WXLTransparentModeKey];
    } else if (sender == self.tabBarSwitch) {
        [d setBool:sender.on forKey:WXLTabBarEnabledKey];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"导航栏" : @"底部 TabBar";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) return @"开关即时生效。若无效，请查看 Console 里的 [WXL] 日志。";
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWith把Identifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if (indexPath.section == 0) {
        cell.textLabel.text = @"透明模式";
        cell.accessoryView = self.transparentSwitch;
    } else {
        cell.textLabel.text = @"底栏总开关";
        cell.accessoryView = self.tabBarSwitch;
    }
    return cell;
}

@end
