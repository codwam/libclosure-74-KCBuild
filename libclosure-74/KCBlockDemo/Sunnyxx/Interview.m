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

static void *origin_invoke;
static void *origin_block;
static void* (*original__Block_copy)(id);

static void __my_block_func_1(void *__cself, ...) {
    va_list args;
    va_start(args, __cself);
    __unsafe_unretained NSObject *myBlock = CFBridgingRelease(origin_block);

    const char * signature = _Block_signature(__cself);

        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:signature];
        NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [blockInvocation setArgument:&__cself atIndex:0];
        
        NSMutableArray *paramArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 1; i < methodSignature.numberOfArguments; ++i) {
            const char *s = [methodSignature getArgumentTypeAtIndex:i];
            NSString *str = [NSString stringWithUTF8String:s];
            [paramArray addObject:str];
        }
        NSInteger paramCount = 1;
        NSMutableString *paramLog = [NSMutableString stringWithString:@"<Hooked>\n"];
        // Objective-C type encodings https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        // String Format Specifiers https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
        NSDictionary *type_code = @{@"c": @"char",
                                           @"i": @"int",
                                           @"s": @"short",
                                           @"l": @"long",
                                           @"q": @"long long",
                                           @"C": @"unsigned char",
                                           @"I": @"unsigned int",
                                           @"S": @"unsigned short",
                                           @"L": @"unsigned long",
                                           @"Q": @"unsigned long long",
                                           @"f": @"float",
                                           @"d": @"double",
                                           @"B": @"BOOL",
    //                                       @"v": @"void",
                                           @"*": @"char *",
                                           @"@": @"id",
                                           @"#": @"Class",
                                           @":": @"SEL",
                                           @"?": @"unknown"
                                           };
        NSDictionary *type_format = @{@"c": @"%c",
                                             @"i": @"%d",
                                             @"s": @"%hd",
                                             @"l": @"%ld",
                                             @"q": @"%lld",
                                             @"C": @"%c",
                                             @"I": @"%u",
                                             @"S": @"%hu",
                                             @"L": @"%lu",
                                             @"Q": @"%llu",
                                             @"f": @"%f",
                                             @"d": @"%lf",
                                             @"B": @"%@",
    //                                         @"v": @"%@",
                                             @"*": @"%s",
                                             @"@": @"%@",
                                             @"#": @"%@",
                                             @":": @"%@",
                                             @"?": @"%p"
                                             };
        for (NSString *varType in paramArray) {
            NSString *code = [type_code objectForKey:varType] ?: @"unknown";
            NSString *format = [type_format objectForKey:varType] ?: @"%@";
            NSString *fmt = [NSString stringWithFormat:@"<%ld> [%@] %@\n", paramCount, code, format];
            // char
            if ([varType isEqualToString:@"c"]) {
                char arg = va_arg(args, int);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // int
            else if ([varType isEqualToString:@"i"]) {
                int arg = va_arg(args, int);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // short
            else if ([varType isEqualToString:@"s"]) {
                short arg = va_arg(args, int);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // long
            else if ([varType isEqualToString:@"l"]) {
                long arg = va_arg(args, long);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // long long
            else if ([varType isEqualToString:@"q"]) {
                long long arg = va_arg(args, long long);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // unsigned char
            else if ([varType isEqualToString:@"C"]) {
                unsigned char arg = va_arg(args, int);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // unsigned int
            else if ([varType isEqualToString:@"I"]) {
                unsigned int arg = va_arg(args, unsigned int);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // unsigned short
            else if ([varType isEqualToString:@"S"]) {
                unsigned short arg = va_arg(args, int);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // unsigned long
            else if ([varType isEqualToString:@"L"]) {
                unsigned long arg = va_arg(args, unsigned long);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // unsigned long long
            else if ([varType isEqualToString:@"Q"]) {
                unsigned long long arg = va_arg(args, unsigned long long);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // float
            else if ([varType isEqualToString:@"f"]) {
                float arg = va_arg(args, float);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // double
            else if ([varType isEqualToString:@"d"]) {
                double arg = va_arg(args, double);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // bool (_Bool) <! NOT BOOL -> BOOL is char
            else if ([varType isEqualToString:@"B"]) {
                BOOL arg = va_arg(args, int);
                [paramLog appendFormat:fmt, arg ? @"YES": @"NO"];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // void
    //        else if ([varType isEqualToString:@"v"]) {
    //        }
            // char *
            else if ([varType isEqualToString:@"*"]) {
                char *arg = va_arg(args, char *);
                [paramLog appendFormat:fmt, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // id (@)
            // array ([array type])
            // structure ({name=type...})
            // union ((name=type...))
            // bit field (bnum)
            // pointer (^type)
            else if ([varType isEqualToString:@"@"] ||
                     varType.length > 2) {
                id arg = va_arg(args, id);
                if ([varType isEqualToString:@"@\"NSArray\""]) {
                    [paramLog appendFormat:@"<%ld> [%@] (\n\t%@\n)\n",
                     paramCount, [arg class],
                     [[arg valueForKey:@"description"] componentsJoinedByString:@",\n\t"]];
                } else {
                    [paramLog appendFormat:@"<%ld> [%@] %@\n", paramCount, [arg class], arg];
                }
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // Class
            else if ([varType isEqualToString:@"#"]) {
                id arg = va_arg(args, id);
                [paramLog appendFormat:@"<%ld> [%@] %@\n", paramCount, [arg class], arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // SEL
            else if ([varType isEqualToString:@":"]) {
    //            typedef struct objc_selector *SEL;
                SEL arg = va_arg(args, SEL);
                [paramLog appendFormat:@"<%ld> [SEL] %s\n", paramCount, sel_getName(arg)];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            // unknown
            else {
                void *arg = va_arg(args, void *);
                [paramLog appendFormat:@"<%ld> [unknown] %p\n", paramCount, arg];
                [blockInvocation setArgument:&arg atIndex:(paramCount)];
            }
            
            paramCount += 1;
        }
        
        NSLog(@"%@", paramLog);
        va_end(args);
    // 调用self，会死循环。
//    __unsafe_unretained id target = (__bridge id _Nonnull)(__cself);
    // 调用copy block。
//    [blockInvocation invokeWithTarget:myBlock];
    
    // call original
    // 没问题的，但是是固定参数的。
    //    ((void(*)(void *, ...)) origin_invoke)(__cself, 1, @"222");
//    ((void(*)(void *, ...)) origin_invoke)(__cself, __VA_ARGS__);
    
    void *arg1 = NULL;
    [blockInvocation getArgument:&arg1 atIndex:1];
    void *arg2 = NULL;
    [blockInvocation getArgument:&arg2 atIndex:2];
    switch (paramCount - 1) {
        case 2:
            ((void(*)(void *, ...)) origin_invoke)(__cself, arg1, arg2);
            break;
        default:
            break;
    }
}

static void hook__Block_copy_helper(void* block) {
    struct Block_layout *impl = (struct Block_layout *) block;
    NSLog(@"%lu", impl->descriptor->size);
//
//    uint8_t *desc = (uint8_t *) impl->descriptor;
//    desc += sizeof(struct Block_descriptor_1);
//    if (impl->flags & BLOCK_HAS_COPY_DISPOSE) {
//        desc += sizeof(struct Block_descriptor_2);
//    }
//    if (impl->flags & BLOCK_HAS_SIGNATURE) {
//        desc += sizeof(struct Block_descriptor_3);
//    }
//    if (_Block_has_signature((__bridge void *)(block))) {
//        const char * s = _Block_signature((__bridge void *)(block));
//        NSLog(@"%s", s);
//    }
    
    // 调用原来的有点麻烦
    origin_invoke = (void *)impl->invoke;
    // 所以用了这种再copy一次的方式。invoke指针指向原来的。
    origin_block = (void *)malloc(impl->descriptor->size);
    memcpy(origin_block, impl, impl->descriptor->size);
    
    impl->invoke = (void *)__my_block_func_1;
}

static void * hook__Block_copy(id block) {
    void* ret = original__Block_copy(block);
    
    hook__Block_copy_helper(ret);
    
    return ret;
}

static void HookEveryBlockToPrintArguments() {
    struct  rebinding open_rebinding = {
        "_Block_copy",
        (void *)hook__Block_copy,
        (void **)&original__Block_copy
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
    
    void (^block2)(long long, NSObject *b) = ^(__unused long long a, __unused NSObject *b) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
    };
    block2(0x1234, [NSObject new]);
    
    /*
     <1> [double] 4660.000000
     <2> [NSTaggedPointerString] eeee c Mu.CRamr
     
     第二个识别错误了
     */
//    void (^block3)(double, CGRect b) = ^(__unused double a, __unused CGRect b) {
//        NSLog(@"%s", __PRETTY_FUNCTION__);
//    };
//    block3(0x1234, CGRectZero);
}


#pragma mark - Interview

@implementation Interview

+ (void)test {
    test3();
}

@end
