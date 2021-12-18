//
//  main.m
//  KCBlockBuild
//
//  Created by cooci on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import "../SelfTest/SelfTest.h"
#import "../Sunnyxx/Interview.h"

int main(__unused int argc, __unused const char * argv[]) {
    @autoreleasepool {
  
//        NSObject *objc = [[NSObject alloc] init];
//        NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
//        void (^kcBlock)(void) = ^void {
//            NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
//        };
//        kcBlock();
//        NSLog(@"KCBlock is %@", kcBlock);
        
//        [SelfTest test];
        [Interview test];
    }
    return 0;
}
