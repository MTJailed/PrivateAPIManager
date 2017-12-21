//
//  MSVZExtractor.m
//  XTJailed
//
//  Created by Sem Voigtländer on 13/12/2017.
//  Copyright © 2017 Jailed Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSVZipArchive.h"
#import "APIManager.h"
@interface MSVZExtractor()
{
    Class MSVZipArchive; //The class you found in the framework
    id instance; //So you can get and set the class it's properties (instantiate)
}
@end

@implementation MSVZExtractor


/*
	Function: Extracts a zip archive to a directory
	PrivateAPI: MediaServices
	@param input: Path to the archive to be extracted
	@param to: Path to the directory you want the files to be extracted to
	@return: True or false, depending on if the extraction succeeds
*/

- (BOOL)extract:(NSString*)input to:(NSString*)output {
    if([APIManager loadPFW:@"MediaServices"]) {
        if(!MSVZipArchive) {
            MSVZipArchive = NSClassFromString(@"MSVZipArchive");
        }
        if(!instance) {
            instance = [[MSVZipArchive alloc] init];
        }
        [instance setValue:input forKey:@"_archivePath"];
        NSError *extractionError = nil;
        [instance decompressToPath:output withError:&extractionError];
        if(extractionError) {
            printf("Failed to extract archive: %s\n", [extractionError
                   .localizedDescription UTF8String]);
	    return NO;
        }
    } else {
        return NO;
    }
    return YES;
}

//Fake Selector
- (void) decompressToPath:(NSString*)outputPath withError:(id*)error{
    
}

@end

