//
//  main.m
//  KCBlockDemo
//
//  Created by cooci on 2020/11/12.
//

#import <Foundation/Foundation.h>

typedef void(^VoidBlock)(void);

// MARK: - global

static void test_global(void) {
    VoidBlock block = ^{
        NSLog(@"Hello, World!");
    };
    NSLog(@"%@", [block class]);
    block();
    
    /*
     编译的时候是_NSConcreteStackBlock，但调试的时候是__NSGlobalBlock__
     */
}

// MARK: - stack

static void test_stack(void) {
    int a = 10;
    NSLog(@"%@", [^{
        NSLog(@"%d", a);
    } class]);
    
    /*
     __NSStackBlock__， 根本不走_Block_copy
     */
}

// MARK: - malloc

static void test_malloc(void) {
    int a = 10;
    VoidBlock block = ^{
        NSLog(@"%d", a);
    };
    NSLog(@"%@", [block class]);
    block();
    
    /*
     __NSMallocBlock__，没有copy和dispose函数。
     */
}

static void test_malloc_2(void) {
    NSObject* obj = [NSObject new];
    VoidBlock block = [^{
        NSLog(@"%@", obj);
    } copy];
    NSLog(@"%@", [block class]);
    block();
    
    /*
     __NSMallocBlock__，有copy和dispose函数。但是没有调用_Block_object_assign和_Block_object_dispose函数。
     */
}

static void test_malloc_3(void) {
    __block int a = 10;
    VoidBlock block = [^{
        NSLog(@"%d", a);
    } copy];
    NSLog(@"%@", [block class]);
    block();
    
    /*
     __NSMallocBlock__，有copy和dispose函数。有调用_Block_object_assign和_Block_object_dispose函数。
     */
}

static void test_malloc_4(void) {
    __block NSObject* obj = [NSObject new];
    VoidBlock block = [^{
        NSLog(@"%@", obj);
    } copy];
    NSLog(@"%@", [block class]);
    block();
    
    /*
     __NSMallocBlock__，有copy和dispose函数。但是没有调用_Block_object_assign和_Block_object_dispose函数。
     */
}

static void test() {
    //        test_global();
    //        test_stack();
    //        test_malloc();
    //        test_malloc_2();
    //        test_malloc_3();
            test_malloc_4();
}

#import "Sunnyxx/Interview.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        __block int a = 10;
//        void (^mallocBlock)(void) = ^void { a++; };
//        NSLog(@"MallocBlock is %@", mallocBlock);
//
//        NSLog(@"Hello, World!");
    
//        test();
        
        [Interview test];
    }
    return 0;
}
