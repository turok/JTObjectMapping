/*
 * This file is part of the JTObjectMapping package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "JTMappings.h"
#import "NSObject+JTObjectMapping.h"

@interface JTMappings : NSObject <JTValidMappingKey>

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSDictionary *mapping;
@property (nonatomic, strong) Class targetClass;

+ (id <JTValidMappingKey>)mappingWithKey:(NSString *)aKey
                             targetClass:(Class)aClass
                                 mapping:(NSDictionary *)aMapping;

@end

@implementation JTMappings

+ (id <JTValidMappingKey>)mappingWithKey:(NSString *)aKey targetClass:(Class)aClass mapping:(NSDictionary *)aMapping {
    JTMappings *obj = [[JTMappings alloc] init];
    obj.key         = aKey;
    obj.mapping     = aMapping;
    obj.targetClass = aClass;
    return obj;
}

- (void)dealloc {
    self.key = nil;
    self.mapping = nil;
    self.targetClass = nil;
}

- (BOOL)transformValue:(NSObject *)oldValue
               toValue:(NSObject **)newValue
                forKey:(NSString **)key {
    
    if ([oldValue isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in (NSArray *)oldValue) {
            id obj = [self.targetClass objectFromJSONObject:dict mapping:self.mapping];
            [array addObject:obj];
        }

        *newValue = array;
        *key      = self.key;

        return YES;

    } else if ([oldValue isKindOfClass:[NSDictionary class]]) {
        id obj = [self.targetClass objectFromJSONObject:(NSDictionary *)oldValue mapping:self.mapping];
        
        *newValue = obj;
        *key      = self.key;

        return YES;
    } else if ([oldValue isKindOfClass:[NSNull class]]) {
        
        *newValue = nil;
        *key      = self.key;

        return YES;
    }
    
    return NO;
}

@end

#pragma mark -

@implementation NSObject (JTValidMappingKey)

+ (id <JTValidMappingKey>)mappingWithKey:(NSString *)key mapping:(NSDictionary *)mapping {
    return [JTMappings mappingWithKey:key targetClass:[self class] mapping:mapping];
}

@end
