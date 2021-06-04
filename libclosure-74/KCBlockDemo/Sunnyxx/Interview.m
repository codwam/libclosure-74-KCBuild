//
//  Interview.m
//  KCBlockDemo
//
//  Created by anon on 2021/6/3.
//

#import "Interview.h"
#import "fishhook.h"
#import "Block_private.h"

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};


#pragma mark - 第一题

static void HelloWorld() {
    NSLog(@"Hello world!");
}

static void HookBlockToPrintHelloWorld(id block) {
    if ([block isMemberOfClass:NSClassFromString(@"__NSGlobalBlock__")]) {
        NSLog(@"__NSGlobalBlock__ 不支持修改");
        exit(-1);
    }
    struct __block_impl *impl = (__bridge struct __block_impl *) block;
    impl->FuncPtr = (void *) &HelloWorld;
}

static void test1() {
    {
        // 堆上面的没问题
        int a = 0;
        void(^block)(void) = ^{
            __unused int b = a;
            NSLog(@"%s", __PRETTY_FUNCTION__);
        };
        HookBlockToPrintHelloWorld(block);
        block();
    }
    {
        // 全局block是有问题的
        void(^block)(void) = ^{
            NSLog(@"%s", __PRETTY_FUNCTION__);
        };
        HookBlockToPrintHelloWorld(block);
        block();
    }
}

#pragma mark - 第二题

static void *HookBlockToPrintArguments_original_func;

static void HookBlockToPrintArguments_block_func_0(void *__self, int a, NSString *b) {
    NSLog(@"%d, %@", a, b);
    ((void (*)(void *, int, NSString *))HookBlockToPrintArguments_original_func)(__self, a, b);
}

static void HookBlockToPrintArguments(id block) {
    struct __block_impl *impl = (__bridge struct __block_impl *) block;
    if ([block isMemberOfClass:NSClassFromString(@"__NSGlobalBlock__")]) {
        NSLog(@"__NSGlobalBlock__ 不支持修改");
        exit(-1);
    }
    
    HookBlockToPrintArguments_original_func = impl->FuncPtr;
    impl->FuncPtr = (void *) &HookBlockToPrintArguments_block_func_0;
}

static void test2() {
    {
        int tmp = 1;
        void (^block)(int, NSString*) = ^(__unused int a, __unused NSString* b) {
            __unused int _tmp = tmp;
            NSLog(@"%s", __PRETTY_FUNCTION__);
        };
        HookBlockToPrintArguments(block);
        block(123, @"abc");
    }
}

#pragma mark - 第三题

static void * (*_Block_copy_original)(id);

static void * _Block_copy_new(id block) {
    void* ret = _Block_copy_original(block);
    
    struct Block_layout *impl = (struct Block_layout *) ret;
    NSLog(@"%lu", impl->descriptor->size);
    
    uint8_t *desc = (uint8_t *) impl->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (impl->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct Block_descriptor_2);
    }
    if (impl->flags & BLOCK_HAS_SIGNATURE) {
        struct Block_descriptor_3 *desc2 = (struct Block_descriptor_3 *)desc;
        desc += sizeof(struct Block_descriptor_3);
    }
    BOOL r = _Block_has_signature(ret);
    const char * s = _Block_signature(ret);
    
//    int *first = (int *)desc;
//    NSLog(@"(int) = %d", *first);
//    id second = (__bridge id)(void *)(first + 1);
//    NSLog(@"(NSString) = %@", second);
    
    return ret;
}

static void HookEveryBlockToPrintArguments() {
    struct  rebinding open_rebinding = {
        "_Block_copy",
        (void *)&_Block_copy_new,
        (void **)&_Block_copy_original
    };
    
    rebind_symbols((struct rebinding[1]){open_rebinding}, 1);
}

static void test3() {
    HookEveryBlockToPrintArguments();
    
    int tmp = 15;
    void (^block1)(int a, NSString *b) = ^(__unused int a, __unused NSString *b) {
        __unused int _tmp = tmp;
        NSLog(@"%s", __PRETTY_FUNCTION__);
    };
    
    block1(0x1234, @"dsadas");
}


#pragma mark - Interview

@implementation Interview

+ (void)test {
    test3();
}

@end
