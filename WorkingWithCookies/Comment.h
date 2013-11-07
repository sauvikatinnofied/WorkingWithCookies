//
//  Comment.h
//  CommentsJSONParser
//
//  Created by Sandip Saha on 26/09/13.
//  Copyright (c) 2013 Sandip Saha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
@property (strong,nonatomic)NSString *userName;
@property (strong,nonatomic)NSString *name;
@property (strong,nonatomic)NSString *profileUrl;
@property (strong,nonatomic)NSString *raw_message;


-(id)initCommentWithDataDictionary:(NSDictionary*)dataDictionary;

-(void)display;
@end
