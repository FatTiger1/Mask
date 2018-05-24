//
//  ParseManager.m
//  CloudClassRoom
//
//  Created by rgshio on 16/1/19.
//  Copyright © 2016年 like. All rights reserved.
//

#import "ParseManager.h"

static ParseManager *parseManager = nil;
@implementation ParseManager

#pragma mark - Private
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parseManager = [[ParseManager alloc] init];
    });
    
    return parseManager;
}

+ (instancetype)alloc {
    NSAssert(parseManager == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Common
- (NSDictionary *)parseJsonToDict:(id)obj {
    if (obj) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:nil];
        if (dict) {
            return dict;
        }else {
            NSLog(@"parse json failure");
            return nil;
        }
    }else {
        return nil;
    }
}

- (NSString *)parseJsonToStr:(id)obj {
    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
    return str;
}

- (NSMutableArray *)loadImsmanifestXML:(NSData *)XMLData {
    [DataManager sharedManager].isHaveChild = NO;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:XMLData options:0 error:nil];
    
    CXMLElement *root = [document rootElement];
    
    NSArray *users = [root children];
    ImsmanifestXML *ims = [[ImsmanifestXML alloc] init];
    
    for (CXMLElement *element in users) {
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"organizations"]) {
            ims.ID = [[element attributeForName:@"default"] stringValue];
            for (int i = 0; i < [element childCount]; i++) {
                
                if ([[[element children] objectAtIndex:i] isKindOfClass:[CXMLElement class]]) {
                    if([[[element childAtIndex:i] name] isEqualToString:@"organization"]) {
                        
                        NSArray *organizations = [[element childAtIndex:i] children];
                        
                        for (CXMLElement *organization in organizations) {
                            if ([organization isKindOfClass:[CXMLElement class]]&&[[organization name] isEqualToString:@"item"]) {
                                
                                ImsmanifestXML *imsmanifest = [[ImsmanifestXML alloc] init];
                                imsmanifest.ID = [[organization attributeForName:@"identifier"] stringValue];
                                imsmanifest.identifierref = [[organization attributeForName:@"identifierref"] stringValue];
                                if ([[[[organization attributeForName:@"isvisible"] stringValue] lowercaseString] isEqualToString:@"true"]) {
                                    imsmanifest.isvisible = YES;
                                }else{
                                    imsmanifest.isvisible = NO;
                                }
                                
                                NSArray *items = [organization children];
                                
                                for (CXMLElement *item in items) {
                                    
                                    if ([item isKindOfClass:[CXMLElement class]]&&[[item name] isEqualToString:@"title"]) {
                                        imsmanifest.title = [item stringValue];
                                        [list addObject:imsmanifest];
                                    }
                                    
                                    if ([item isKindOfClass:[CXMLElement class]]&&[[item name] isEqualToString:@"item"]) {
                                        for (int j = 0; j < [item childCount]; j++) {
                                            if ([[[item children] objectAtIndex:j] isKindOfClass:[CXMLElement class]]) {
                                                if([[[item childAtIndex:j] name] isEqualToString:@"title"]) {
                                                    ImsmanifestXML *cellImsmanifest = [[ImsmanifestXML alloc] init];
                                                    
                                                    cellImsmanifest.title = [[item childAtIndex:j] stringValue];
                                                    cellImsmanifest.identifierref = [[item attributeForName:@"identifierref"] stringValue];
                                                    
                                                    if ([[[[item attributeForName:@"isvisible"] stringValue] lowercaseString] isEqualToString:@"true"]) {
                                                        cellImsmanifest.isvisible = YES;
                                                    }else{
                                                        cellImsmanifest.isvisible = NO;
                                                    }
                                                    
                                                    [DataManager sharedManager].isHaveChild = YES;
                                                    [imsmanifest.cellList addObject:cellImsmanifest];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (! [DataManager sharedManager].isHaveChild) {
        [ims.cellList addObjectsFromArray:list];
        [list removeAllObjects];
        [list addObject:ims];
    }
    
    for (CXMLElement *element in users) {
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"resources"]) {
            NSArray *items = [element children];
            
            for (CXMLElement *item in items) {
                if ([item isKindOfClass:[CXMLElement class]]) {
                    if([[item name] isEqualToString:@"resource"]) {
                        for (ImsmanifestXML *imsmanifest in list) {
                            
                            if ([[[[item attributeForName:@"identifier"] stringValue] lowercaseString] isEqualToString:[imsmanifest.identifierref lowercaseString]]) {
                                
                                imsmanifest.resource = [[[item attributeForName:@"href"] stringValue] lowercaseString];
                            }
                            for (ImsmanifestXML *imsmanifest2 in imsmanifest.cellList) {
                                
                                if ([[[[item attributeForName:@"identifier"] stringValue] lowercaseString] isEqualToString:[imsmanifest2.identifierref lowercaseString]]) {
                                    imsmanifest2.resource = [[[item attributeForName:@"href"] stringValue] lowercaseString];
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    return list;
}



- (NSMutableArray *)loadMicroReadXML:(NSData *)XMLData {
    [DataManager sharedManager].microIsHaveChild = NO;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    ImsmanifestXML *ims = [[ImsmanifestXML alloc] init];
    
    TBXML *tbxml = [TBXML newTBXMLWithXMLData:XMLData error:nil];
    TBXMLElement *rootEle = tbxml.rootXMLElement;

    if (rootEle) {
        TBXMLElement *resultEle = [TBXML childElementNamed:@"organizations" parentElement:rootEle];
        if (resultEle) {
            ims.ID = [TBXML valueOfAttributeNamed:@"default" forElement:resultEle];
            
            TBXMLElement *dataEle = [TBXML childElementNamed:@"organization" parentElement:resultEle];
            if (dataEle) {
                TBXMLElement *oneItemEle = [TBXML childElementNamed:@"item" parentElement:dataEle];
                while (oneItemEle) {
                    ImsmanifestXML *imsmanifest = [[ImsmanifestXML alloc] init];
                    imsmanifest.ID = [TBXML valueOfAttributeNamed:@"identifier" forElement:oneItemEle];
                    imsmanifest.identifierref = [TBXML valueOfAttributeNamed:@"identifierref" forElement:oneItemEle];
                    if ([[TBXML valueOfAttributeNamed:@"isvisible" forElement:oneItemEle] isEqualToString:
                         @"true"]) {
                        imsmanifest.isvisible = YES;
                    }else{
                        imsmanifest.isvisible = NO;
                    }
                    TBXMLElement *oneTitleEle = [TBXML childElementNamed:@"title" parentElement:oneItemEle];
                    if (oneTitleEle) {
                        imsmanifest.title = [TBXML textForElement:oneTitleEle];
                        [list addObject:imsmanifest];
                    }
                    TBXMLElement *childItemEle = [TBXML childElementNamed:@"item" parentElement:oneItemEle];
                    while (childItemEle) {
                        ImsmanifestXML *cellImsmanifest = [[ImsmanifestXML alloc] init];
                        cellImsmanifest.identifierref = [TBXML valueOfAttributeNamed:@"identifierref" forElement:childItemEle];
                        if ([[TBXML valueOfAttributeNamed:@"isvisible" forElement:childItemEle] isEqualToString:
                             @"true"]) {
                            imsmanifest.isvisible = YES;
                        }else{
                            imsmanifest.isvisible = NO;
                        }
                        
                        TBXMLElement *childTitleEle = [TBXML childElementNamed:@"title" parentElement:childItemEle];
                        if (childItemEle) {
                            cellImsmanifest.title = [TBXML textForElement:childTitleEle];
                        }
                        
                        [DataManager sharedManager].microIsHaveChild = YES;
                        [imsmanifest.cellList addObject:cellImsmanifest];
                        childItemEle = [TBXML nextSiblingNamed:@"item" searchFromElement:childItemEle];
                    }
                    oneItemEle = [TBXML nextSiblingNamed:@"item" searchFromElement:oneItemEle];
                }
            }
        }
    }
    
    
    if (! [DataManager sharedManager].microIsHaveChild) {
        [ims.cellList addObjectsFromArray:list];
        [list removeAllObjects];
        [list addObject:ims];
    }
    
    
    if (rootEle) {
        TBXMLElement *resultEle = [TBXML childElementNamed:@"resources" parentElement:rootEle];
        if (resultEle) {
            TBXMLElement *dataEle = [TBXML childElementNamed:@"resource" parentElement:resultEle];
            while(dataEle !=nil) {
                
                for (ImsmanifestXML *imsmanifest in list) {
                    if ([[imsmanifest.identifierref lowercaseString] isEqualToString:[[TBXML valueOfAttributeNamed:@"identifier" forElement:dataEle] lowercaseString]]) {
                        imsmanifest.resource = [TBXML valueOfAttributeNamed:@"href" forElement:dataEle];
                    }
                    for (ImsmanifestXML *imsmanifest2 in imsmanifest.cellList) {
                        if ([[imsmanifest2.identifierref lowercaseString] isEqualToString:[[TBXML valueOfAttributeNamed:@"identifier" forElement:dataEle] lowercaseString]]) {
                            imsmanifest2.resource = [TBXML valueOfAttributeNamed:@"href" forElement:dataEle];
                        }
                    }
                }
                
                dataEle = [TBXML nextSiblingNamed:@"resource" searchFromElement:dataEle];
            }
        }
    }
    
    return list;
}


/**
 * RecommendBooks文件解析
 */
- (NSMutableArray *)loadRecommendBooksXML:(NSData *)XMLData{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:XMLData options:0 error:nil];
    
    NSArray *users = [document nodesForXPath:@"//book" error:nil];
    
    for (CXMLElement *element in users) {
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"book"]) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            for (int i=0; i<[element childCount]; i++) {
                if ([[[element children] objectAtIndex:i] isKindOfClass:[CXMLElement class]]) {
                    [item setObject:[[element childAtIndex:i] stringValue]
                             forKey:[[element childAtIndex:i] name]];
                }
            }
            
            [list addObject:item];
        }
        
    }
    
    return list;
}

- (NSMutableArray *)loadCourseXML:(NSData *)XMLData {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:XMLData options:0 error:nil];
    
    CXMLElement *root = [document rootElement];
    
    NSArray *users = [root children];
    
    int courseID = 0;
    
    for (CXMLElement *element in users) {
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"nav"]) {
            CourseXML *coursexml = [[CourseXML alloc] init];
            coursexml.ID = courseID++;
            coursexml.title = [[element attributeForName:@"name"] stringValue];
            coursexml.action = [[element attributeForName:@"action"] stringValue];
            coursexml.src = [[element attributeForName:@"src"] stringValue];
            coursexml.cellList = [[NSMutableArray alloc] init];
            
            int cellID = 0;
            
            for (CXMLElement *nav in [element children]) {
                if ([nav isKindOfClass:[CXMLElement class]]) {
                    CourseXML *cellxml = [[CourseXML alloc] init];
                    cellxml.ID = cellID++;
                    cellxml.title = [[nav attributeForName:@"title"] stringValue];
                    coursexml.action = [[element attributeForName:@"action"] stringValue];
                    cellxml.src = [[nav attributeForName:@"src"] stringValue];
                    
                    [coursexml.cellList addObject:cellxml];
                }
            }
            
            if (![coursexml.action isEqualToString:@"exit"]) {
                [list addObject:coursexml];
            }
        }
    }
    
    return list;
}

- (NSMutableDictionary *)loadDataXML:(NSData *)XMLData {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:XMLData options:0 error:nil];
    CXMLElement *root = [document rootElement];
    
    NSArray *users = [root children];
    int pageID = 0;
    int questionID = 0;
    int sectionID = 0;
    
    NSMutableArray *pageList = [[NSMutableArray alloc] init];
    NSMutableArray *sectionList = [[NSMutableArray alloc] init];
    NSMutableArray *questionList = [[NSMutableArray alloc] init];
    ExamXML *examxml = [[ExamXML alloc] init];
    
    for (CXMLElement *element in users) {
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"document"]) {
            for (CXMLElement *page in [element children]) {
                if ([page isKindOfClass:[CXMLElement class]]&&[[page name] isEqualToString:@"page"]) {
                    PageXML *pagexml = [[PageXML alloc] init];
                    pagexml.ID = ++pageID;
                    pagexml.posString = [[page attributeForName:@"pos"] stringValue];
                    pagexml.pos = [MANAGER_UTIL posToPosString:pagexml.posString];
                    [pageList addObject:pagexml];
                }
            }
        }
        
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"menu"]) {
            for (CXMLElement *section in [element children]) {
                if ([section isKindOfClass:[CXMLElement class]]&&[[section name] isEqualToString:@"section"]) {
                    SectionXML *sectionxml = [[SectionXML alloc] init];
                    sectionxml.perID = 0;
                    sectionxml.ID = sectionID++;
                    sectionxml.title = [[section attributeForName:@"title"] stringValue];
                    sectionxml.posString = [[section attributeForName:@"pos"] stringValue];
                    sectionxml.pos = [MANAGER_UTIL posToPosString:sectionxml.posString];
                    sectionxml.level = 0;
                    sectionxml.cellList = [[NSMutableArray alloc] init];
                    
                    for (CXMLElement *sectionCell in [section children]) {
                        if ([sectionCell isKindOfClass:[CXMLElement class]]&&[[sectionCell name] isEqualToString:@"section"]) {
                            SectionXML *cellSectionxml = [[SectionXML alloc] init];
                            cellSectionxml.perID = sectionxml.ID;
                            cellSectionxml.ID = sectionID++;
                            cellSectionxml.title = [[sectionCell attributeForName:@"title"] stringValue];
                            cellSectionxml.posString = [[sectionCell attributeForName:@"pos"] stringValue];
                            cellSectionxml.pos = [MANAGER_UTIL posToPosString:cellSectionxml.posString];
                            cellSectionxml.level = 1;
                            [sectionxml.cellList addObject:cellSectionxml];
                        }
                    }
                    
                    [sectionList addObject:sectionxml];
                }
            }
        }
        
        if ([element isKindOfClass:[CXMLElement class]]&&[[element name] isEqualToString:@"exam"]) {
            examxml.examPrenumber = [[[element attributeForName:@"exam_prenumber"] stringValue] intValue];
            
            if ([[[[element attributeForName:@"title_predisorder"] stringValue] lowercaseString] isEqualToString:@"true"]) {
                examxml.titlePredisorder = YES;
            }else{
                examxml.titlePredisorder = NO;
            }
            
            if ([[[[element attributeForName:@"option_predisorder"] stringValue] lowercaseString] isEqualToString:@"true"]) {
                examxml.optionPredisorder = YES;
            }else{
                examxml.optionPredisorder = NO;
            }
            
            examxml.examNumber = [[[element attributeForName:@"exam_number"] stringValue] intValue];
            
            if ([[[[element attributeForName:@"title_disorder"] stringValue] lowercaseString] isEqualToString:@"true"]) {
                examxml.titleDisorder = YES;
            }else{
                examxml.titleDisorder = NO;
            }
            
            if ([[[[element attributeForName:@"option_disorder"] stringValue] lowercaseString] isEqualToString:@"true"]) {
                examxml.optionDisorder = YES;
            }else{
                examxml.optionDisorder = NO;
            }
            
            for (CXMLElement *question in [element children]) {
                if ([question isKindOfClass:[CXMLElement class]]&&[[question name] isEqualToString:@"question"]) {
                    QuestionXML *questionxml = [[QuestionXML alloc] init];
                    questionxml.ID = ++questionID;
                    questionxml.title = [[question attributeForName:@"title"] stringValue];
                    questionxml.answer = [[[question attributeForName:@"answer"] stringValue] uppercaseString];
                    questionxml.point = [[question attributeForName:@"point"] stringValue];
                    questionxml.posString = [[question attributeForName:@"pos"] stringValue];
                    questionxml.pos = [MANAGER_UTIL posToPosString:questionxml.posString];
                    
                    if ([[[question attributeForName:@"pre"] stringValue] isEqualToString:@"0"]) {
                        questionxml.pre = NO;
                    }else{
                        questionxml.pre = YES;
                    }
                    questionxml.optionList = [[NSMutableArray alloc] init];
                    
                    int optionID = 0;
                    
                    for (CXMLElement *option in [question children]) {
                        if ([option isKindOfClass:[CXMLElement class]]&&[[option name] isEqualToString:@"option"]) {
                            OptionXML *optionxml = [[OptionXML alloc] init];
                            optionxml.ID = ++optionID;
                            optionxml.title = [[option attributeForName:@"title"] stringValue];
                            if ([questionxml.answer rangeOfString:[MANAGER_UTIL idToanswer:optionxml.ID - 1]].location != NSNotFound) {
                                optionxml.isAnswer = YES;
                            }else{
                                optionxml.isAnswer = NO;
                            }
                            
                            [questionxml.optionList addObject:optionxml];
                        }
                    }
                    
                    [questionList addObject:questionxml];
                }
            }
        }
        
    }
    
    
    [dictionary setObject:pageList forKey:@"PAGE"];
    [dictionary setObject:sectionList forKey:@"SECTION"];
    [dictionary setObject:questionList forKey:@"QUESTION"];
    [dictionary setObject:examxml forKey:@"EXAM"];
    
    return dictionary;
}

@end
