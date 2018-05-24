//
//  ChatViewController.m
//  TrainingAssistant
//
//  Created by like on 2015/01/25.
//  Copyright (c) 2015年 like. All rights reserved.
//

#import "ChatViewController.h"

@implementation NSMutableAttributedString (atimg)

- (void)insertImage:(UIImage*)image bounds:(CGRect)bounds atIndex:(NSUInteger)index;
 {
    NSTextAttachment *at = [[NSTextAttachment alloc] init];
    at.image = image;
    at.bounds = bounds;
    NSAttributedString *ns = [NSAttributedString attributedStringWithAttachment:at];
    // unicode : NSAttachmentCharacter = 0xFFFC
    
    [self insertAttributedString:ns atIndex:index];
}

@end

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)dataFinishedLoadData:(NSString *)flag{
	
    BOOL isBottom = NO;
    
    //判断当前是否在底部
    if (((int)messageList.contentSize.height - (int)messageList.contentOffset.y <= (int)messageList.bounds.size.height + 1 ) && ((int)messageList.contentSize.height >= (int)messageList.bounds.size.height)) {
        isBottom = YES;
    }
    
    [self reloadData];
    
    if ([flag isEqualToString:@"YES"]) {
        [self scrollToBottom:YES];
        
        [MANAGER_SHOW dismiss];
    }else{
        if (isBottom) {
            [self scrollToBottom:YES];
        }
    }
}

- (void)reloadData {
    [messageList reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    list = [[NSMutableArray alloc] init];
    
    attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            [UIFont systemFontOfSize:16], NSFontAttributeName,
                            nil];
    
    plistDic  = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"]];
    
    [self loadMainView];
    
    messageList.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        //加载新数据
        NSMutableArray *tmpList = [[NSMutableArray alloc] init];
        NSArray *sortArray = [list sortedArrayUsingFunction:intSortChat context:nil];
        if (list.count>0) {
            [[DataManager sharedManager] loadChatList:tmpList Type:0 ChatID:((Chat *)[sortArray objectAtIndex:0]).ID RelationID:self.relationID];
            for (Chat *chat in tmpList) {
                [list insertObject:chat atIndex:0];
            }
        }
        
        if (tmpList.count == 0) {
            [self performSelector:@selector(showInfo) withObject:nil afterDelay:1];
        }
        
        [self performSelector:@selector(dataFinishedLoadData:) withObject:@"NO" afterDelay:0.5];
        
        [messageList.mj_header endRefreshing];
        
    }];
    
    __block int max_id = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_max_id(@"chat", self.relationID) withExecuteBlock:^(NSDictionary *result) {
        max_id = [[[result allValues] firstObject] intValue];
    }];
    
    if (max_id == 0) {//第一次加载数据
        [self loadJsonData:@"2" ChatID:0];
    }else{
        //插入加载照片
        NSMutableArray *tmpList = [[NSMutableArray alloc] init];
        [[DataManager sharedManager] loadChatList:tmpList Type:0 ChatID:0 RelationID:self.relationID];
        NSArray *sortArray = [tmpList sortedArrayUsingFunction:intSortChat context:nil];
        for (Chat  *chat in sortArray) {
            [list addObject:chat];
        }
        [self performSelector:@selector(dataFinishedLoadData:) withObject:@"YES" afterDelay:0.0];
    }
    
    
}

- (void)loadMainView {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(goBack) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:btn];
    
    
    inputViewController = [[InputViewController alloc] init];
    [inputViewController initInputViewController:CGRectMake(0, self.view.frame.size.height-45, inputViewController.view.frame.size.width, inputViewController.view.frame.size.height)];
    inputViewController.relationID = self.relationID;
    inputViewController.delegate = self;
    
    inputViewOriFrame = inputViewController.view.frame;
    
    messageList = [[TableView alloc] initWithFrame:CGRectMake(0, HEADER, self.view.frame.size.width, self.view.frame.size.height - inputViewController.view.frame.size.height - HEADER)];
    tableViewOriFrame = messageList.frame;
    messageList.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    messageList.delegate = self;
    messageList.dataSource =self;
    messageList.parent = self;
    messageList.separatorColor = [UIColor clearColor];
    messageList.backgroundColor = [UIColor colorWithRed:(float)230/255 green:(float)230/255 blue:(float)230/255 alpha:1.0];
    
    [self.view addSubview:messageList];
    [self.view addSubview:inputViewController.view];
}

//type：1 time以前数据  2 time以后数据 
- (void)loadJsonData:(NSString *)type ChatID:(int)chatID {
    if (chatID == 0) {
        __block int max_id = 0;
        [MANAGER_SQLITE executeQueryWithSql:sql_select_max_id(@"chat", self.relationID) withExecuteBlock:^(NSDictionary *result) {
            max_id = [[[result allValues] firstObject] intValue];
        }];
        chatID = max_id;
    }
    
    NSLog(@"uuid = %@", self.relationID);
    NSString *urlStr = [[NSString stringWithFormat:chat_list,Host,self.relationID,chatID,ChatPageCount,[type intValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[DataManager sharedManager] parseJsonData:urlStr FileName:@"chat.json" ShowLoadingMessage:NO JsonType:ParseJsonTypeChat finishCallbackBlock:^(NSMutableArray *result) {
        
        if (![MANAGER_UTIL isEnableNetWork]) {
            [self performSelector:@selector(dataFinishedLoadData:) withObject:@"NO" afterDelay:1];
            return;
        }
        
        [self deleteChat:[result lastObject]];
        
        NSMutableArray *tmpList = [result firstObject];
        [self insertChat:tmpList];
        
        //插入加载照片
        if ([type isEqualToString:@"2"]) {//新数据
            NSArray *sortArray = [tmpList sortedArrayUsingFunction:intSortChat context:nil];
            for (Chat *chat in sortArray) {
                [list addObject:chat];
            }
        }
        
        [self performSelector:@selector(dataFinishedLoadData:) withObject:@"NO" afterDelay:1];
        
    }];

}

- (void)insertChat:(NSMutableArray *)tmpList {
    NSMutableArray *sqlArray = [NSMutableArray new];
    for (Chat *chat in tmpList) {
        NSString *sql = sql_insert_chat(chat, self.relationID);
        [sqlArray addObject:sql];
    }
    [MANAGER_SQLITE beginTransactionWithSqlArray:sqlArray];
}

- (void)showInfo {
    [MANAGER_SHOW showInfo:@"已加载所有信息"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
	return list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MessageCell";
    
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    Chat *chat = [list objectAtIndex:indexPath.row];
    
    Message *message = [[Message alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:chat.createTime];
    
    message.time = date;
    message.realname = chat.realname;
    
    [cell.photo sd_setImageWithURL:IMAGE_URL(chat.avatar) placeholderImage:[UIImage imageNamed:@"default"]];
    
    if (chat.userID == [MANAGER_USER.user.user_id intValue]) {
        message.isReceived = NO;
    } else {
        message.isReceived = YES;
    }
    
    message.messageType = Text;
    

    if (chat.userID == [MANAGER_USER.user.user_id intValue]) {
        message.from = false;
        message.peer = @"receiver";
    } else {
        message.from = true;
        message.peer = @"sender";
    }
    
    message.content = chat.content;
    
    [self replaceEmoticon:message];

    [cell setup:message withWidth:tableView.frame.size.width];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    
   Chat *chat = [list objectAtIndex:indexPath.row];
    
    Message *message = [[Message alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:chat.createTime];
    
    message.time = date;
    
    message.messageType = Text;
    
    if (chat.userID == [MANAGER_USER.user.user_id intValue]) {
        message.from = false;
        message.peer = @"receiver";
    } else {
        message.from = true;
        message.peer = @"sender";
    }
    
    message.content = chat.content;
    [self replaceEmoticon:message];
    
    height = [MessageCell heightOfCellWithContent:message withWidth:tableView.frame.size.width];
    
    return height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replaceEmoticon:(Message *)message {
    if (message.content && ![message.content isEqualToString:@""]) {
        
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]*\\]" options:0 error:nil];//  \\[(.*?)\\]  (?<=\\()[^\\)]+
        NSArray *matches = [reg matchesInString:message.content options:0 range:NSMakeRange(0, [message.content length])];
        int count = 0;
        
        
        NSString *replaceContent=[reg stringByReplacingMatchesInString:message.content options:NSMatchingReportProgress range:NSMakeRange(0, message.content.length) withTemplate:@""];
        
        
        message.attributedContent = [[NSMutableAttributedString alloc] initWithString:replaceContent attributes:attributesDictionary ];
        
        for (NSTextCheckingResult *result in matches) {
            
            NSString *strKey = [message.content substringWithRange:result.range];
            
            [message.attributedContent insertImage:[UIImage imageNamed:[plistDic objectForKey:strKey]]  bounds:CGRectMake(2, -5, 24, 24) atIndex:result.range.location-count];
            
            count = count + (int)result.range.length -1;
        }
    }
}


- (void) inputViewFrameChang:(CGRect)frame {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:KeyboardAnimationDuration];
    messageList.frame = CGRectMake(tableViewOriFrame.origin.x,tableViewOriFrame.origin.y,tableViewOriFrame.size.width,tableViewOriFrame.size.height - (inputViewOriFrame.origin.y - frame.origin.y));
    
    [UIView commitAnimations];
    
    /*if (inputViewController.isScrollToToBottom == YES) {
        [self performSelector:@selector(scrollToBottom:) withObject:@"1" afterDelay:.02];
        inputViewController.isScrollToToBottom = NO;
    }*/
    
    [self scrollToBottom:NO];
    
}


- (void)scrollToBottom:(BOOL)animated {
    CGFloat yOffset = 0;
    
    if (messageList.contentSize.height > messageList.bounds.size.height) {
        yOffset = messageList.contentSize.height - messageList.bounds.size.height;
    }
    
    [messageList setContentOffset:CGPointMake(0, yOffset) animated:NO];
    /*NSUInteger rowCount = [messageList numberOfRowsInSection:0];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:0];
    [messageList scrollToRowAtIndexPath:indexPath  atScrollPosition:UITableViewScrollPositionBottom animated:NO];*/
}


- (void) sendMessageEnd {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSData *fileData = [fm contentsAtPath:[MANAGER_FILE.CSDownloadPath stringByAppendingPathComponent:@"json/mychat.json"]];
    if(fileData) {
        
        [self parseJsonData:fileData Type:@"2"];
        
        [self performSelector:@selector(dataFinishedLoadData:) withObject:@"YES" afterDelay:1];
    }
}

- (void)parseJsonData:(NSData *)data Type:(NSString *)type {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (json == nil) {
        NSLog(@"json parse failed \r\n");
        return;
    }
    
    NSMutableArray *tmpList = [[NSMutableArray alloc] init];
    
    NSString *status = [json objectForKey:@"status"];
    if ([status intValue] == 1) {
        
        NSArray *array = [json objectForKey:@"chat"];
        
        for (NSDictionary *dict in array) {
            Chat *chat = [[Chat alloc] initWithDictionary:dict];
            [tmpList addObject:chat];
        }
        
        [self deleteChat:[json objectForKey:@"delete_chat"]];
    }
    
    [self insertChat:tmpList];
    
    //插入加载照片
    if ([type isEqualToString:@"2"]) {//新数据
        NSArray *sortArray = [tmpList sortedArrayUsingFunction:intSortChat context:nil];
        for (Chat *chat in sortArray) {
            [list addObject:chat];
        }
    }
}

- (void)deleteChat:(NSArray *)delArray {
    for (NSString *ID in delArray) {
        
        NSPredicate *thirtiesPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@" ID == %@ ",ID]];
        NSArray *dlArray = [list filteredArrayUsingPredicate:thirtiesPredicate];
        if (dlArray.count > 0) {
            [list removeObject:[dlArray objectAtIndex:0]];
        }
    }
    
    NSString *strID = [delArray description];
    strID = [strID stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    strID = [strID stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [MANAGER_SQLITE executeUpdateWithSql:sql_delete_chat(strID)];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:LoadServerMessageTime target:self selector:@selector(receiverMessage) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([timer isValid]) {
        [timer invalidate];
    }
}

- (void)receiverMessage {
    __block int max_id = 0;
    [MANAGER_SQLITE executeQueryWithSql:sql_select_max_id(@"chat", self.relationID) withExecuteBlock:^(NSDictionary *result) {
        max_id = [[[result allValues] firstObject] intValue];
    }];
    [self loadJsonData:@"2" ChatID:max_id];
}

@end
