//
//  NetworkRequestHandler.m
//  PasingTest
//
//  Created by Sandip Saha on 18/09/13.
//  Copyright (c) 2013 Sandip Saha. All rights reserved.
//

#define BASE_SERVER_ADDRESS @"http://innofiedpujagallery.nodejitsu.com"



#import "NetworkRequestHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>

//to supress the incomplete implementation warning
#pragma clang diagnostic ignored "-Wincomplete-implementation"


@implementation NetworkRequestHandler


//Sysnthesizing properties for the the input data 
@synthesize requestDataDictionary,baseURL,objectPathInURL;

//Sysnthesizing the own data properties
@synthesize responseData,responseStatusCode,responseStatusString,responseString,
            getConnection,uploadProgressionFraction,totalBytesToBeDownloaded,
            bytesDownloadedSoFar,downloadProgressionFraction,httpResponseHeaders;


//**********************************************************************
//                  The init method for simple data upload or download
//**********************************************************************
-(id)initWithBaseURLString:(NSString*)inputBaseURL
           objectPathInURL:(NSString*)inputObjectPath
      dataDictionaryToPost:(NSDictionary*)dataDictionary
{
    if(self=[super init])
    {
        if(!inputBaseURL)
        {
           self.baseURL=BASE_SERVER_ADDRESS;
           NSLog(@"NetworkRequestHandler WARNING:server base adderss is missing,defauly base address( \"http://innofiedpujagallery.nodejitsu.com) is setted");
        }
        else
        {
            self.baseURL=inputBaseURL;
            
        }
        
        
        if(!inputObjectPath && !inputBaseURL)
        {
            NSLog(@"NetworkRequestHandler ERROR:baseURL & objectpathInURL both can not be nil,returning nil object ");
            return nil;          
        }
        else
        {
            self.objectPathInURL=inputObjectPath;
        }
        
        if(dataDictionary)
        {
            self.requestDataDictionary=dataDictionary;
            NSLog(@"NetworkRequestHandler REPORTS:request data dictionary is not ,user wants a POST connection ");
        }
        else
        {
            NSLog(@"NetworkRequestHandler WARNING:request data dictionary is nil,user wants a GET connection ");
         
        }

        //allocating memory for the output properties
        
        self.responseStatusString =[[NSString alloc]init];
        self.responseData = [NSMutableData data];
        self.responseString=[[NSString alloc]init];
        
    }
    
    return self;
}






 //**************************************************************************************************
 //                  This init method will be used for multipart data(only image) upload or download
 //***************************************************************************************************
 
-(id)initToUpLoadDataWithBaseURLString:(NSString*)inputBaseURL
                       objectPathInURL:(NSString*)inputObjectPath
                  dataDictionaryToPost:(NSDictionary*)uploadDataDictionary
{
    if(self=[super init])
    {
        if(!inputBaseURL)
        {
            self.baseURL=BASE_SERVER_ADDRESS;
            NSLog(@"NetworkRequestHandler WARNING:server base adderss is missing,defauly base address( \"http://innofiedpujagallery.nodejitsu.com) is setted");
        }
        else
        {
            self.baseURL=inputBaseURL;
            
        }
        
        
        if(!inputObjectPath && !inputBaseURL)
        {
            NSLog(@"NetworkRequestHandler ERROR: inputBaseURL & objectpathInURL both can not be nil,returning nil object ");
            return nil;
        }
        else
        {
            self.objectPathInURL=inputObjectPath;
        }
        
        if(uploadDataDictionary)
        {
            self.requestDataDictionary=uploadDataDictionary;
        }
        else
        {
            NSLog(@"NetworkRequestHandler ERROR:request data dictionary is nil,OBJECT INITIALIZATION ERROR ,NOTHING TO UPLOAD ,returning nil");
            return nil;
            
        }
        
        //allocating memory for the output properties
        
        self.responseStatusString =[[NSString alloc]init];
        self.responseData = [NSMutableData data];
        self.responseString=[[NSString alloc]init];
        
    }
    
    return self;

    
}


//**************************************************************
//              START DOWNLOAD METHOD
//*************************************************************

-(void)startDownload
{
  
    
    if(self.requestDataDictionary)//initializing connection for POST method
    {
        NSURL *url = [NSURL URLWithString:self.baseURL];
   
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
        [httpClient postPath:self.objectPathInURL
                  parameters:self.requestDataDictionary
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        //when request is successful then setting the output properties
                     
                        self.httpResponseHeaders=[operation.response allHeaderFields];
                        self.responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        self.responseData=responseObject;
                        self.responseStatusCode=[NSString stringWithFormat:@"%i",operation.response.statusCode ];  
                                     
                        //-----executing the block of code which is defined from the view
                        //      controller/or from where the this Class instance is needed
                        if (self.completionHandler)
                             self.completionHandler();
   
                        NSLog(@"NetworkRequestHandler REPORTS:downloaad request successfull....");
                     
                    }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)//on failure this block is executed
                    {
                     
                        self.responseStatusCode=[NSString stringWithFormat:@"%i",operation.response.statusCode];
                        self.responseStatusString=[NSString stringWithString:error.localizedDescription];
                        
                        if (self.errorHandler)
                            self.errorHandler(error);
                        
                        
                        NSLog(@"NetworkRequestHandler ERROR:%@", error.localizedDescription);
                    }];
    }
    else//initializing connection for GET method
    {
        //=================================================
        //  1.Append Base and objectPath URL
        //  2.Set the delegate for this urlConnection
        
        NSString *getURLString;
        if(self.objectPathInURL)
        {
            getURLString=[self.baseURL stringByAppendingString:self.objectPathInURL];
        }
        else{
            getURLString=self.baseURL;
        }
        NSURLRequest *getRequest=[[NSURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:getURLString]];
        self.getConnection=[[NSURLConnection alloc]initWithRequest:getRequest delegate:self];
    }

}

//**************************************************************
//              CANCEL DOWNLOAD METHOD
//*************************************************************

-(void)cancelDownload
{
    //=====================TASKS===================
    //  1.Cancel the connection
    //  2.Deallocate all the resources currently consuming memory
    
    self.responseData = nil;
    self.responseString=nil;
    self.requestDataDictionary=nil;
    self.getConnection=nil;
    
    
}




//**************************************************************
//              START UPLOAD METHOD
//**************************************************************

-(void)startUpload
{
    
    NSString *strServerURL = [self.baseURL stringByAppendingString:self.objectPathInURL];
    
    NSURL *URL = [NSURL URLWithString:strServerURL];
    __block AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:URL];
    
    
    //-------------------------Configuring the NSMutable Request---------------------------
    
    __block NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"
                                                                     path:@""
                                                               parameters:nil
                                                constructingBodyWithBlock:
                                    ^(id <AFMultipartFormData>formData)
                                    {
                                        
                                        // clubName
                                        NSData *clubName = [[self.requestDataDictionary objectForKey:@"clubName" ] dataUsingEncoding:NSUTF8StringEncoding];
                                        if(!clubName)
                                        {
                                            NSLog(@"\nNetworkResourceDownloader WARNING:No Club Name is not avaliavle while uploading images");
                                            
                                        }
                                        else
                                        {
                                            [formData appendPartWithFormData:clubName name:@"clubName"];
                                        }
                                        
                                        // Description for Images 
                                        NSData *imageDescription = [[self.requestDataDictionary objectForKey:@"description" ]  dataUsingEncoding:NSUTF8StringEncoding];
                                        if(!imageDescription)
                                        {
                                            NSLog(@"\nNetworkResourceDownloader WARNING:No description is not avaliavle while uploading images");
                                            
                                        }
                                        else
                                        {
                                           [formData appendPartWithFormData:imageDescription name:@"description"];
                                        }
                                        
                                        
                                        // -----------------------adding images to body of the HTTP request---------------------
                                        // add two functions for extracting file name and mime type of the file path
                                        
                                        
                                        //**************************************TASK******************************************
                                        //  1.Find out the string arrary with in the requestDataDictionary coinatinig the paths of images
                                        //  2.Iterates through the array
                                        //      2.1.make NSData for this image path
                                        //      2.2 find out the file name from the image path
                                        //      2.3 find out the mime type of this image from the file extention
                                        
                                        
                                        NSArray *imageFilePaths=[self.requestDataDictionary objectForKey:@"imageFilePaths" ];
                                        
                                        if(!imageFilePaths)
                                        {
                                            NSLog(@"\nNetworkResourceDownloader ERROR:No imagepath is  avaliavle while uploading images:Uploading cancelled...");
                                            return ;
                                        }
                                        else
                                        {
                                            for(int i=0;i<[imageFilePaths count];i++)
                                            {
                                            
                                                //------fetchin data from the disk-----------------
                                                NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[imageFilePaths objectAtIndex:i]]];
                                            
                                                NSString *fileName=[self fileNameFromFilePath:[imageFilePaths objectAtIndex:i]];
                                                NSString *fileMimeType=[self fileMimeTypeFromFilePath:[imageFilePaths objectAtIndex:i]];
                                            
                                                [formData appendPartWithFileData:fileData name:@"image" fileName:fileName mimeType:fileMimeType];
                                            
                                            }
                                        }
                                        
                                    }];
    
    [request setURL:URL];
    [request setTimeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    //-----------------------------------------Configured the NSMUtable Request------------------------------------------------
    
    
    
    
    
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)]];
    
    
    //=============================Upload Progress Report Generation===========================
    
    [operation setUploadProgressBlock:
                                   ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
                                    {
                                        if (totalBytesExpectedToWrite == 0)
                                        {
                                            self.uploadProgressionFraction=0.0;
                                        }
                                        else
                                        {
                                             self.uploadProgressionFraction= totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
                                            
                                            //this block of code has been defined from View controller or the class where this object is used
                                            if(self.progressReporter)
                                                self.progressReporter();
                                         }
                                    }
    ];
    //=============================Upload Progress Report Generation  ends===========================
    
    [operation setCompletionBlockWithSuccess:
                                            ^(AFHTTPRequestOperation *operation, id responseObject)
                                            {
                                                
                                                self.responseStatusCode=[NSString stringWithFormat:@"%i",operation.response.statusCode];
                                                self.httpResponseHeaders=[operation.response allHeaderFields];
                                                self.responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                self.responseData=responseObject;
                                                
                                                //-----executing the block of code which is defined from the view
                                                //      controller/or from where the this Class instance is needed
                                                if (self.completionHandler)
                                                    self.completionHandler();
                                                NSLog(@"\nNetworkResourceDownloader REPORTS:Image Uploaded successfully.....Status code=%s",[self.responseStatusCode UTF8String]);
                                               
                                                
                                            }
                                     failure:
                                            ^(AFHTTPRequestOperation *operation, NSError *error)
                                            {
                                                NSLog(@"Failure: %@", error);
                                                self.responseStatusString=[error localizedDescription];
                                                NSLog(@"\nNetworkResourceDownloader ERROR:Image Upload failed due to %@",self.responseStatusString);
                                                operation=nil;
                                                request=nil;
                                                client=nil;
                                                
                                                if (self.errorHandler)
                                                    self.errorHandler(error);
                                            }
     ];
    
  
    [client enqueueHTTPRequestOperation:operation];
    
}



//=====================================================
//              CANCEL UPLOAD METHOD
//=====================================================
-(void)cancelUpload
{
    self.requestDataDictionary=nil;
    
}




-(NSString*)fileNameFromFilePath:(NSString*)filePath
{
    return [filePath lastPathComponent];
}



-(NSString*)fileMimeTypeFromFilePath:(NSString*)filePath
{
    
    //***************     ````CAUTION````    ************************
    //  HARD CODED ONLY FOR POPULAR IMAGE FORMATS
    //***************************************************************
    
    
    NSString *fileType=[filePath pathExtension];
    NSString *mimeType;
    
    if([fileType isEqualToString:@"jpg"]||
       [fileType isEqualToString:@"jpeg"]||
       [fileType isEqualToString:@"jpe"])
        mimeType=@"image/jpg";
        
    if([fileType isEqualToString:@"png"])
         mimeType=@"image/jpg";
    if([fileType isEqualToString:@"gif"])
        mimeType=@"image/gif";
    
    
    //******************JUST TRYING TO FIND-OUT MIME TYPE OF THE FILE FROM THE FILE EXTENTION*****************
     
     /*CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
     CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
     CFRelease(pathExtension);
     
     // The UTI can be converted to a mime type:
     
      = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    */
    //***************************IS NOT WORKING PROPERLY*******************************************************
    
    return mimeType;
     
    
}



//*****************************SIMPLE GET CONNECTION IS BEING MANUPULATED BY NSURLConnectionDelegate METHODS****************

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [self.responseData appendData:data];
    self.bytesDownloadedSoFar=responseData.length;
    self.downloadProgressionFraction=self.bytesDownloadedSoFar*1.0 /self.totalBytesToBeDownloaded;
    
    if(self.progressReporter)
        self.progressReporter();
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseStatusString=[error localizedDescription];
    self.responseStatusCode=@"404";
    [self cancelDownload];
    if (self.errorHandler)
        self.errorHandler(error);
    NSLog(@"\nNetworkResourceDownloader ERROR:Connection failed...All resources released...");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    // call our completion handler block
    if (self.completionHandler)
        self.completionHandler();
    
    [self cancelDownload];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.totalBytesToBeDownloaded=[response expectedContentLength];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    self.httpResponseHeaders=[httpResponse allHeaderFields];
    self.responseStatusCode=[NSString stringWithFormat:@"%i",[httpResponse statusCode]];
}


@end
