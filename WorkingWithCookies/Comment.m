//
//  Comment.m
//  CommentsJSONParser
//
//  Created by Sandip Saha on 26/09/13.
//  Copyright (c) 2013 Sandip Saha. All rights reserved.
//

#import "Comment.h"

@implementation Comment
@synthesize  userName,name,profileUrl,raw_message;
-(id)initCommentWithDataDictionary:(NSDictionary*)dataDictionary
{
    
    if(self=[super init])
    {
        self.userName=[dataDictionary objectForKey:@"username"];
        self.name=[dataDictionary objectForKey:@"name"];
        self.profileUrl=[dataDictionary objectForKey:@"profileUrl"];
        self.raw_message=[dataDictionary objectForKey:@"raw_message"];
    }
    
    return  self;
    
}

-(void)display
{
    static int i=1;
    printf("\n\n==================Comments No:%i=====================",i);
    printf("\nuserName=%s",[self.userName UTF8String]);
    printf("\name=%s",[self.name UTF8String]);
    printf("\nprofileUrl=%s",[self.profileUrl UTF8String]);
    printf("\raw_message=%s",[self.raw_message UTF8String]);
    printf("\n\n==================Comments No:%i ends=====================",i);
    i++;
    
}

@end
