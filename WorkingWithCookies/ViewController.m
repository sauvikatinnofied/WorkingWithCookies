//
//  ViewController.m
//  WorkingWithCookies
//
//  Created by Sandip Saha on 28/09/13.
//  Copyright (c) 2013 Sandip Saha. All rights reserved.
//

#import "ViewController.h"
#import "NetworkRequestHandler.h"
#import "Comment.h"
#define kServerBaseUrl   @"https://disqus.com"



@interface ViewController ()

@end

@implementation ViewController
@synthesize allcookies,imageView;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //=================Working with cookies=======================
    //Request URL: https://disqus.com/profile/login/?next=https://disqus.com/
    
    
    NSMutableDictionary *userData=[[NSMutableDictionary alloc]init];
    [userData setObject:@"pujagallery_innofied" forKey:@"username"];
    [userData setObject:@"innofied#123" forKey:@"password"];
    
    
    __block NetworkRequestHandler *logInRequest=[[NetworkRequestHandler alloc]initWithBaseURLString:@"https://disqus.com" objectPathInURL:@"/profile/login/?next=https://disqus.com/" dataDictionaryToPost:userData];
    //---------------fetching cookies data for anonymous  user from disqus-------------
    
    [logInRequest setCompletionHandler:^{
        
       // NSLog(@"%@",[logInRequest httpResponseHeaders]);
        //NSLog(@"\nCookies=%@",[logInRequest.httpResponseHeaders objectForKey:@"cookie"]);
        
        NSLog(@"Cookies from server after login=%@",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://disqus.com"]]);
        
    }];
    
    [logInRequest startDownload];
    
    
    
    /*NSMutableDictionary *postData=[[NSMutableDictionary alloc]init];
    [postData setObject:@"Post for testing." forKey:@"message"];
    [postData setObject:@"1788564545" forKey:@"thread"];
    [postData setObject:@"E8Uh5l5fHZ6gD8U3KycjAIAk46f68Zw7C6eW8WSjZvCLXebZ7p0r1yrYDrLilk2F" forKey:@"api_key"];
    [postData setObject:@"sauvik@innofied.com" forKey:@"author_email"];
    [postData setObject:@"Sauvik " forKey:@"author_name"];
    
    
    NetworkRequestHandler *commentUploader=[[NetworkRequestHandler alloc]initWithBaseURLString:@"https://disqus.com" objectPathInURL:@"/api/3.0/posts/create.json" dataDictionaryToPost:postData];
    
    [commentUploader setCompletionHandler:^{
        
        printf("\nDisqus response=%s",[commentUploader.responseString UTF8String]);
    }];
    [commentUploader setErrorHandler:^(NSError *postError)
    {
        
        printf("\nDisqus response=%s",[[postError localizedDescription]UTF8String]);
    }];
     
    [commentUploader startDownload];
     */
    
    
    
    [self getCommentFromThread:@"1788564545"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    allcookies = [HTTPResponse allHeaderFields];
    NSLog(@"all cookies=\n%@",allcookies);
    //NSString *cookie = [fields valueForKey:@"Set-Cookie"]; // It is your cookie
}


-(void)getCommentFromThread:(NSString *)localThread
{
    
    
   // NSString *objectPath=[NSString stringWithFormat:@"/api/3.0/threads/listPosts.json?thread=%@&forum=pujagallery&api_key=E8Uh5l5fHZ6gD8U3KycjAIAk46f68Zw7C6eW8WSjZvCLXebZ7p0r1yrYDrLilk2F",localThread];
    
    NetworkRequestHandler *commentJSONDonloader=[[NetworkRequestHandler alloc ]initWithBaseURLString:@"https://disqus.com/api/3.0/threads/listPosts.json?thread=1788564545&forum=pujagallery&api_key=gsBxzqAo49wwEaklWSNGtcAILpnbm3D7oWpBRPmMBAv0bkcQjYO8Cn7EQUDl6T07" objectPathInURL:nil dataDictionaryToPost:nil];
    
    [commentJSONDonloader setCompletionHandler:^{
       
        NSDictionary *commentJSONDictionary = [NSJSONSerialization JSONObjectWithData:commentJSONDonloader.responseData
                                                                                   options:NSJSONReadingMutableContainers
                                                                                     error:nil];
        
        
        if([commentJSONDictionary objectForKey:@"response"])//returns true after successful download
        {
            NSArray *dataCointainer=[commentJSONDictionary objectForKey:@"response"];
            
            for(int i=0;i<[dataCointainer count];i++)
            {
                //make an instance of the ImageFrammeContent
                //add it to the proper array
                
                NSDictionary *commentdictionary=[dataCointainer[i] objectForKey:@"author"];
                
                Comment *newComment=[[Comment alloc]init];
                newComment.userName=[commentdictionary objectForKey:@"name"];
                newComment.raw_message=[dataCointainer[i] objectForKey:@"raw_message"];
                printf("\n++++++++++++++++++++Cooment details for %ith user+++++++++++++++++\n\n",i);
                printf("\nName=%s",[newComment.userName UTF8String]);
                printf("\nRaw Message=%s",[newComment.raw_message UTF8String]);
                printf("\n++++++++++++++++++++Cooment details for %ith user+++++++++++++++++\n\n",i);
                
               // NSLog(@"\nThe avatar dictionary=%@",[commentdictionary objectForKey:@"avatar"]);
                
                NSString *authorImageURL;
                if([[commentdictionary objectForKey:@"avatar"]objectForKey:@"cache"])//going to parse if cache is available
                {
                  authorImageURL=[[commentdictionary objectForKey:@"avatar"] objectForKey:@"cache"];//getting the image URL
                  
                    if([authorImageURL rangeOfString:@"_id"].location==123)//the user does not have any profile in disqus
                    {
                        //set the default picture here
                

                    }
                    else//user has a profile in disqus
                    {
                        //manupulating the string the get it's usable format
                        authorImageURL=[authorImageURL substringFromIndex:2];
                        authorImageURL=[authorImageURL substringToIndex:[authorImageURL rangeOfString:@"?"].location];
                        authorImageURL =[@"http://" stringByAppendingString:authorImageURL];
                        
                        printf("\nUser's profile pic url=%s",[authorImageURL UTF8String]);
                                        
                       
                    }
                    
                }
                
           
                
                
                NetworkRequestHandler *imageDownloader=[[NetworkRequestHandler alloc]initWithBaseURLString:authorImageURL objectPathInURL:nil dataDictionaryToPost:nil];
                [imageDownloader setCompletionHandler:^{
                   
                    self.imageView.image=[UIImage imageWithData:imageDownloader.responseData];
                }];
                
                [imageDownloader startDownload];
                
            }
            
            
        }
        else
        {
            NSLog(@"ERROR in JSON Parsing\n");
        }
        
        
    }];
    
    [commentJSONDonloader startDownload];
    
}

@end
